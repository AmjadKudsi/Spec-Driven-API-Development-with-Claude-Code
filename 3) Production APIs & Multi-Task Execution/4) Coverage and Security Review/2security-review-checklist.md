# Security Review Checklist: Task Comments API

## Authorization Checks

### Authentication Required
- [x] POST /tasks/{task_id}/comments - Requires `get_current_user`
- [x] GET /tasks/{task_id}/comments - Requires `get_current_user`
- [x] DELETE /comments/{comment_id} - Requires `get_current_user`

### Ownership Verification
- [x] POST checks task ownership (lines 19-21)
- [x] GET restricts to user's tasks (lines 38-40)
- [ ] **VULN:** DELETE missing ownership check (lines 53-55)

## Input Validation

### Content Validation
- [x] Service layer validates content (raises ValueError)
- [x] Empty content rejected via service (422 status)
- [ ] Whitespace-only content handling unclear

### ID Validation
- [x] UUID validation via FastAPI type system
- [x] task_id as int prevents injection
- [x] No raw SQL in API layer

### Error Handling
- [x] 422 for validation errors (line 27)
- [x] 404 for not found (line 61)
- [x] 403 for unauthorized access (lines 21, 40)

## Data Protection

### Access Control
- [x] POST/GET verify task ownership before access
- [ ] **VULN:** DELETE allows any user to delete any comment

### Information Disclosure
- [x] Error messages appropriate (no stack traces)
- [x] Returns generic "Not your task" message