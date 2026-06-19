# Split bloated T004 into two focused planning tasks.
# Create T004_COMMENT_SCHEMAS.md and T005_COMMENT_API.md, without writing implementation code.


Task ID: T004
Title: Implement comment validation schemas
Files Modified:
  - src/schemas/comment_schema.py
  - src/schemas/__init__.py
  - tests/unit/test_comment_schemas.py

Dependencies: T001, T002, T003

Estimated Time: 45 minutes

Acceptance Criteria:
[ ] CommentCreate schema with content validation
[ ] CommentResponse schema with all required fields
[ ] Schema exports added to src/schemas/__init__.py
[ ] Unit tests validate required fields are enforced
[ ] Unit tests validate content length constraints

Notes: This task implements the Pydantic validation layer for comments. It creates the data models that will be used by the API endpoints in T005.
