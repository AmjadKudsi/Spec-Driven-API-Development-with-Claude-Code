# Create technical_plan.md for Task Attachments using the required 7 sections.
# Use Claude Code to inspect existing TaskMaster patterns, fill the plan, then verify completeness.

# Technical Plan: Task Attachments Feature

## 1. Architecture (Component Interactions)

### Request Flow
```
Client → API Router → Service Layer → Repository Layer → Database
                    ↓
                  S3Service → AWS S3
```

### Components and Responsibilities

**AttachmentRouter** (`src/api/attachments.py`)
- Handle HTTP requests for upload, list, download, delete
- Validate user authentication via `get_current_user` dependency
- Parse multipart form data for file uploads
- Return appropriate HTTP responses and error codes

**AttachmentService** (`src/services/attachment_service.py`)
- Validate file size and MIME type
- Authorize user access (verify task ownership)
- Coordinate upload: S3 upload → database save
- Generate presigned URLs for downloads
- Handle deletion: database delete → S3 cleanup
- Owns transaction management: commit on success, rollback on failure
- Owns S3 cleanup on transaction failures
- Method signatures:
  - `__init__(self, repository: AttachmentRepository, s3_service: S3Service, db: Session)`
  - `upload(task_id: UUID, file: UploadFile, current_user: User) -> Attachment`
  - `list_by_task(task_id: UUID, current_user: User) -> List[Attachment]`
  - `get_download_url(attachment_id: UUID, current_user: User) -> dict`
  - `delete(attachment_id: UUID, current_user: User) -> bool`

**AttachmentRepository** (`src/repositories/attachment_repository.py`)
- CRUD operations for Attachment model
- Query attachments by task_id
- Does NOT commit or rollback (Service layer handles transactions)
- Method signatures:
  - `__init__(self, db: Session)` - Store db session as self.db
  - `create(attachment_data: dict) -> Attachment` - Adds to session, does NOT commit
  - `get_by_id(attachment_id: UUID) -> Optional[Attachment]` - Query only
  - `list_by_task(task_id: UUID) -> List[Attachment]` - Query only
  - `delete(attachment_id: UUID) -> bool` - Marks for deletion, does NOT commit

**S3Service** (`src/services/s3_service.py`)
- Upload files to S3 with unique keys
- Delete files from S3
- Generate presigned download URLs
- Handle S3 client exceptions
- Method signatures:
  - `__init__(self)` - Initialize boto3 client from settings
  - `upload_file(file_content: bytes, s3_key: str) -> str` (returns s3_key)
  - `delete_file(s3_key: str) -> bool`
  - `generate_presigned_url(s3_key: str, expiration: int = 3600) -> str` (returns URL)

**Dependency Factory** (`src/services/attachment_service.py`)
- Function to wire dependencies with single DB session per request
- Signature:
  - `get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService`
- Implementation:
  ```python
  def get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService:
      repository = AttachmentRepository(db)
      s3_service = S3Service()
      return AttachmentService(repository, s3_service, db)
  ```

### Upload Data Flow
1. Client sends multipart/form-data to POST `/api/tasks/{task_id}/attachments`
2. Router extracts file, calls service with current_user
3. Service validates file size/type and verifies task ownership using db session
4. Service calls S3Service to upload file → receives S3 key
5. Service calls Repository to add attachment metadata to db session
6. Service commits transaction (db.commit())
7. On success: Service returns attachment metadata to router
8. On failure: Service rolls back db and deletes S3 file
9. Router returns 201 Created with attachment details

### Rollback Strategy (Service Layer Responsibility)
- **If S3 upload fails**: Raise exception, no database changes made, return 500 error
- **If database commit fails after S3 upload**: Service calls db.rollback(), then calls s3_service.delete_file(s3_key), return 500 error
- **If presigned URL generation fails**: Return 500 error, log issue
- Service wraps all operations in try/except:
  ```python
  try:
      # Upload to S3
      s3_key = self.s3_service.upload_file(...)
      # Save to database
      attachment = self.repository.create(...)
      self.db.commit()
      return attachment
  except Exception:
      self.db.rollback()
      if s3_key:
          self.s3_service.delete_file(s3_key)
      raise
  ```

---

## 2. Data Model (Database Schema)

### Attachment Table

