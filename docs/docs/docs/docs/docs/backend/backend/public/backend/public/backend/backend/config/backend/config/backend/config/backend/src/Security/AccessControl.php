<?php

declare(strict_types=1);

namespace HPC\SmartAI\Security;

use PDO;
use RuntimeException;

final class AccessControl
{
    private function __construct()
    {
    }

    /**
     * Check whether a user can access a business.
     */
    public static function canAccessBusiness(
        PDO $database,
        int $userId,
        int $businessId
    ): bool {

        if ($userId <= 0 || $businessId <= 0) {
            return false;
        }

        $sql = "
            SELECT id
            FROM businesses
            WHERE id = :business_id
              AND owner_user_id = :user_id

            UNION

            SELECT bm.id
            FROM business_members bm
            INNER JOIN businesses b
                ON b.id = bm.business_id
            WHERE bm.business_id = :member_business_id
              AND bm.user_id = :member_user_id
        ";

        $statement = $database->prepare($sql);

        $statement->execute([
            'business_id' => $businessId,
            'user_id' => $userId,
            'member_business_id' => $businessId,
            'member_user_id' => $userId,
        ]);

        return $statement->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Require authorized business access.
     */
    public static function requireBusinessAccess(
        PDO $database,
        int $userId,
        int $businessId
    ): void {

        if (!self::canAccessBusiness(
            $database,
            $userId,
            $businessId
        )) {
            throw new RuntimeException(
                'Access denied: unauthorized business access.'
            );
        }
    }

    /**
     * Check membership role.
     */
    public static function hasRole(
        PDO $database,
        int $userId,
        int $businessId,
        array $allowedRoles
    ): bool {

        if (
            $userId <= 0 ||
            $businessId <= 0 ||
            empty($allowedRoles)
        ) {
            return false;
        }

        self::requireBusinessAccess(
            $database,
            $userId,
            $businessId
        );

        $placeholders = implode(
            ',',
            array_fill(0, count($allowedRoles), '?')
        );

        $sql = "
            SELECT role
            FROM business_members
            WHERE user_id = ?
              AND business_id = ?
              AND role IN ($placeholders)
            LIMIT 1
        ";

        $statement = $database->prepare($sql);

        $statement->execute(array_merge(
            [$userId, $businessId],
            $allowedRoles
        ));

        return $statement->fetch(PDO::FETCH_ASSOC) !== false;
    }
}
