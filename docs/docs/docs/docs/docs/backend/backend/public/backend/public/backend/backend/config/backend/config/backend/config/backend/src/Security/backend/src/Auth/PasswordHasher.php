<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use InvalidArgumentException;
use RuntimeException;

final class PasswordHasher
{
    /**
     * Password को सुरक्षित hash में बदलें।
     */
    public static function hash(string $password): string
    {
        if (trim($password) === '') {
            throw new InvalidArgumentException(
                'Password cannot be empty.'
            );
        }

        if (strlen($password) > 4096) {
            throw new InvalidArgumentException(
                'Password is too long.'
            );
        }

        // PASSWORD_DEFAULT के bcrypt implementation की 72-byte सीमा।
        if (defined('PASSWORD_BCRYPT') && PASSWORD_DEFAULT === PASSWORD_BCRYPT
            && strlen($password) > 72) {
            throw new InvalidArgumentException(
                'Password exceeds the supported length.'
            );
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);

        if ($hash === false) {
            throw new RuntimeException(
                'Password hashing failed.'
            );
        }

        return $hash;
    }

    /**
     * दिए गए Password को stored hash से verify करें।
     */
    public static function verify(
        string $password,
        string $hash
    ): bool {
        if ($password === '' || $hash === '') {
            return false;
        }

        return password_verify($password, $hash);
    }

    /**
     * जांचें कि पुराने hash को दोबारा बनाना जरूरी है या नहीं।
     */
    public static function needsRehash(string $hash): bool
    {
        if ($hash === '') {
            return true;
        }

        return password_needs_rehash(
            $hash,
            PASSWORD_DEFAULT
        );
    }
}