```python
# src/models/attachment.py
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
from ..database import Base

class Attachment(Base):
    __tablename__ = "attachments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    uploader_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    filename = Column(String(255), nullable=False)
    file_size = Column(Integer, nullable=False)  # bytes
    mime_type = Column(String(127), nullable=False)
    s3_key = Column(String(512), nullable=False, unique=True)
    s3_bucket = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    task = relationship("Task", back_populates="attachments")
    uploader = relationship("User")
```

### Updates to Existing Models

**Task Model** (`src/models/task.py`) - Add relationship after line 33 (after `comments` relationship):
```python
attachments = relationship("Attachment", back_populates="task", cascade="all, delete-orphan")
```

**Location**: Insert in Task class definition, after the existing relationships.

### Indexes
- `task_id`: For efficient querying attachments by task (created via ForeignKey index=True)
- `s3_key`: Unique constraint to prevent duplicate S3 keys

### Constraints
- `task_id`: NOT NULL, CASCADE delete when task deleted
- `uploader_id`: NOT NULL
- `filename`: NOT NULL, max 255 chars
- `file_size`: NOT NULL, positive integer
- `mime_type`: NOT NULL, max 127 chars
- `s3_key`: NOT NULL, unique, max 512 chars
- `s3_bucket`: NOT NULL, max 255 chars

---

## 3. Storage Strategy (S3 Organization)

### Bucket Structure
- **Bucket name**: `taskmaster-attachments` (configurable via settings)
- **Region**: us-east-1 (configurable via settings)
- **Lifecycle policy**: None for MVP (future: archive after 90 days)

### S3 Key Format
```
attachments/{task_id}/{attachment_id}/{sanitized_filename}
```

**Example:**
```
attachments/550e8400-e29b-41d4-a716-446655440000/7c9e6679-7425-40de-944b-e07fc1f90ae7/project_diagram.png
```

### Rationale
- **Task grouping**: All attachments for a task under same prefix enables efficient listing and cleanup
- **Unique attachment_id**: Prevents filename collisions, enables atomic operations
- **Original filename**: Preserves user-friendly names while ensuring uniqueness
- **Flat hierarchy**: Simple structure, scales well, no deep nesting issues

### S3 Configuration Requirements

Add to `src/config.py`:
```python
s3_bucket_name: str = "taskmaster-attachments"
s3_region: str = "us-east-1"
aws_access_key_id: str = ""
aws_secret_access_key: str = ""
```

Environment variables: `S3_BUCKET_NAME`, `S3_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### Bucket Permissions
- Service account needs: `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`
- Presigned URLs require: `s3:GetObject` permission on bucket

---

## 4. Validation Rules

### Allowed MIME Types
```python
ALLOWED_MIME_TYPES = {
    # Images
    "image/png", "image/jpeg", "image/jpg", "image/gif", "image/webp",
    # Documents
    "application/pdf",
    "text/plain",
    "application/msword",  # .doc
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",  # .docx
    "application/vnd.ms-excel",  # .xls
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",  # .xlsx
    # Archives
    "application/zip",
    "application/x-tar",
    "application/gzip"
}
```

### File Size Limit
- **Maximum**: 10 MB (10,485,760 bytes)
- **Validation**: Check before S3 upload to avoid wasted bandwidth
- **Error**: 413 Payload Too Large if exceeded

### Filename Validation
- **Maximum length**: 255 characters
- **Sanitization**: Remove path traversal characters (`../`, `..\\`)
- **Allowed characters**: alphanumeric, hyphens, underscores, periods, spaces
- **Reject**: Null bytes, control characters

### Virus Scanning
- **MVP implementation**: No virus scanning code required
- **Rationale**: Reduces initial complexity; MIME type validation provides basic protection
- **Implementation**: Simply do not include virus scanning logic in upload flow
- **Future enhancement**: Integrate AWS S3 bucket scanning (Amazon GuardDuty) or ClamAV

### Error Message Formats

Following CLAUDE.md pattern for clear, actionable messages:

```python
# File too large
"File size 15.2MB exceeds maximum allowed size of 10MB"

# Invalid MIME type
"File type 'application/exe' not allowed. Allowed types: images, PDFs, documents, archives"

# Task not found
"Task {task_id} not found"

# Not authorized
"Not authorized to upload attachments to this task"

# Attachment not found
"Attachment {attachment_id} not found"

# S3 upload failure
"Failed to upload file to storage. Please try again"
```

---

## 5. API Contracts (Endpoints)

### POST /api/tasks/{task_id}/attachments
Upload attachment to task.

**Authentication**: Required (Bearer token)

**Authorization**: User must be task owner

**Request**: multipart/form-data
```
POST /api/tasks/550e8400-e29b-41d4-a716-446655440000/attachments
Authorization: Bearer <token>
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="project_diagram.png"
Content-Type: image/png

