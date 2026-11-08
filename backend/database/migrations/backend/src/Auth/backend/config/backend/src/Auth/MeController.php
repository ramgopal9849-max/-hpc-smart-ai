<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

final class MeController
{
    public function __invoke(
        ServerRequestInterface $request,
        ResponseInterface $response
    ): ResponseInterface {
        $userId = $request->getAttribute('auth_user_id');

        if (!is_string($userId) || $userId === '') {
            $response->getBody()->write(
                json_encode([
                    'success' => false,
                    'message' => 'Authentication required.',
                ])
            );

            return $response
                ->withStatus(401)
                ->withHeader('Content-Type', 'application/json');
        }

        $response->getBody()->write(
            json_encode([
                'success' => true,
                'data' => [
                    'user_id' => $userId,
                    'authenticated' => true,
                ],
            ], JSON_UNESCAPED_SLASHES)
        );

        return $response->withHeader(
            'Content-Type',
            'application/json'
        );
    }
}
