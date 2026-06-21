# Task: Decompose Task Attachments into 13 atomic implementation tasks across 5 phases.
# Goal: Produce task_breakdown.md with dependencies, parallelism analysis, critical path, and time calculations.

# Task Breakdown: Task Attachments Feature

## Phase 1: Foundation (Database & Core Models)

### Task 1.1: Create Attachment Model and Database Schema
**Files:**
- `src/models/attachment.py` (new)
- `src/models/task.py` (modified)
- `alembic/versions/xxx_add_attachments_table.py` (new)

**Estimated Time:** 60 minutes

**Dependencies:** None

**Description:** Create the SQLAlchemy Attachment model and Alembic migration for the attachments table with proper relationships to tasks and users.

**Acceptance Criteria:**
- [ ] Attachment model created with all fields: id, task_id, filename, file_size, mime_type, s3_key, uploaded_by, created_at
- [ ] Foreign key relationships configured: task_id → tasks(id) CASCADE, uploaded_by → users(id)
- [ ] Task model updated with `attachments` back_populates relationship
- [ ] Alembic migration creates attachments table with indexes on task_id and uploaded_by
- [ ] Migration runs successfully with `alembic upgrade head`
- [ ] Model includes proper type hints and validates UUID fields

---

### Task 1.2: Create AttachmentRepository
**Files:**
- `src/repositories/attachment_repository.py` (new)

**Estimated Time:** 45 minutes

**Dependencies:** Task 1.1

**Description:** Implement repository layer for attachment CRUD operations with proper database session management.

**Acceptance Criteria:**
- [ ] Repository implements `create(task_id, filename, file_size, mime_type, s3_key, uploaded_by)` method
- [ ] Repository implements `get_by_id(attachment_id)` method returning Attachment or None
- [ ] Repository implements `list_by_task_id(task_id)` method returning list of attachments
- [ ] Repository implements `delete(attachment_id)` method with proper session commit
- [ ] All methods properly handle database exceptions and rollbacks
- [ ] Repository follows existing repository patterns from codebase

---

## Phase 2: Storage Layer (S3 Integration)

### Task 2.1: Implement S3Client
**Files:**
- `src/storage/s3_client.py` (new)
- `requirements.txt` (modified)
- `.env.example` (modified)

**Estimated Time:** 75 minutes

**Dependencies:** None

**Description:** Create S3Client wrapper for file upload, deletion, and presigned URL generation using boto3.

**Acceptance Criteria:**
- [ ] S3Client initializes with boto3 using AWS credentials from environment variables
- [ ] `upload_file(file_content, s3_key)` uploads binary content to S3 with AES-256 encryption
- [ ] `delete_file(s3_key)` removes file from S3 bucket
- [ ] `generate_presigned_url(s3_key, expires_in=3600)` creates time-limited GET URL
- [ ] S3 key follows format: `attachments/{task_id}/{uuid}/{filename}`
- [ ] Client handles boto3 exceptions (NoSuchBucket, AccessDenied) with clear error messages

---

### Task 2.2: Create FileUploadHandler Utility
**Files:**
- `src/utils/file_handler.py` (new)

**Estimated Time:** 30 minutes

**Dependencies:** None

**Description:** Build utility to handle multipart form file extraction and filename sanitization.

**Acceptance Criteria:**
- [ ] `sanitize_filename(filename)` strips path components and special characters
- [ ] Sanitization limits filename to 255 characters
- [ ] `generate_s3_key(task_id, filename)` creates unique S3 key with UUID
- [ ] Function preserves file extension during sanitization
- [ ] Unit tests verify path traversal prevention (e.g., `../../etc/passwd` → `etc_passwd`)

---

## Phase 3: Validation Layer

### Task 3.1: Implement MIME Type Validator
**Files:**
- `src/validators/mime_validator.py` (new)
- `requirements.txt` (modified)

**Estimated Time:** 60 minutes

**Dependencies:** None