<binary file data>
------WebKitFormBoundary--
```

**Field name**: `file` (required)

**Response 201 Created:**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "task_id": "550e8400-e29b-41d4-a716-446655440000",
  "filename": "project_diagram.png",
  "file_size": 245760,
  "mime_type": "image/png",
  "uploader_id": "123e4567-e89b-12d3-a456-426614174000",
  "created_at": "2024-01-20T15:30:00Z"
}
```

**Error Responses:**

`400 Bad Request` - No file provided:
```json
{"detail": "No file provided in request"}
```

`401 Unauthorized` - Missing or invalid token:
```json
{"detail": "Could not validate credentials"}
```

`403 Forbidden` - Not task owner:
```json
{"detail": "Not authorized to upload attachments to this task"}
```

`404 Not Found` - Task not found:
```json
{"detail": "Task 550e8400-e29b-41d4-a716-446655440000 not found"}
```

`413 Payload Too Large` - File exceeds limit:
```json
{"detail": "File size 15.2MB exceeds maximum allowed size of 10MB"}
```

`415 Unsupported Media Type` - Invalid MIME type:
```json
{"detail": "File type 'application/exe' not allowed. Allowed types: images, PDFs, documents, archives"}
```

`500 Internal Server Error` - S3 or database failure:
```json
{"detail": "Failed to upload file to storage. Please try again"}
```

---

### GET /api/tasks/{task_id}/attachments
List all attachments for a task.

**Authentication**: Required

**Authorization**: User must be task owner

**Response 200 OK:**
```json
{
  "attachments": [
    {
      "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "task_id": "550e8400-e29b-41d4-a716-446655440000",
      "filename": "project_diagram.png",
      "file_size": 245760,
      "mime_type": "image/png",
      "uploader_id": "123e4567-e89b-12d3-a456-426614174000",
      "created_at": "2024-01-20T15:30:00Z"
    }
  ],
  "total": 1
}
```

**Error Responses:**

`401 Unauthorized`:
```json
{"detail": "Could not validate credentials"}
```

`403 Forbidden`:
```json
{"detail": "Not authorized to access this task"}
```

`404 Not Found`:
```json
{"detail": "Task 550e8400-e29b-41d4-a716-446655440000 not found"}
```

---

### GET /api/attachments/{attachment_id}/download
Get presigned URL for downloading attachment.

**Authentication**: Required

**Authorization**: User must be owner of task that attachment belongs to

**Response 200 OK:**
```json
{
  "download_url": "https://taskmaster-attachments.s3.amazonaws.com/attachments/...",
  "expires_in": 3600,
  "filename": "project_diagram.png"
}
```

**Error Responses:**

`401 Unauthorized`:
```json
{"detail": "Could not validate credentials"}
```

`403 Forbidden`:
```json
{"detail": "Not authorized to access this attachment"}
```

`404 Not Found`:
```json
{"detail": "Attachment 7c9e6679-7425-40de-944b-e07fc1f90ae7 not found"}
```

`500 Internal Server Error`:
```json
{"detail": "Failed to generate download URL. Please try again"}
```

---

### DELETE /api/attachments/{attachment_id}
Delete an attachment.

**Authentication**: Required

**Authorization**: User must be owner of task that attachment belongs to

**Response 204 No Content**

**Error Responses:**

`401 Unauthorized`:
```json
{"detail": "Could not validate credentials"}
```

`403 Forbidden`:
```json
{"detail": "Not authorized to delete this attachment"}
```

`404 Not Found`:
```json
{"detail": "Attachment 7c9e6679-7425-40de-944b-e07fc1f90ae7 not found"}
```

`500 Internal Server Error`:
```json
{"detail": "Failed to delete attachment. Please try again"}
```

---

## 6. Security Considerations

### Authorization Rules

All authorization checks implemented in **AttachmentService** layer (not in router).

**Upload** (`POST /api/tasks/{task_id}/attachments`):
- User must be authenticated (verified by `get_current_user` dependency in router)
- Service validates: `task.owner_id == current_user.id`
- Raise `HTTPException(403)` if not owner

**List** (`GET /api/tasks/{task_id}/attachments`):
- User must be authenticated
- Service validates: `task.owner_id == current_user.id`
- Raise `HTTPException(403)` if not owner

