<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Throwable;
use InvalidArgumentException;
use RuntimeException;

final class TokenManager
{
    private string $secret;
    private string $issuer;
    private string $audience;
    private int $ttl;

    public function __construct(
        string $secret,
        string $issuer,
        string $audience,
        int $ttl = 3600
    ) {
        if (strlen($secret) < 32) {
            throw new InvalidArgumentException(
                'JWT secret must be at least 32 characters.'
            );
        }

        if ($issuer === '' || $audience === '') {
            throw new InvalidArgumentException(
                'JWT issuer and audience are required.'
            );
        }

        if ($ttl < 60 || $ttl > 86400) {
            throw new InvalidArgumentException(
                'JWT lifetime must be between 60 and 86400 seconds.'
            );
        }

        $this->secret = $secret;
        $this->issuer = $issuer;
        $this->audience = $audience;
        $this->ttl = $ttl;
    }

    /**
     * नया JWT Access Token बनाएँ।
     */
    public function create(string $userId): string
    {
        if ($userId === '') {
            throw new InvalidArgumentException(
                'User ID is required.'
            );
        }

        $now = time();

        $payload = [
            'iss' => $this->issuer,
            'aud' => $this->audience,
            'sub' => $userId,
            'iat' => $now,
            'nbf' => $now,
            'exp' => $now + $this->ttl,
            'jti' => bin2hex(random_bytes(16)),
        ];

        return JWT::encode(
            $payload,
            $this->secret,
            'HS256'
        );
    }

    /**
     * JWT Token की जाँच करें।
     */
    public function verify(string $token): ?array
    {
        if ($token === '') {
            return null;
        }

        try {
            $decoded = JWT::decode(
                $token,
                new Key($this->secret, 'HS256')
            );

            $claims = (array) $decoded;

            if (($claims['iss'] ?? null) !== $this->issuer) {
                return null;
            }

            $aud = $claims['aud'] ?? null;

            $validAudience = is_string($aud)
                ? $aud === $this->audience
                : (
                    is_array($aud)
                    && in_array($this->audience, $aud, true)
                );

            if (!$validAudience) {
                return null;
            }

            if (
                !isset($claims['sub'])
                || !is_string($claims['sub'])
                || $claims['sub'] === ''
            ) {
                return null;
            }

            return $claims;

        } catch (Throwable $exception) {
            return null;
        }
    }
}
