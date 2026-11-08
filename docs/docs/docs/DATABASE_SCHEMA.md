# HPC Smart AI – Database Schema

## 1. Database Overview

HPC Smart AI requires a secure, scalable, multi-tenant database.

The database must support Android, Web, Admin Dashboard, AI Chat, Documents, Website Intelligence and Code Auditing.

## 2. Users Table

Table: users

Fields:
- id
- name
- email
- phone
- password_hash
- account_status
- email_verified
- phone_verified
- created_at
- updated_at

Rules:
- Passwords must be securely hashed.
- Never store plain-text passwords.
- Private user data must be protected.

## 3. Businesses Table

Table: businesses

Fields:
- id
- owner_user_id
- business_name
- website_url
- business_status
- created_at
- updated_at

Rules:
- Each business must have an authorized owner.
- Business data must remain isolated.

## 4. Business Members Table

Table: business_members

Fields:
- id
- business_id
- user_id
- role
- permissions
- created_at

Roles:
- owner
- admin
- manager
- staff
- viewer

## 5. Workspaces Table

Table: workspaces

Fields:
- id
- business_id
- workspace_name
- workspace_type
- created_at
- updated_at

## 6. Authentication Tables

Table: login_otps

Fields:
- id
- user_id
- phone
- otp_hash
- expires_at
- verified_at
- attempts
- created_at

Security:
- Store OTP hashes, not plain OTP values.
- Apply expiration and attempt limits.
- Never expose OTPs in logs.

## 7. Documents Table

Table: documents

Fields:
- id
- business_id
- uploaded_by
- file_name
- file_type
- storage_path
- file_size
- processing_status
- created_at

Rules:
- Validate uploaded files.
- Restrict access by business and user permissions.
- Protect private documents.

## 8. Website Connections Table

Table: website_connections

Fields:
- id
- business_id
- website_url
- ownership_verified
- connection_status
- permission_scope
- last_scan_at
- created_at

Rules:
- Verify ownership before connection.
- Use restricted permissions.
- Never store unrestricted website credentials.

## 9. AI Conversations Table

Table: ai_conversations

Fields:
- id
- user_id
- business_id
- workspace_id
- title
- created_at
- updated_at

## 10. AI Messages Table

Table: ai_messages

Fields:
- id
- conversation_id
- role
- message_content
- source_references
- created_at

Rules:
- Enforce conversation ownership.
- Protect private messages.
- Do not expose another user's conversations.

## 11. Code Audit Reports Table

Table: code_audit_reports

Fields:
- id
- business_id
- website_connection_id
- requested_by
- audit_type
- severity
- file_path
- line_number
- issue_title
- issue_description
- proposed_fix
- confidence
- report_status
- created_at

## 12. Approved Changes Table

Table: approved_changes

Fields:
- id
- business_id
- audit_report_id
- approved_by
- approval_status
- backup_reference
- old_code_hash
- new_code_hash
- applied_at
- rollback_status
- created_at

Rules:
- No modification without explicit authorized approval.
- Preserve backups.
- Record every approved change.

## 13. Activity Logs Table

Table: activity_logs

Fields:
- id
- user_id
- business_id
- activity_type
- resource_type
- resource_id
- activity_status
- ip_address
- created_at

Never store passwords, OTPs, API keys or private tokens in logs.

## 14. Notifications Table

Table: notifications

Fields:
- id
- user_id
- business_id
- notification_type
- title
- message
- is_read
- created_at

## 15. API Keys Table

Table: api_keys

Fields:
- id
- business_id
- key_name
- encrypted_secret_reference
- permissions
- status
- expires_at
- created_at

Rules:
- Never expose API secrets.
- Use secure secret storage.
- Support revocation and expiration.

## 16. Database Security

- Use prepared statements.
- Enforce foreign key relationships.
- Apply role-based access control.
- Validate all user input.
- Encrypt sensitive information where appropriate.
- Use secure backups.
- Maintain audit logs.
- Enforce tenant isolation on every query.

## 17. Important Development Rule

This document defines the planned database structure only.

No production database should be created or modified until the schema is reviewed, approved and tested.

HPC Smart AI must remain READ-ONLY toward connected external websites and business systems by default.
