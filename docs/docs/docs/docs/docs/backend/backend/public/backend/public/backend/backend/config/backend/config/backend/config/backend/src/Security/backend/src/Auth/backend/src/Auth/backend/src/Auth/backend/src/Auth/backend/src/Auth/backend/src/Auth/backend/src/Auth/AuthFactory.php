<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use PDO;
use InvalidArgumentException;

final class AuthFactory
{
    public static function create(
        PDO $database,
        string $jwtSecret,
        string $jwtIssuer,
        string $jwtAudience,
        int $tokenLifetime = 3600
    ): AuthController {
        if (!$database->getAttribute(PDO::ATTR_ERRMODE)) {
            throw new InvalidArgumentException(
                'Database connection is not configured correctly.'
            );
        }

        $tokenManager = new TokenManager(
            $jwtSecret,
            $jwtIssuer,
            $jwtAudience,
            $tokenLifetime
        );

        $authService = new AuthService(
            $database,
            $tokenManager
        );

        return new AuthController($authService);
    }
}
