# Specification: Task Comments

**Version:** 1.0  
**Status:** Approved  
**Source PRD:** docs/prds/task-comments-v1.0.md  
**Implementation Date:** 2024-01-12

---

## Purpose

Enable users to add, view, and delete text comments on tasks, providing in-app communication and maintaining task discussion history.

---

## API Contract

### POST /api/tasks/{task_id}/comments

Create new comment on task.

**Authentication:** Required (JWT Bearer token)

**Path Parameters:**
- `task_id`: UUID - Task to comment on

**Request Body:**
"""json
{
  "content": "string"
}
"""

**Request Validation:**
- `content`: Required, string, 1-5000 characters
- `content`: Cannot be only whitespace (trim then check not empty)

**Success Response (201 Created):**
"""json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "task_id": "123e4567-e89b-12d3-a456-426614174000",
  "author_id": "789e0123-e89b-12d3-a456-426614174000",
  "author_name": "John Doe",
  "content": "This looks good!",
  "created_at": "2024-01-12T10:30:00Z",
  "updated_at": "2024-01-12T10:30:00Z"
}
"""

**Error Responses:**

**400 Bad Request** - Validation failure
"""json
{
  "detail": "Content is required and cannot be empty"
}
"""

**400 Bad Request** - Content too long
"""json
{
  "detail": "Content must not exceed 5000 characters"
}
"""

**401 Unauthorized** - Not authenticated
"""json
{
  "detail": "Authentication required"
}
"""

**403 Forbidden** - No access to task
"""json
{
  "detail": "Not authorized to access this task"
}
"""

**404 Not Found** - Task doesn't exist
"""json
{
  "detail": "Task not found"
}
"""

---

### GET /api/tasks/{task_id}/comments

List all comments on task in chronological order.

**Authentication:** Required

**Path Parameters:**
- `task_id`: UUID - Task to get comments for

**Query Parameters:** None (all comments returned, no pagination in v1.0)

**Success Response (200 OK):**
"""json
{
  "comments": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "task_id": "123e4567-e89b-12d3-a456-426614174000",
      "author_id": "789e0123-e89b-12d3-a456-426614174000",
      "author_name": "John Doe",
      "content": "Started working on this",
      "created_at": "2024-01-12T09:00:00Z",
      "updated_at": "2024-01-12T09:00:00Z"
    },
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "task_id": "123e4567-e89b-12d3-a456-426614174000",
      "author_id": "890e0123-e89b-12d3-a456-426614174001",
      "author_name": "Jane Smith",
      "content": "Looks good!",
      "created_at": "2024-01-12T10:30:00Z",
      "updated_at": "2024-01-12T10:30:00Z"
    }
  ],
  "total": 2
}
"""

**Order:** Chronological (oldest first, created_at ASC)

**Error Responses:**

**401 Unauthorized** - Not authenticated
"""json
{
  "detail": "Authentication required"
}
"""

**403 Forbidden** - No access to task
"""json
{
  "detail": "Not authorized to access this task"
}
"""

**404 Not Found** - Task doesn't exist
"""json
{
  "detail": "Task not found"
}
"""

---

### DELETE /api/comments/{comment_id}

Delete comment (author only).

**Authentication:** Required

**Path Parameters:**
- `comment_id`: UUID - Comment to delete

**Success Response (204 No Content)**
No response body.

**Error Responses:**

**401 Unauthorized** - Not authenticated
"""json
{
  "detail": "Authentication required"
}
"""

**403 Forbidden** - Not comment author
"""json
{
  "detail": "Only comment author can delete comments"
}
"""

**404 Not Found** - Comment doesn't exist
"""json
{
  "detail": "Comment not found"
}
"""

---

## Data Model

### Comment Model

**Table:** `comments`

**Fields:**
- `id`: UUID, Primary Key, Default: uuid.uuid4()
- `task_id`: UUID, Foreign Key → tasks(id), NOT NULL, ON DELETE CASCADE
- `user_id`: UUID, Foreign Key → users(id), NOT NULL, ON DELETE CASCADE  
- `content`: TEXT, NOT NULL
- `created_at`: TIMESTAMP WITH TIME ZONE, NOT NULL, Default: NOW()
- `updated_at`: TIMESTAMP WITH TIME ZONE, NOT NULL, Default: NOW(), ON UPDATE: NOW()

**Relationships:**
- `task`: relationship("Task", back_populates="comments")
- `author`: relationship("User")

