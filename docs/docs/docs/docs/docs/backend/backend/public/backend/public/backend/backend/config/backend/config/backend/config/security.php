<?php

declare(strict_types=1);

return [

    /*
    |--------------------------------------------------------------------------
    | HPC Smart AI Security Policy
    |--------------------------------------------------------------------------
    */

    'default_mode' => 'READ_ONLY',

    'allow_external_modifications' => false,

    'require_explicit_admin_approval' => true,

    /*
    |--------------------------------------------------------------------------
    | Authentication
    |--------------------------------------------------------------------------
    */

    'authentication' => [
        'require_login_for_private_data' => true,
        'password_min_length' => 12,
        'max_login_attempts' => 5,
        'lockout_minutes' => 15,
        'require_verified_email' => false,
        'require_verified_phone' => false,
    ],

    /*
    |--------------------------------------------------------------------------
    | Session Security
    |--------------------------------------------------------------------------
    */

    'session' => [
        'secure_cookie' => true,
        'http_only' => true,
        'same_site' => 'Lax',
        'regenerate_after_login' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Role-Based Access Control
    |--------------------------------------------------------------------------
    */

    'roles' => [
        'super_admin',
        'business_owner',
        'admin',
        'manager',
        'staff',
        'customer',
        'viewer',
    ],

    /*
    |--------------------------------------------------------------------------
    | Tenant Isolation
    |--------------------------------------------------------------------------
    */

    'tenant_isolation' => [
        'enabled' => true,
        'require_business_membership' => true,
        'deny_cross_business_access' => true,
        'verify_permissions_on_every_request' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | API Protection
    |--------------------------------------------------------------------------
    */

    'api' => [
        'require_https' => true,
        'rate_limit_enabled' => true,
        'reject_invalid_tokens' => true,
        'validate_all_input' => true,
        'hide_internal_errors' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Document Protection
    |--------------------------------------------------------------------------
    */

    'documents' => [
        'validate_file_type' => true,
        'validate_file_size' => true,
        'require_authorization' => true,
        'scan_before_processing' => true,
        'prevent_public_private_files' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Website Connection Protection
    |--------------------------------------------------------------------------
    */

    'website' => [
        'require_ownership_verification' => true,
        'default_permission' => 'READ_ONLY',
        'block_unauthorized_scanning' => true,
        'block_private_network_targets' => true,
        'respect_robots_policy' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Code Audit Protection
    |--------------------------------------------------------------------------
    */

    'code_audit' => [
        'enabled' => true,
        'default_mode' => 'ANALYSIS_ONLY',
        'execute_untrusted_code' => false,
        'production_execution' => false,
        'require_isolated_environment' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Auto-Fix Protection
    |--------------------------------------------------------------------------
    */

    'auto_fix' => [
        'enabled' => false,
        'require_admin_approval' => true,
        'require_backup' => true,
        'require_code_diff' => true,
        'require_scope_validation' => true,
        'require_post_change_testing' => true,
        'require_rollback_support' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Secrets and Logging
    |--------------------------------------------------------------------------
    */

    'secrets' => [
        'never_expose_api_keys' => true,
        'never_log_passwords' => true,
        'never_log_otps' => true,
        'never_log_private_tokens' => true,
    ],

    'audit_logs' => [
        'enabled' => true,
        'record_login_events' => true,
        'record_permission_changes' => true,
        'record_website_connections' => true,
        'record_admin_approvals' => true,
    ],

];
