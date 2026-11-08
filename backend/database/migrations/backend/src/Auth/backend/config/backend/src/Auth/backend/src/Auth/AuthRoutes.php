<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use Slim\App;

final class AuthRoutes
{
    public static function register(
        App $app,
        AuthController $authController,
        AuthMiddleware $authMiddleware,
        MeController $meController
    ): void {
        // Public Registration API
        $app->post(
            '/api/v1/auth/register',
            [$authController, 'register']
        );

        // Public Login API
        $app->post(
            '/api/v1/auth/login',
            [$authController, 'login']
        );

        // Protected Current User API
        $app->get(
            '/api/v1/auth/me',
            $meController
        )->add($authMiddleware);
    }
}