**Download** (`GET /api/attachments/{attachment_id}/download`):
- User must be authenticated
- Service retrieves attachment with task relationship
- Service validates: `attachment.task.owner_id == current_user.id`
- Raise `HTTPException(403)` if not owner

**Delete** (`DELETE /api/attachments/{attachment_id}`):
- User must be authenticated
- Service retrieves attachment with task relationship
- Service validates: `attachment.task.owner_id == current_user.id`
- Raise `HTTPException(403)` if not owner

**Pattern**: Router handles authentication, Service handles authorization

### Presigned URL Strategy
- **Expiration**: 1 hour (3600 seconds)
- **Method**: GET only
- **Generation**: On-demand when download endpoint called (not stored)
- **Benefits**: No direct S3 access needed, temporary access, auto-expiring

### Input Validation and Sanitization

**Filename sanitization**:
```python
def sanitize_filename(filename: str) -> str:
    # Remove path traversal
    filename = os.path.basename(filename)
    # Remove non-safe characters
    filename = re.sub(r'[^\w\s\-\.]', '', filename)
    # Limit length
    return filename[:255]
```

**MIME type validation**:
- Use FastAPI's UploadFile.content_type (relies on browser-provided MIME type)
- Validate against ALLOWED_MIME_TYPES whitelist
- Reject files with mismatched MIME types
- Note: For production, consider adding `python-magic` library for content-based validation

**File size validation**:
- Check `Content-Length` header before reading file
- Stream file in chunks to avoid memory exhaustion
- Reject if size exceeds limit

### Protection Against Common Attacks

**Path Traversal**:
- Sanitize filename to remove `../`, `..\\`
- Use UUID-based S3 keys (not user-controlled paths)

**File Upload Bombs**:
- Enforce strict file size limit (10MB)
- Validate MIME type before processing

**MIME Type Confusion**:
- MVP: Validate using browser-provided MIME type from UploadFile.content_type
- Whitelist approach with ALLOWED_MIME_TYPES
- Future enhancement: Add python-magic for magic number detection

**SSRF (Server-Side Request Forgery)**:
- S3 service uses boto3 with proper AWS credentials
- No user-controlled URLs for S3 operations

**Denial of Service**:
- Rate limiting on upload endpoints (future enhancement)
- File size limits prevent large uploads
- Per-task attachment count limit (future: max 20 attachments per task)

**Unauthorized Access**:
- All endpoints require authentication
- Task ownership verified before any operation
- Presigned URLs expire after 1 hour

---

## 7. Integration Points (Existing Code)

### Components to Reuse

**Authentication** (`src/services/auth.py`):
- `get_current_user` dependency for all endpoints
- Returns `User` model with validated authentication

**Database** (`src/database.py`):
- `get_db` dependency for session management
- `Base` for model inheritance

**Task Model** (`src/models/task.py`):
- Verify task existence: `db.query(Task).filter(Task.id == task_id).first()`
- Check ownership: `task.owner_id == current_user.id`

**Error Handling Pattern** (from `src/api/tasks.py`):
```python
from fastapi import HTTPException, status

if not task:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Task {task_id} not found"
    )
if task.owner_id != current_user.id:
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Not authorized"
    )
```

**Testing Fixtures** (`tests/conftest.py`):
- `client`: TestClient with dependency overrides
- `test_user`: Authenticated test user
- `auth_headers`: Bearer token headers
- `db`: Test database session

---

### New Components to Create

**Models:**
- `src/models/attachment.py`: Attachment SQLAlchemy model

**Repositories:**
- `src/repositories/attachment_repository.py`: AttachmentRepository class
  ```python
  class AttachmentRepository:
      def __init__(self, db: Session):
          self.db = db

      def create(self, attachment_data: dict) -> Attachment:
          # Creates instance, adds to session, does NOT commit
          attachment = Attachment(**attachment_data)
          self.db.add(attachment)
          self.db.flush()  # Get ID without committing
          self.db.refresh(attachment)
          return attachment

      def get_by_id(self, attachment_id: UUID) -> Optional[Attachment]:
          return self.db.query(Attachment).filter(Attachment.id == attachment_id).first()

      def list_by_task(self, task_id: UUID) -> List[Attachment]:
          return self.db.query(Attachment).filter(Attachment.task_id == task_id).all()

      def delete(self, attachment_id: UUID) -> bool:
          # Marks for deletion, does NOT commit
          attachment = self.get_by_id(attachment_id)
          if attachment:
              self.db.delete(attachment)
              return True
          return False
  ```

