# Security Review Report: Task Comments API

**Date:** 2026-07-12
**Reviewer:** Claude Code
**Module:** Comment API endpoints

## Issues Found

### HIGH Priority

**Issue:** Missing Authorization Check (IDOR - Insecure Direct Object Reference)
**Location:** src/api/comments.py:46-61 (delete_comment endpoint)
**Severity:** HIGH

**Description:**
The `delete_comment` endpoint was missing authorization checks to verify that the requesting user has permission to delete the comment. The endpoint only verified authentication (user is logged in) but did not check if the user owns the comment or owns the task containing the comment. This allowed any authenticated user to delete any comment if they knew the comment ID.

**Impact:**
- Any authenticated user could delete ANY comment in the system
- Attackers could enumerate comment IDs and systematically delete all comments
- Data loss and disruption of service for legitimate users
- Violation of authorization boundaries between users
- Loss of audit trail and comment history

**Original Code:**
```python
@router.delete("/comments/{comment_id}")
def delete_comment(
    comment_id: UUID,
    current_user: User = Depends(get_current_user),
    service: CommentService = Depends()
):
    """Delete a comment."""
    # TODO: SECURITY ISSUE - Missing authorization check!
    # TODO: Should verify user owns comment OR owns task
    # TODO: Add ownership check before allowing deletion

    try:
        service.delete_comment(comment_id, current_user.id)
        return {"status": "deleted"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
```

**Fix Applied:**
```python
@router.delete("/comments/{comment_id}")
def delete_comment(
    comment_id: UUID,
    current_user: User = Depends(get_current_user),
    service: CommentService = Depends()
):
    """Delete a comment."""
    # Get comment to verify authorization
    comment = service.get_comment(comment_id)
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")

    # Get task to check task ownership
    task = get_task(comment.task_id)

    # Authorization: User must own comment OR own task
    if comment.user_id != current_user.id and task.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this comment")

    try:
        service.delete_comment(comment_id, current_user.id)
        return {"status": "deleted"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
```

**Verification:**
Created and executed comprehensive unit tests (tests/test_comments_auth_unit.py):
- ✅ test_comment_owner_can_delete - PASSED
- ✅ test_task_owner_can_delete_comment_on_their_task - PASSED
- ✅ test_unauthorized_user_cannot_delete_comment - PASSED (403 returned)
- ✅ test_nonexistent_comment_returns_404 - PASSED
- ✅ test_authorization_logic_precedence - PASSED

All 5 test scenarios passed, confirming the authorization logic correctly enforces access control.

## Items Passed

### Authorization
- [x] All endpoints require authentication via get_current_user
- [x] POST /tasks/{task_id}/comments checks task ownership
- [x] GET /tasks/{task_id}/comments restricts to user's tasks
- [x] DELETE /comments/{comment_id} now checks comment OR task ownership

### Input Validation
- [x] Content validation handled by service layer (raises ValueError)
- [x] SQL injection protected via FastAPI type system (UUID, int)
- [x] No raw SQL in API layer
- [x] Empty content rejected with 422 status

### Data Protection
- [x] Error messages don't leak sensitive information
- [x] 404 returned for non-existent resources
- [x] 403 returned for unauthorized access attempts
- [x] Access controls verified to work correctly

## Summary

**Issues Found:** 1
**Issues Fixed:** 1
**Status:** PASSED

The security review identified a critical IDOR vulnerability in the comment deletion endpoint that allowed unauthorized users to delete any comment. The vulnerability was fixed by adding proper authorization checks that verify the requesting user either owns the comment OR owns the task containing the comment.

The fix was verified through comprehensive unit testing covering all authorization scenarios. All other endpoints (POST and GET) were found to have proper authorization checks already in place. Input validation and error handling across all endpoints follow security best practices with no information disclosure vulnerabilities detected.