**Description:** Create validator to check file MIME types against whitelist and verify magic bytes match extension.

**Acceptance Criteria:**
- [ ] Validator whitelists: application/pdf, image/png, image/jpeg, application/vnd.openxmlformats-officedocument.wordprocessingml.document
- [ ] `validate_mime_type(file_content, filename)` checks magic bytes using python-magic
- [ ] Validator raises ValidationError with message: "File type 'X' not allowed. Allowed: PDF, PNG, JPG, DOCX"
- [ ] Magic byte verification prevents spoofing (e.g., .exe renamed to .pdf)
- [ ] Validator handles files without extensions gracefully
- [ ] Unit tests cover all allowed types and common attack vectors

---

### Task 3.2: Implement File Size Validator
**Files:**
- `src/validators/file_size_validator.py` (new)

**Estimated Time:** 30 minutes

**Dependencies:** None

**Description:** Create validator to enforce 5MB file size limit with human-readable error messages.

**Acceptance Criteria:**
- [ ] `validate_file_size(file_content, max_size=5242880)` checks byte length
- [ ] Validator raises ValidationError with formatted message: "File size X.XMB exceeds maximum 5MB"
- [ ] Helper function converts bytes to human-readable format (KB/MB)
- [ ] Validation occurs before expensive operations (upload, virus scan)
- [ ] Unit tests verify edge cases: exactly 5MB, 1 byte over, empty file

---

### Task 3.3: Implement Virus Scanner Integration
**Files:**
- `src/validators/virus_scanner.py` (new)
- `requirements.txt` (modified)

**Estimated Time:** 90 minutes

**Dependencies:** None

**Description:** Integrate ClamAV virus scanning with fallback behavior and proper error handling.

**Acceptance Criteria:**
- [ ] `scan_file(file_content)` integrates with pyclamd or clamd for virus detection
- [ ] Scanner raises ValidationError with message: "File rejected: virus detected"
- [ ] Scanner raises ValidationError on scan failure: "File rejected: virus scan failed"
- [ ] Configuration allows disabling virus scanning for local development
- [ ] Scanner handles ClamAV connection errors gracefully with fail-safe approach
- [ ] Unit tests use mock virus signatures to verify detection

---

## Phase 4: Service & API Layer

### Task 4.1: Implement AttachmentService
**Files:**
- `src/services/attachment_service.py` (new)

**Estimated Time:** 90 minutes

**Dependencies:** Task 1.2, Task 2.1, Task 2.2, Task 3.1, Task 3.2, Task 3.3

**Description:** Create orchestration service that coordinates validation, upload, metadata storage, and rollback logic.

**Acceptance Criteria:**
- [ ] `upload_attachment(task_id, file, user_id)` orchestrates: validate → upload → save metadata
- [ ] Service runs validators in sequence: MIME → size → virus scan
- [ ] Service generates unique S3 key using FileUploadHandler
- [ ] Service implements rollback: if database save fails, deletes file from S3
- [ ] `list_attachments(task_id)` fetches metadata and generates presigned URLs for each
- [ ] `delete_attachment(attachment_id)` removes from both S3 and database atomically

---

### Task 4.2: Create Pydantic Schemas
**Files:**
- `src/schemas/attachment_schema.py` (new)

**Estimated Time:** 30 minutes

**Dependencies:** Task 1.1

**Description:** Define request/response schemas for API validation and serialization.

**Acceptance Criteria:**
- [ ] `AttachmentResponse` schema includes: id, task_id, filename, file_size, mime_type, uploaded_by, created_at, download_url
- [ ] `AttachmentListResponse` schema includes: attachments (list), count (int)
- [ ] All UUID fields use proper typing (UUID4)
- [ ] DateTime fields serialize to ISO 8601 format
- [ ] Schemas include examples for OpenAPI documentation

---

### Task 4.3: Implement Upload Attachment API
**Files:**
- `src/api/attachments.py` (new)
- `src/main.py` (modified)

**Estimated Time:** 75 minutes