**Indexes:**
- `idx_comments_task_id` ON task_id (for listing comments by task)
- `idx_comments_user_id` ON user_id (for finding user's comments)
- `idx_comments_created_at` ON created_at (for chronological ordering)

**SQLAlchemy Model:**
"""python
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid

class Comment(Base):
    __tablename__ = "comments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    
    # Relationships
    task = relationship("Task", back_populates="comments")
    author = relationship("User")
"""

**Update Task Model:**
Add to `src/models/task.py`:
"""python
comments = relationship("Comment", back_populates="task", cascade="all, delete-orphan")
"""

---

## Validation Rules

### Content Validation
1. **Required:** Content field must be present in request
2. **Not Empty:** After trimming whitespace, content must have length ≥1
3. **Length:** Content must be 1-5000 characters (after trimming)
4. **Type:** Content must be string (not null, not number)

**Validation Order:**
1. Check field exists → 400 "Content is required"
2. Trim whitespace
3. Check not empty after trim → 400 "Content cannot be empty"
4. Check length ≤5000 → 400 "Content must not exceed 5000 characters"

**Examples:**

| Input | Validation Result |
|-------|-------------------|
| `{"content": "Hello"}` | ✅ Valid (5 chars) |
| `{"content": "  Hello  "}` | ✅ Valid (trimmed to "Hello") |
| `{"content": ""}` | ❌ Empty |
| `{"content": "   "}` | ❌ Only whitespace (empty after trim) |
| `{"content": "A" * 5001}` | ❌ Too long |
| `{}` | ❌ Field missing |

---

## Authorization Rules

### Add Comment (POST)
- User must be authenticated (JWT valid)
- User must have access to task:
  - User is task owner (task.owner_id == current_user.id), OR
  - User is task team member (future: when teams implemented)
- If user doesn't own task → 403 Forbidden

### View Comments (GET)
- User must be authenticated
- User must have access to task (same rules as add)
- If user doesn't have access → 403 Forbidden

### Delete Comment (DELETE)
- User must be authenticated
- User must be comment author (comment.user_id == current_user.id)
- If user is not author → 403 Forbidden

**Authorization Check Order:**
1. Verify JWT valid → 401 if invalid
2. Verify resource exists (task/comment) → 404 if not found
3. Verify user has permission → 403 if not authorized

---

## Edge Cases

### Edge Case 1: Delete Comment on Deleted Task
**Scenario:** Task is deleted while comment deletion request in flight  
**Behavior:** ON DELETE CASCADE removes comments automatically  
**Response:** 404 Not Found ("Comment not found")

### Edge Case 2: Empty Comments List
**Scenario:** GET comments on task with no comments  
**Behavior:** Return empty array  
**Response:** `{"comments": [], "total": 0}`

### Edge Case 3: Concurrent Comment Creation
**Scenario:** Two users add comments to same task simultaneously  
**Behavior:** Both succeed, database handles concurrency  
**Result:** Two comments with different created_at timestamps

### Edge Case 4: Very Long Comment
**Scenario:** User submits 5001-character comment  
**Behavior:** Validation rejects  
**Response:** 400 "Content must not exceed 5000 characters"

### Edge Case 5: Comment on Non-Existent Task
**Scenario:** POST /api/tasks/{invalid-uuid}/comments  
**Behavior:** Task lookup fails  
**Response:** 404 "Task not found"

---

## Error Handling

### Validation Errors (400 Bad Request)
**Trigger:** Invalid request data  
**Response:** `{"detail": "<specific validation message>"}`  
**Examples:**
- Missing content → "Content is required and cannot be empty"
- Content too long → "Content must not exceed 5000 characters"
- Invalid JSON → "Invalid JSON in request body"

### Authentication Errors (401 Unauthorized)
**Trigger:** Missing or invalid JWT token  
**Response:** `{"detail": "Authentication required"}`  
**HTTP Header:** `WWW-Authenticate: Bearer`

### Authorization Errors (403 Forbidden)
**Trigger:** Valid auth but insufficient permissions  
**Response:** `{"detail": "<specific permission message>"}`  
**Examples:**
- Not task owner → "Not authorized to access this task"
- Not comment author → "Only comment author can delete comments"

### Not Found Errors (404 Not Found)
**Trigger:** Resource doesn't exist  
**Response:** `{"detail": "<resource> not found"}`  
**Examples:**
- Invalid task_id → "Task not found"
- Invalid comment_id → "Comment not found"

### Server Errors (500 Internal Server Error)
**Trigger:** Unexpected server failure  
**Response:** `{"detail": "Internal server error"}`  
**Logging:** Full stack trace logged to Sentry  
**User Message:** Generic (no implementation details exposed)

---

## Examples

### Example 1: Create Comment (Success)

**Request:**
"""http
POST /api/tasks/123e4567-e89b-12d3-a456-426614174000/comments HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "content": "Started working on this task. Should be done by EOD."
}
"""

**Response:**
"""http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "task_id": "123e4567-e89b-12d3-a456-426614174000",
  "author_id": "789e0123-e89b-12d3-a456-426614174000",
  "author_name": "John Doe",
  "content": "Started working on this task. Should be done by EOD.",
  "created_at": "2024-01-12T10:30:00Z",
  "updated_at": "2024-01-12T10:30:00Z"
}
"""

---

### Example 2: Create Comment (Validation Error)

**Request:**
"""http
POST /api/tasks/123e4567-e89b-12d3-a456-426614174000/comments HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "content": "   "
}
"""

**Response:**
"""http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "detail": "Content cannot be empty"
}
"""

---

### Example 3: List Comments

**Request:**
"""http
GET /api/tasks/123e4567-e89b-12d3-a456-426614174000/comments HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
"""

**Response:**
"""http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "comments": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "task_id": "123e4567-e89b-12d3-a456-426614174000",
      "author_id": "789e0123-e89b-12d3-a456-426614174000",
      "author_name": "John Doe",
      "content": "Started working on this",
      "created_at": "2024-01-12T09:00:00Z",
      "updated_at": "2024-01-12T09:00:00Z"
    },
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "task_id": "123e4567-e89b-12d3-a456-426614174000",
      "author_id": "890e0123-e89b-12d3-a456-426614174001",
      "author_name": "Jane Smith",
      "content": "Looks good! Let me know if you need help.",
      "created_at": "2024-01-12T10:30:00Z",
      "updated_at": "2024-01-12T10:30:00Z"
    }
  ],
  "total": 2
}
"""

---

### Example 4: Delete Comment (Success)

**Request:**
"""http
DELETE /api/comments/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
"""

**Response:**
"""http
HTTP/1.1 204 No Content
"""

---

### Example 5: Delete Comment (Authorization Error)

**Request:**
"""http
DELETE /api/comments/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Authorization: Bearer <different-user-token>
"""

**Response:**
"""http
HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "detail": "Only comment author can delete comments"
}
"""

---

## Implementation Notes

### Repository Pattern
Follow `src/repositories/task_repository.py` as example.

**CommentRepository methods:**
- `create(task_id, user_id, content) -> Comment`
- `get_by_id(comment_id) -> Optional[Comment]`
- `get_task_comments(task_id) -> List[Comment]`
- `delete(comment_id) -> bool`

**Dependency injection:**
"""python
class CommentRepository:
    def __init__(self, db: Session = Depends(get_db)):
        self.db = db
"""

### Authentication
Use existing pattern from `src/api/tasks.py`:
"""python
from src.services.auth import get_current_user

@router.post("/api/tasks/{task_id}/comments")
def create_comment(
    task_id: UUID,
    data: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    ...
"""

### Pydantic Schemas
**CommentCreate** (request):
"""python
from pydantic import BaseModel, Field, validator

class CommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000)
    
    @validator('content')
    def content_not_empty(cls, v):
        if not v.strip():
            raise ValueError('Content cannot be empty')
        return v.strip()
"""

**CommentSchema** (response):
"""python
from pydantic import BaseModel
from datetime import datetime
from uuid import UUID

class CommentSchema(BaseModel):
    id: UUID
    task_id: UUID
    author_id: UUID
    author_name: str
    content: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True
"""

---

## Testing Requirements

### Unit Tests (CommentRepository)
- `test_create_comment_success` - Verify comment created with correct fields
- `test_get_comment_by_id_exists` - Fetch existing comment returns it
- `test_get_comment_by_id_not_exists` - Non-existent ID returns None
- `test_get_task_comments_empty` - Task with no comments returns empty list
- `test_get_task_comments_multiple` - Returns comments in chronological order
- `test_delete_comment_success` - Comment deletion returns True
- `test_delete_comment_not_exists` - Non-existent comment returns False

**Coverage Target:** 95%+ for repository

### Integration Tests (API Endpoints)
- `test_create_comment_success_201` - Valid request returns 201 with comment
- `test_create_comment_empty_content_400` - Empty content returns 400
- `test_create_comment_too_long_400` - 5001 chars returns 400
- `test_create_comment_unauthorized_401` - No token returns 401
- `test_create_comment_not_owner_403` - Non-owner returns 403
- `test_create_comment_task_not_found_404` - Invalid task returns 404
- `test_list_comments_success_200` - Returns comments chronologically
- `test_list_comments_empty_200` - Empty list when no comments
- `test_list_comments_unauthorized_401` - No token returns 401
- `test_delete_comment_success_204` - Author deletion returns 204
- `test_delete_comment_not_author_403` - Non-author returns 403
- `test_delete_comment_not_found_404` - Invalid ID returns 404

**Coverage Target:** 90%+ for API

### Performance Tests
- Verify <200ms for listing 100 comments
- Verify <100ms for creating comment
- Load test with 1000 comments per task

**Performance Target:** p95 latency within limits

---

## Migration Script

**File:** `alembic/versions/YYYY_MM_DD_HHMM_add_comments.py`

**Up Migration:**
"""python
def upgrade():
    op.create_table(
        'comments',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('task_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['task_id'], ['tasks.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('idx_comments_task_id', 'comments', ['task_id'])
    op.create_index('idx_comments_user_id', 'comments', ['user_id'])
    op.create_index('idx_comments_created_at', 'comments', ['created_at'])

def downgrade():
    op.drop_index('idx_comments_created_at')
    op.drop_index('idx_comments_user_id')
    op.drop_index('idx_comments_task_id')
    op.drop_table('comments')
"""

**Test Migration:**
"""bash
# Run migration
alembic upgrade head

# Verify table exists
psql -d taskmaster -c "\d comments"

# Test rollback
alembic downgrade -1

# Verify table dropped
psql -d taskmaster -c "\d comments"
"""