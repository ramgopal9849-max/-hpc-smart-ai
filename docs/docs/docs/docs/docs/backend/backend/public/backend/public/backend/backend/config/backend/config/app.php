<?php

declare(strict_types=1);

return [

    /*
    |--------------------------------------------------------------------------
    | Application Information
    |--------------------------------------------------------------------------
    */

    'name' => $_ENV['APP_NAME'] ?? 'HPC Smart AI',

    'environment' => $_ENV['APP_ENV'] ?? 'production',

    'debug' => filter_var(
        $_ENV['APP_DEBUG'] ?? false,
        FILTER_VALIDATE_BOOLEAN
    ),

    'url' => $_ENV['APP_URL'] ?? '',

    'version' => '1.0.0',

    /*
    |--------------------------------------------------------------------------
    | Security Configuration
    |--------------------------------------------------------------------------
    */

    'security' => [

        'force_https' => filter_var(
            $_ENV['FORCE_HTTPS'] ?? true,
            FILTER_VALIDATE_BOOLEAN
        ),

        'rate_limit_enabled' => filter_var(
            $_ENV['RATE_LIMIT_ENABLED'] ?? true,
            FILTER_VALIDATE_BOOLEAN
        ),

        'rate_limit_per_minute' => (int) (
            $_ENV['RATE_LIMIT_PER_MINUTE'] ?? 60
        ),

        'jwt_access_token_ttl' => (int) (
            $_ENV['JWT_ACCESS_TOKEN_TTL'] ?? 900
        ),

        'jwt_refresh_token_ttl' => (int) (
            $_ENV['JWT_REFRESH_TOKEN_TTL'] ?? 604800
        ),

    ],

    /*
    |--------------------------------------------------------------------------
    | AI Configuration
    |--------------------------------------------------------------------------
    */

    'ai' => [

        'provider' => $_ENV['AI_PROVIDER'] ?? '',

        'model' => $_ENV['AI_MODEL'] ?? '',

        'default_mode' => 'READ_ONLY',

        'allow_external_modifications' => false,

        'require_admin_approval' => true,

    ],

    /*
    |--------------------------------------------------------------------------
    | File Upload Configuration
    |--------------------------------------------------------------------------
    */

    'uploads' => [

        'max_size' => (int) (
            $_ENV['UPLOAD_MAX_SIZE'] ?? 10485760
        ),

        'allowed_types' => array_filter(
            explode(
                ',',
                $_ENV['UPLOAD_ALLOWED_TYPES']
                    ?? 'pdf,docx,xlsx,csv,txt'
            )
        ),

    ],

    /*
    |--------------------------------------------------------------------------
    | Storage Configuration
    |--------------------------------------------------------------------------
    */

    'storage' => [

        'driver' => $_ENV['STORAGE_DRIVER'] ?? 'local',

        'path' => $_ENV['STORAGE_PATH'] ?? 'storage',

    ],

    /*
    |--------------------------------------------------------------------------
    | Logging Configuration
    |--------------------------------------------------------------------------
    */

    'logging' => [

        'level' => $_ENV['LOG_LEVEL'] ?? 'warning',

        'path' => $_ENV['LOG_PATH'] ?? 'storage/logs',

    ],

];