**Services:**
- `src/services/attachment_service.py`: AttachmentService class and dependency factory
  ```python
  class AttachmentService:
      def __init__(self, repository: AttachmentRepository, s3_service: S3Service, db: Session):
          self.repository = repository
          self.s3_service = s3_service
          self.db = db

      def upload(self, task_id: UUID, file: UploadFile, current_user: User) -> Attachment:
          # Validate, upload to S3, save to DB, commit, handle rollback
          pass

      def list_by_task(self, task_id: UUID, current_user: User) -> List[Attachment]:
          # Verify task ownership, return attachments
          pass

      def get_download_url(self, attachment_id: UUID, current_user: User) -> dict:
          # Verify ownership, generate presigned URL
          pass

      def delete(self, attachment_id: UUID, current_user: User) -> bool:
          # Verify ownership, delete from DB, delete from S3, commit
          pass

  def get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService:
      """Dependency factory: creates service with single DB session"""
      repository = AttachmentRepository(db)
      s3_service = S3Service()
      return AttachmentService(repository, s3_service, db)
  ```

- `src/services/s3_service.py`: S3Service class
  ```python
  class S3Service:
      def __init__(self):
          settings = get_settings()
          self.s3_client = boto3.client(
              's3',
              region_name=settings.s3_region,
              aws_access_key_id=settings.aws_access_key_id,
              aws_secret_access_key=settings.aws_secret_access_key
          )
          self.bucket_name = settings.s3_bucket_name
      def upload_file(self, file_content: bytes, s3_key: str) -> str
      def delete_file(self, s3_key: str) -> bool
      def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str
  ```

**Schemas:**
- `src/schemas/attachment.py`: Pydantic schemas
  ```python
  class AttachmentResponse(BaseModel):
      id: UUID
      task_id: UUID
      filename: str
      file_size: int
      mime_type: str
      uploader_id: UUID
      created_at: datetime
      model_config = ConfigDict(from_attributes=True)

  class AttachmentList(BaseModel):
      attachments: List[AttachmentResponse]
      total: int

  class AttachmentDownloadResponse(BaseModel):
      download_url: str
      expires_in: int
      filename: str
  ```

**API Routes:**
- `src/api/attachments.py`: FastAPI router with 4 endpoints
  ```python
  from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
  from ..services.attachment_service import get_attachment_service, AttachmentService
  from ..services.auth import get_current_user
  from ..models.user import User

  router = APIRouter(prefix="/api", tags=["Attachments"])

  @router.post("/tasks/{task_id}/attachments", response_model=AttachmentResponse, status_code=201)
  async def upload_attachment(
      task_id: UUID,
      file: UploadFile = File(...),
      current_user: User = Depends(get_current_user),
      service: AttachmentService = Depends(get_attachment_service)
  ):
      return service.upload(task_id, file, current_user)

  @router.get("/tasks/{task_id}/attachments", response_model=AttachmentList)
  def list_attachments(
      task_id: UUID,
      current_user: User = Depends(get_current_user),
      service: AttachmentService = Depends(get_attachment_service)
  ):
      attachments = service.list_by_task(task_id, current_user)
      return AttachmentList(attachments=attachments, total=len(attachments))

  @router.get("/attachments/{attachment_id}/download", response_model=AttachmentDownloadResponse)
  def get_download_url(
      attachment_id: UUID,
      current_user: User = Depends(get_current_user),
      service: AttachmentService = Depends(get_attachment_service)
  ):
      return service.get_download_url(attachment_id, current_user)

  @router.delete("/attachments/{attachment_id}", status_code=204)
  def delete_attachment(
      attachment_id: UUID,
      current_user: User = Depends(get_current_user),
      service: AttachmentService = Depends(get_attachment_service)
  ):
      service.delete(attachment_id, current_user)
      return None
  ```

- Update `src/api/__init__.py`:
  ```python
  from .attachments import router as attachments_router
  __all__ = ["auth_router", "tasks_router", "comments_router", "attachments_router"]
  ```

- Update `src/main.py` line 38 (after comments_router):
  ```python
  app.include_router(attachments_router)
  ```

