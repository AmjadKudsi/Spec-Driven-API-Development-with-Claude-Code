# Split bloated T004 into two focused planning tasks.
# Create T004_COMMENT_SCHEMAS.md and T005_COMMENT_API.md, without writing implementation code.

Task ID: T005
Title: Implement comment HTTP endpoints with authentication
Files Modified:
  - src/api/comments.py
  - tests/integration/test_comment_api.py

Dependencies: T004

Estimated Time: 60 minutes

Acceptance Criteria:
[ ] POST /tasks/{task_id}/comments endpoint created
[ ] POST endpoint requires authentication
[ ] GET /tasks/{task_id}/comments endpoint created
[ ] DELETE /comments/{comment_id} endpoint created
[ ] DELETE endpoint verifies user owns comment
[ ] Integration tests for all three endpoints
[ ] Integration tests verify authorization checks

Notes: This task implements the HTTP API layer for comments. It builds on the schemas from T004 and handles authentication and authorization logic.