**Dependencies:** Task 4.1, Task 4.2

**Description:** Create POST endpoint for file upload with multipart/form-data handling and authorization.

**Acceptance Criteria:**
- [ ] Endpoint: POST `/api/tasks/{task_id}/attachments` accepts multipart/form-data
- [ ] Endpoint uses `get_current_user` dependency for authentication
- [ ] Endpoint verifies task ownership: task.user_id == current_user.id (403 if false)
- [ ] Endpoint returns 201 with AttachmentResponse including presigned download URL
- [ ] Error responses: 400 (validation), 401 (auth), 403 (forbidden), 404 (task not found), 500 (server error)
- [ ] Endpoint registered in FastAPI app router in main.py

---

### Task 4.4: Implement List Attachments API
**Files:**
- `src/api/attachments.py` (modified)

**Estimated Time:** 45 minutes

**Dependencies:** Task 4.1, Task 4.2, Task 4.3

**Description:** Create GET endpoint to retrieve all attachments for a task with presigned URLs.

**Acceptance Criteria:**
- [ ] Endpoint: GET `/api/tasks/{task_id}/attachments` returns AttachmentListResponse
- [ ] Endpoint verifies user has task access (task owner check)
- [ ] Response includes presigned URLs for each attachment (1-hour expiration)
- [ ] Response includes total count of attachments
- [ ] Error responses: 401 (unauthorized), 403 (forbidden), 404 (task not found)
- [ ] Attachments ordered by created_at descending

---

### Task 4.5: Implement Delete Attachment API
**Files:**
- `src/api/attachments.py` (modified)

**Estimated Time:** 60 minutes

**Dependencies:** Task 4.1, Task 4.3

**Description:** Create DELETE endpoint with authorization for uploader or task owner.

**Acceptance Criteria:**
- [ ] Endpoint: DELETE `/api/attachments/{attachment_id}` returns 204 No Content
- [ ] Endpoint verifies user is uploader (attachment.uploaded_by == current_user.id) OR task owner
- [ ] Endpoint calls AttachmentService.delete_attachment() for atomic S3+DB deletion
- [ ] Error responses: 401 (unauthorized), 403 (forbidden), 404 (not found), 500 (S3 deletion failed)
- [ ] Deletion rolls back database transaction if S3 deletion fails
- [ ] Endpoint handles case where attachment exists in DB but not S3 (logs warning, deletes DB record)

---

## Phase 5: Testing & Documentation

### Task 5.1: Create E2E Tests and Update Documentation
**Files:**
- `tests/test_attachments_e2e.py` (new)
- `README.md` (modified)
- `docs/api_endpoints.md` (modified)

**Estimated Time:** 90 minutes

**Dependencies:** Task 4.3, Task 4.4, Task 4.5

**Description:** Write end-to-end tests covering happy path and error scenarios, update API documentation.

**Acceptance Criteria:**
- [ ] E2E test: upload valid PDF → verify 201 response → confirm file in S3 → verify DB record
- [ ] E2E test: upload oversized file → verify 400 with size error message
- [ ] E2E test: upload .exe file → verify 400 with MIME type error
- [ ] E2E test: list attachments → verify presigned URLs are valid and downloadable
- [ ] E2E test: delete attachment as uploader → verify 204 → confirm removed from S3 and DB
- [ ] Documentation updated with API endpoint examples, authentication requirements, and error codes

---

## Time Analysis

### Sequential Execution
**Total Time:** 60 + 45 + 75 + 30 + 60 + 30 + 90 + 90 + 30 + 75 + 45 + 60 + 90 = **780 minutes (13 hours)**

### Optimal Parallel Execution

**Wave 1 (no dependencies):** Max(Task 1.1: 60, Task 2.1: 75, Task 2.2: 30, Task 3.1: 60, Task 3.2: 30, Task 3.3: 90) = **90 minutes**

**Wave 2 (depends on Wave 1):** Max(Task 1.2: 45, Task 4.2: 30) = **45 minutes**

