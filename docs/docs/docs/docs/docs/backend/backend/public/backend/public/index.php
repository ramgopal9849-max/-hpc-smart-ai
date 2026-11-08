<?php

declare(strict_types=1);

/**
 * HPC Smart AI
 * Main Backend API Entry Point
 *
 * Default operation: READ-ONLY
 */

use Slim\Factory\AppFactory;
use Slim\Psr7\Response;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

define('HPC_SMART_AI', true);

$basePath = dirname(__DIR__);

$autoloadPath = $basePath . '/vendor/autoload.php';

if (!file_exists($autoloadPath)) {
    http_response_code(503);
    header('Content-Type: application/json');

    echo json_encode([
        'success' => false,
        'error' => 'Backend dependencies are not installed.',
        'message' => 'Run composer install before starting the API.'
    ]);

    exit;
}

require $autoloadPath;

// Load environment configuration if available.
if (class_exists(\Dotenv\Dotenv::class)) {
    $envFile = $basePath . '/.env';

    if (file_exists($envFile)) {
        \Dotenv\Dotenv::createImmutable($basePath)->safeLoad();
    }
}

// Create application.
$app = AppFactory::create();

// Basic security headers.
$app->add(function (
    ServerRequestInterface $request,
    $handler
): ResponseInterface {
    $response = $handler->handle($request);

    return $response
        ->withHeader('X-Content-Type-Options', 'nosniff')
        ->withHeader('X-Frame-Options', 'DENY')
        ->withHeader('Referrer-Policy', 'no-referrer')
        ->withHeader('Cache-Control', 'no-store');
});

// Error handling.
$app->addErrorMiddleware(
    filter_var(
        $_ENV['APP_DEBUG'] ?? false,
        FILTER_VALIDATE_BOOLEAN
    ),
    true,
    true
);

// JSON response helper.
$jsonResponse = function (
    ResponseInterface $response,
    array $data,
    int $status = 200
): ResponseInterface {
    $response->getBody()->write(
        json_encode(
            $data,
            JSON_UNESCAPED_SLASHES |
            JSON_UNESCAPED_UNICODE
        )
    );

    return $response
        ->withStatus($status)
        ->withHeader('Content-Type', 'application/json; charset=utf-8');
};

// API root.
$app->get('/', function (
    ServerRequestInterface $request,
    ResponseInterface $response
) use ($jsonResponse): ResponseInterface {

    return $jsonResponse($response, [
        'success' => true,
        'application' => 'HPC Smart AI',
        'version' => '1.0.0',
        'message' => 'HPC Smart AI API is running.',
        'mode' => 'READ-ONLY'
    ]);
});

// Health check.
$app->get('/api/v1/health', function (
    ServerRequestInterface $request,
    ResponseInterface $response
) use ($jsonResponse): ResponseInterface {

    return $jsonResponse($response, [
        'success' => true,
        'status' => 'healthy',
        'service' => 'HPC Smart AI Backend',
        'version' => '1.0.0'
    ]);
});

// API information.
$app->get('/api/v1', function (
    ServerRequestInterface $request,
    ResponseInterface $response
) use ($jsonResponse): ResponseInterface {

    return $jsonResponse($response, [
        'success' => true,
        'application' => 'HPC Smart AI',
        'api_version' => 'v1',
        'available_endpoints' => [
            '/api/v1',
            '/api/v1/health'
        ],
        'security' => 'Authentication required for private endpoints.',
        'default_mode' => 'READ-ONLY'
    ]);
});

// JSON 404 response.
$app->map(
    ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    '/{routes:.*}',
    function (
        ServerRequestInterface $request,
        ResponseInterface $response
    ) use ($jsonResponse): ResponseInterface {

        return $jsonResponse($response, [
            'success' => false,
            'error' => 'API endpoint not found.'
        ], 404);
    }
);

// Start API.
$app->run();
