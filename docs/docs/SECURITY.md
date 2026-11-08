# HPC Smart AI – Security Policy

## 1. Authentication
- Secure user registration and login.
- Passwords must be securely hashed.
- OTP verification must be protected.
- Sessions must use secure settings.

## 2. User Permissions
- Separate Admin and Customer roles.
- Users can access only their authorized data.
- Admin permissions must be checked by the backend.
- Unauthorized access must be blocked.

## 3. Business Data Isolation
- Every business must have a separate workspace.
- One business must never access another business's private data.
- All API requests must verify user permissions.

## 4. AI Read-Only Protection
- Default AI mode is READ-ONLY.
- AI may read and analyze authorized information.
- AI may explain and suggest improvements.
- AI must not silently change any data or files.

## 5. Website Connection
- Verify website ownership before connecting.
- Use restricted API permissions.
- Never expose database passwords or secret keys.
- Do not allow unauthorized website access.

## 6. Document Security
- Validate uploaded file types and sizes.
- Scan files before processing.
- Protect private documents.
- Allow access only to authorized users.

## 7. Code Audit Security
- Analyze code in an isolated environment.
- Never execute untrusted code on production servers.
- Report security issues with evidence.
- Keep audit reports private.

## 8. Admin Approved Changes
Any future Auto-Fix must require:
- Explicit Admin approval of a specific change.
- Backup before modification.
- Old and new code comparison.
- Scope verification.
- Testing and rollback support.

## 9. Audit Logs
Record important security events:
- Login attempts
- Permission changes
- Website connections
- Document access
- Code audit activities
- Approved modifications

Never log passwords, OTPs, API keys or private tokens.

## 10. Security Principle
Security, privacy and user control are mandatory throughout HPC Smart AI.
