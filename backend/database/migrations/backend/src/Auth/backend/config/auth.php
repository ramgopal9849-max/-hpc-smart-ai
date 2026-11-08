<?php

declare(strict_types=1);

/**
 * HPC Smart AI - Authentication Configuration
 *
 * वास्तविक secrets केवल environment variables (.env) में रखें।
 * इस फ़ाइल में कोई असली API Key या JWT Secret न लिखें।
 */

$jwtSecret = getenv('JWT_SECRET') ?: '';

if (strlen($jwtSecret) < 32) {
    throw new RuntimeException(
        'JWT_SECRET must be configured with at least 32 characters.'
    );
}

$issuer = getenv('JWT_ISSUER') ?: 'hpc-smart-ai';
$audience = getenv('JWT_AUDIENCE') ?: 'hpc-smart-ai-users';

$tokenLifetime = filter_var(
    getenv('JWT_TTL') ?: '3600',
    FILTER_VALIDATE_INT
);

if (
    $tokenLifetime === false
    || $tokenLifetime < 60
    || $tokenLifetime > 86400
) {
    throw new RuntimeException(
        'JWT_TTL must be between 60 and 86400 seconds.'
    );
}

return [
    'jwt' => [
        'secret' => $jwtSecret,
        'issuer' => $issuer,
        'audience' => $audience,
        'ttl' => $tokenLifetime,
        'algorithm' => 'HS256',
    ],
];
