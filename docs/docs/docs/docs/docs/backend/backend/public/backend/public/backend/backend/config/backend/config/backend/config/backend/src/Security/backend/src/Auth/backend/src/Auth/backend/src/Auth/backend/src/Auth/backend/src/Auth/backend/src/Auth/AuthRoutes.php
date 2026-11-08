<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use Slim\App;

final class AuthRoutes
{
    public static function register(
        App $app,
        AuthController $controller
    ): void {
        // User Registration
        $app->post(
            '/api/v1/auth/register',
            [$controller, 'register']
        );

        // User Login
        $app->post(
            '/api/v1/auth/login',
            [$controller, 'login']
        );
    }
}