**Tests:**
- `tests/test_attachment_api.py`: Integration tests for all endpoints
  - `test_upload_attachment()` - 201 success case
  - `test_upload_no_file()` - 400 error
  - `test_upload_file_too_large()` - 413 error
  - `test_upload_invalid_mime_type()` - 415 error
  - `test_upload_unauthorized()` - 403 error
  - `test_list_attachments()` - 200 success
  - `test_get_download_url()` - 200 success
  - `test_delete_attachment()` - 204 success

- `tests/test_attachment_service.py`: Unit tests for service layer (with mocked repo & S3)
  - `test_upload_validates_task_ownership()`
  - `test_upload_rollback_on_db_failure()`
  - `test_delete_removes_from_s3_and_db()`

- `tests/test_s3_service.py`: Unit tests for S3 operations (mocked boto3)
  - `test_upload_file_success()`
  - `test_generate_presigned_url()`
  - `test_delete_file_success()`

**Configuration:**
- Update `src/config.py` Settings class (add after line 14):
  ```python
  # S3 Configuration
  s3_bucket_name: str = "taskmaster-attachments"
  s3_region: str = "us-east-1"
  aws_access_key_id: str = ""
  aws_secret_access_key: str = ""
  max_upload_size: int = 10485760  # 10 MB in bytes
  ```

**Dependencies:**
- Add to `requirements.txt` (after line 20):
  ```
  boto3==1.34.7
  python-multipart==0.0.20  # Already present, needed for file uploads
  ```

---

### Database Migration

**Migration needed**: Create `attachments` table

Since Alembic is not currently set up, use database initialization:

**Update `src/database.py`** (add import at top of file, around line 6):
```python
from .models.attachment import Attachment  # Ensure model is imported
```

This ensures the Attachment table is created when `init_db()` calls `Base.metadata.create_all()`.

**Alternative**: Import in `src/models/__init__.py` (add to existing imports):
```python
from .attachment import Attachment
```

**Future**: Set up Alembic for proper migrations:
```bash
alembic init alembic
# Edit alembic.ini and alembic/env.py to configure database
alembic revision --autogenerate -m "Add attachments table"
alembic upgrade head
```

**Verification**: After running app, check table exists:
```sql
\dt attachments  -- in psql
SELECT * FROM attachments LIMIT 1;
```

---

### Integration Flow (Implementation Order)

1. **Update requirements.txt**: Add `boto3==1.34.7` (line 21)
2. **Update config.py**: Add S3 settings to Settings class (after line 14)
3. **Create Attachment model**: `src/models/attachment.py` (complete file)
4. **Update Task model**: Add `attachments` relationship in `src/models/task.py` (after line 33)
5. **Update models __init__.py**: Import Attachment in `src/models/__init__.py`
6. **Create repository directory**: `mkdir src/repositories`
7. **Create repository __init__.py**: `src/repositories/__init__.py` (empty file or with imports)
8. **Create AttachmentRepository**: `src/repositories/attachment_repository.py` (complete file)
9. **Create S3Service**: `src/services/s3_service.py` (complete file)
10. **Create AttachmentService**: `src/services/attachment_service.py` (complete file)
11. **Create Attachment schemas**: `src/schemas/attachment.py` (complete file)
12. **Create API router**: `src/api/attachments.py` (complete file)
13. **Update api __init__.py**: Add attachments_router export (line 6-7)
14. **Update main.py**: Include attachments_router (after line 38)
15. **Write test fixtures**: Update `tests/conftest.py` if needed for S3 mocking
16. **Write integration tests**: `tests/test_attachment_api.py` (complete file)
17. **Write unit tests**: `tests/test_attachment_service.py` and `tests/test_s3_service.py`
18. **Run tests**: `pytest tests/test_attachment_*.py -v`
19. **Run application**: Verify table creation in database

### Dependency Chain
```
FastAPI Request
    ↓
get_db() → db: Session (one per request)
    ↓
get_attachment_service(db) → creates:
    ├─ AttachmentRepository(db)
    ├─ S3Service()
    └─ AttachmentService(repository, s3_service, db)
        ↓
API Router endpoint → service.method(...)
    ↓
Service owns commit/rollback
Repository performs queries (no commit/rollback)
S3Service performs S3 operations
```

All new code follows CLAUDE.md patterns:
- Repository pattern for database access (no transaction management)
- Service layer for business logic and transaction ownership
- Dependency injection via FastAPI Depends() with factory function
- Single DB session per request
- UUID primary keys, timezone-aware timestamps
- HTTPException for errors with clear messages
- Integration tests using TestClient fixtures