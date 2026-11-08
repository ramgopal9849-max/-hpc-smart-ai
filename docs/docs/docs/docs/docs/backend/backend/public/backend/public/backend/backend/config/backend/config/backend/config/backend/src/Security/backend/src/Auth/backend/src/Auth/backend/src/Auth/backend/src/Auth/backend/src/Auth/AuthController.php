<?php

declare(strict_types=1);

namespace HPC\SmartAI\Auth;

use JsonException;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Slim\Psr7\Response;
use Throwable;

final class AuthController
{
    public function __construct(
        private readonly AuthService $authService
    ) {
    }

    /**
     * User Registration API
     */
    public function register(
        ServerRequestInterface $request,
        ResponseInterface $response
    ): ResponseInterface {
        try {
            $data = $this->getRequestData($request);

            $result = $this->authService->register(
                (string) ($data['name'] ?? ''),
                (string) ($data['email'] ?? ''),
                (string) ($data['password'] ?? '')
            );

            return $this->jsonResponse($response, [
                'success' => true,
                'message' => 'Registration successful.',
                'data' => $result,
            ], 201);

        } catch (JsonException $exception) {
            return $this->errorResponse(
                $response,
                'Invalid JSON request.',
                400
            );
        } catch (Throwable $exception) {
            return $this->errorResponse(
                $response,
                'Registration could not be completed.',
                400
            );
        }
    }

    /**
     * User Login API
     */
    public function login(
        ServerRequestInterface $request,
        ResponseInterface $response
    ): ResponseInterface {
        try {
            $data = $this->getRequestData($request);

            $result = $this->authService->login(
                (string) ($data['email'] ?? ''),
                (string) ($data['password'] ?? '')
            );

            return $this->jsonResponse($response, [
                'success' => true,
                'message' => 'Login successful.',
                'data' => $result,
            ]);

        } catch (JsonException $exception) {
            return $this->errorResponse(
                $response,
                'Invalid JSON request.',
                400
            );
        } catch (Throwable $exception) {
            return $this->errorResponse(
                $response,
                'Invalid email or password.',
                401
            );
        }
    }

    /**
     * JSON Request Data पढ़ें।
     */
    private function getRequestData(
        ServerRequestInterface $request
    ): array {
        $body = (string) $request->getBody();

        $data = json_decode(
            $body,
            true,
            512,
            JSON_THROW_ON_ERROR
        );

        if (!is_array($data)) {
            throw new JsonException(
                'Request body must be a JSON object.'
            );
        }

        return $data;
    }

    /**
     * JSON Response भेजें।
     */
    private function jsonResponse(
        ResponseInterface $response,
        array $data,
        int $status = 200
    ): ResponseInterface {
        $response->getBody()->write(
            json_encode(
                $data,
                JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES
            )
        );

        return $response
            ->withStatus($status)
            ->withHeader('Content-Type', 'application/json');
    }

    /**
     * Error Response भेजें।
     */
    private function errorResponse(
        ResponseInterface $response,
        string $message,
        int $status
    ): ResponseInterface {
        return $this->jsonResponse(
            $response,
            [
                'success' => false,
                'error' => [
                    'message' => $message,
                ],
            ],
            $status
        );
    }
}
