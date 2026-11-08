# HPC Smart AI – API Specification

## 1. Overview

HPC Smart AI will provide secure REST APIs for Android, Web, Admin Dashboard and authorized business integrations.

Base API path:

/api/v1/

All production APIs must use HTTPS.

## 2. Authentication APIs

### POST /auth/register
Create a new user account.

Request:
- name
- email
- phone
- password

Response:
- user_id
- account_status
- verification_required

### POST /auth/login
Authenticate an existing user.

Request:
- email_or_phone
- password

Response:
- access_token
- refresh_token
- user_profile

### POST /auth/send-otp
Send an OTP for verification.

Request:
- phone

### POST /auth/verify-otp
Verify the OTP.

Request:
- phone
- otp

Security:
- OTP expiration
- Attempt limits
- Rate limiting
- Secure OTP storage

### POST /auth/logout
Revoke the current session.

## 3. User APIs

### GET /users/me
Return the authenticated user's profile.

### PATCH /users/me
Update permitted profile fields.

### DELETE /users/me
Request account deletion according to the retention policy.

## 4. Business APIs

### POST /businesses
Create a business workspace.

### GET /businesses
List businesses accessible to the authenticated user.

### GET /businesses/{business_id}
Return authorized business information.

### POST /businesses/{business_id}/members
Invite a business member.

### PATCH /businesses/{business_id}/members/{member_id}
Update permitted member roles and permissions.

Every request must verify business ownership or membership.

## 5. AI Chat APIs

### POST /ai/chat
Send a message to the AI Engine.

Request:
- conversation_id
- message
- business_id
- workspace_id

Response:
- answer
- conversation_id
- source_references
- response_status

Rules:
- Respect user permissions.
- Use authorized information only.
- Do not invent business facts.
- Clearly report unavailable information.
- Protect private conversation history.

## 6. Document APIs

### POST /documents/upload
Upload an authorized document.

### GET /documents
List accessible documents.

### GET /documents/{document_id}
Retrieve document metadata.

### POST /documents/{document_id}/analyze
Analyze an uploaded document.

### DELETE /documents/{document_id}
Delete an authorized document according to retention rules.

File validation, size limits and malware scanning are mandatory.

## 7. Website Intelligence APIs

### POST /websites/connect
Request a website connection.

### POST /websites/verify
Verify website ownership.

### GET /websites
List authorized website connections.

### POST /websites/{website_id}/scan
Start an authorized read-only website scan.

### GET /websites/{website_id}/reports
Retrieve website analysis reports.

Website scanning must respect ownership, permissions, robots policies and security restrictions.

## 8. Code Audit APIs

### POST /code-audits
Start an authorized code audit.

Request:
- website_id
- audit_scope
- technologies

### GET /code-audits
List accessible audit reports.

### GET /code-audits/{audit_id}
Retrieve an audit report.

### GET /code-audits/{audit_id}/issues
Retrieve detected issues.

Reports should include:
- File path
- Line number
- Severity
- Evidence
- Explanation
- Confidence
- Proposed correction

Untrusted code must never execute on production servers.

## 9. Admin APIs

### GET /admin/dashboard
Retrieve authorized dashboard statistics.

### GET /admin/users
List users according to Admin permissions.

### GET /admin/activity-logs
Retrieve permitted activity logs.

### GET /admin/security-reports
Retrieve security reports.

All Admin APIs require server-side role and permission verification.

## 10. Notifications APIs

### GET /notifications
List user notifications.

### PATCH /notifications/{notification_id}/read
Mark a notification as read.

## 11. API Security

- HTTPS required.
- Authentication required for private APIs.
- Role-based authorization.
- Business-level tenant isolation.
- Input validation.
- Rate limiting.
- Secure token management.
- Prepared database queries.
- Safe error responses.
- Audit logging.
- No secret keys in client applications.

## 12. Read-Only Policy

All connected website and business integrations must remain READ-ONLY by default.

AI may inspect, analyze, explain and recommend.

No external data modification is permitted without a separately authorized and explicitly approved workflow.

## 13. Approved Auto-Fix API

Any future Auto-Fix endpoint must:

- Require an authorized Admin.
- Reference one specific approved change.
- Create a backup first.
- Validate the proposed diff.
- Test safely where possible.
- Record the result.
- Support rollback.

## 14. API Versioning

Current planned version:

v1

Breaking changes must use a new API version.

## 15. Development Rule

This document describes the planned API contract.

Endpoints must be implemented, tested and secured before production release.
