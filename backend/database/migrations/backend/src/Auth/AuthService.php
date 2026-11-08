<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use PDO;
use RuntimeException;
use InvalidArgumentException;
use PDOException;

final class AuthService
{
    public function __construct(
        private readonly PDO $database,
        private readonly TokenManager $tokenManager
    ) {
    }

    /**
     * नया User Register करें।
     */
    public function register(
        string $name,
        string $email,
        string $password
    ): array {
        $name = trim($name);
        $email = strtolower(trim($email));

        if ($name === '') {
            throw new InvalidArgumentException('Name is required.');
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidArgumentException('Invalid email address.');
        }

        if (strlen($password) < 12) {
            throw new InvalidArgumentException(
                'Password must contain at least 12 characters.'
            );
        }

        $passwordHash = PasswordHasher::hash($password);

        try {
            $statement = $this->database->prepare(
                'INSERT INTO users
                    (name, email, password_hash, account_status)
                 VALUES
                    (:name, :email, :password_hash, :account_status)'
            );

            $statement->execute([
                'name' => $name,
                'email' => $email,
                'password_hash' => $passwordHash,
                'account_status' => 'active',
            ]);

        } catch (PDOException $exception) {
            if ($exception->getCode() === '23000') {
                throw new RuntimeException(
                    'An account with this email or phone already exists.'
                );
            }

            throw $exception;
        }

        return [
            'user_id' => (string) $this->database->lastInsertId(),
            'name' => $name,
            'email' => $email,
        ];
    }

    /**
     * User Login करें।
     */
    public function login(
        string $email,
        string $password
    ): array {
        $email = strtolower(trim($email));

        if (
            !filter_var($email, FILTER_VALIDATE_EMAIL)
            || $password === ''
        ) {
            throw new RuntimeException('Invalid email or password.');
        }

        $statement = $this->database->prepare(
            'SELECT
                id,
                name,
                email,
                password_hash,
                account_status
             FROM users
             WHERE email = :email
             LIMIT 1'
        );

        $statement->execute(['email' => $email]);

        $user = $statement->fetch(PDO::FETCH_ASSOC);

        if (
            !$user
            || !PasswordHasher::verify(
                $password,
                (string) $user['password_hash']
            )
        ) {
            throw new RuntimeException('Invalid email or password.');
        }

        if ($user['account_status'] !== 'active') {
            throw new RuntimeException('Account is not active.');
        }

        if (
            PasswordHasher::needsRehash(
                (string) $user['password_hash']
            )
        ) {
            $newHash = PasswordHasher::hash($password);

            $update = $this->database->prepare(
                'UPDATE users
                 SET password_hash = :password_hash
                 WHERE id = :id'
            );

            $update->execute([
                'password_hash' => $newHash,
                'id' => $user['id'],
            ]);
        }

        $userId = (string) $user['id'];

        return [
            'user' => [
                'id' => $userId,
                'name' => $user['name'],
                'email' => $user['email'],
            ],
            'access_token' => $this->tokenManager->create($userId),
            'token_type' => 'Bearer',
        ];
    }
}