**Wave 3 (depends on Wave 2):** Task 4.1: **90 minutes**

**Wave 4 (depends on Wave 3):** Task 4.3: **75 minutes**

**Wave 5 (depends on Wave 4):** Max(Task 4.4: 45, Task 4.5: 60) = **60 minutes**

**Wave 6 (depends on Wave 5):** Task 5.1: **90 minutes**

**Total Parallel Time:** 90 + 45 + 90 + 75 + 60 + 90 = **450 minutes (7.5 hours)**

### Time Savings
**Savings:** 780 - 450 = **330 minutes (5.5 hours)**
**Efficiency Gain:** 42.3%

### Critical Path

**Longest Dependency Chain:**
```
1.1 (60m) → 1.2 (45m) → 4.1 (90m) → 4.3 (75m) → 4.5 (60m) → 5.1 (90m) = 420 minutes
```

**Actual Parallel Execution Timeline (Wave Bottlenecks):**
```
Wave 1: 90m (bottleneck: Task 3.3)
Wave 2: 45m (bottleneck: Task 1.2)
Wave 3: 90m (Task 4.1)
Wave 4: 75m (Task 4.3)
Wave 5: 60m (bottleneck: Task 4.5)
Wave 6: 90m (Task 5.1)
Total: 450 minutes
```

**Why 450 minutes instead of 420?** Wave 1 contains 6 parallel tasks. Although Task 1.1 (60m) starts the longest dependency chain, Task 3.3 (90m) is the slowest task in Wave 1. Wave 2 cannot begin until ALL Wave 1 tasks complete, adding 30 extra minutes to the timeline.

---

## Dependency Graph

```
Phase 1:
  1.1 (Model) ──────────┐
                        ├──> 1.2 (Repository) ──┐
                        │                        │
Phase 2:                │                        │
  2.1 (S3Client) ───────┤                        │
  2.2 (FileHandler) ────┤                        │
                        │                        ├──> 4.1 (Service) ──┐
Phase 3:                │                        │                     │
  3.1 (MIME) ───────────┤                        │                     │
  3.2 (Size) ───────────┤                        │                     │
  3.3 (Virus) ──────────┘                        │                     │
                                                 │                     │
Phase 4:                                         │                     │
  4.2 (Schemas) ──────────────────────────────────┴─────────────────┐ │
                                                                     │ │
  4.3 (Upload API) ────────────────────────────────────────────────┴─┴──┐
                                                                         │
  4.4 (List API) ─────────────────────────────────────────────────────┬─┤
  4.5 (Delete API) ───────────────────────────────────────────────────┘ │
                                                                         │
Phase 5:                                                                 │
  5.1 (E2E Tests) ────────────────────────────────────────────────────────┘
```

---

## Component Coverage Checklist

Based on technical_plan.md Integration Points (Section 7):

**New Components Created:**
- [x] Attachment Model (`src/models/attachment.py`) - Task 1.1
- [x] AttachmentRepository (`src/repositories/attachment_repository.py`) - Task 1.2
- [x] S3Client (`src/storage/s3_client.py`) - Task 2.1
- [x] Validators (`src/validators/mime_validator.py`) - Task 3.1
- [x] Validators (`src/validators/file_size_validator.py`) - Task 3.2
- [x] Validators (`src/validators/virus_scanner.py`) - Task 3.3
- [x] AttachmentService (`src/services/attachment_service.py`) - Task 4.1
- [x] Attachment API (`src/api/attachments.py`) - Task 4.3, 4.4, 4.5
- [x] Pydantic Schemas (`src/schemas/attachment_schema.py`) - Task 4.2
- [x] File Handler Utility (`src/utils/file_handler.py`) - Task 2.2
- [x] Database Migration (`alembic/versions/xxx_add_attachments_table.py`) - Task 1.1
- [x] E2E Tests (`tests/test_attachments_e2e.py`) - Task 5.1

**All 13 tasks required. No optional tasks.**
