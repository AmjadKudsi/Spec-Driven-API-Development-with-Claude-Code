# Create technical_plan.md for Task Attachments using the required 7 sections.
# Use Claude Code to inspect existing TaskMaster patterns, fill the plan, then verify completeness.


╭─── Claude Code v2.0.42 ─────────────────────────────────────────────────────────────────────────────────╮
│                                    │ Recent activity                                                    │
│            Welcome back!           │ No recent activity                                                 │
│                                    │ ────────────────────────────────────────────────────────────────── │
│               ▐▛███▜▌              │ What's new                                                         │
│              ▝▜█████▛▘             │ Improved auto mode safety: destructive git commands (`git reset -… │
│                ▘▘ ▝▝               │ Added a warning when the requested model is deprecated or automat… │
│                                    │ Added `attribution.sessionUrl` setting to omit the claude.ai sess… │
│   Sonnet 4.5 · API Usage Billing   │ /release-notes for more                                            │
│        /usercode/FILESYSTEM        │                                                                    │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────╯

> Read @technical_plan.md, @CLAUDE.md, and inspect existing TaskMaster patterns for models, 
repositories, services, schemas, API routes, auth, tests, migrations, and file storage. Do not edit 
yet. Report missing essential files only. 
  ⎿  Read CLAUDE.md (151 lines)

● I'll read the technical plan and inspect the existing codebase structure to understand what's already
   in place and identify any missing essential files.

● Read(technical_plan.md)
  ⎿  Error reading file

● Bash(find /usercode/FILESYSTEM -type f -name "*.py" | head -50)
  ⎿  /usercode/FILESYSTEM/src/__init__.py
     /usercode/FILESYSTEM/src/config.py
     /usercode/FILESYSTEM/src/database.py
     … +22 lines (ctrl+o to expand)

● Bash(ls -la /usercode/FILESYSTEM/)
  ⎿  total 40                                         
     drwxrwxrwt. 8 root   root   16384 Jun 19 20:19 .
     drwxrwxrwx. 3 root   root      50 Jun 19 20:19 ..
     … +12 lines (ctrl+o to expand)

● Search(pattern: "**/*plan*.md")
  ⎿  Found 1 file (ctrl+o to expand)

● Bash(ls -la /usercode/FILESYSTEM/specs/)
  ⎿  total 40                                         
     drwxrwxrwt. 2 runner runner   168 Jun 19 20:19 .
     drwxrwxrwt. 8 root   root   16384 Jun 19 20:19 ..
     … +6 lines (ctrl+o to expand)

● Bash(ls -la /usercode/FILESYSTEM/docs/)
  ⎿  total 20                                         
     drwxrwxrwt. 3 runner runner    36 Jun 19 20:19 .
     drwxrwxrwt. 8 root   root   16384 Jun 19 20:19 ..
     … +2 lines (ctrl+o to expand)

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 69 lines

● Bash(find /usercode/FILESYSTEM/src -type d)
  ⎿  /usercode/FILESYSTEM/src        
     /usercode/FILESYSTEM/src/models
     /usercode/FILESYSTEM/src/schemas
     … +2 lines (ctrl+o to expand)

● Search(pattern: "src/repositories/**/*.py")
  ⎿  Found 0 files 

● Search(pattern: "src/services/**/*.py")
  ⎿  Found 3 files (ctrl+o to expand)

● Read(src/models/task.py)
  ⎿  Read 46 lines

● Read(src/models/user.py)
  ⎿  Read 35 lines

● Read(src/schemas/task.py)
  ⎿  Read 43 lines

● Read(src/api/tasks.py)
  ⎿  Read 116 lines

● Read(src/services/auth.py)
  ⎿  Read 51 lines

● Read(src/database.py)
  ⎿  Read 26 lines

● Read(src/config.py)
  ⎿  Read 22 lines

● Read(src/main.py)
  ⎿  Read 69 lines

● Bash(find /usercode/FILESYSTEM -type d -name "migrations" -o -name "alembic")
  ⎿  (No content)

● Read(tests/conftest.py)
  ⎿  Read 55 lines

● Read(requirements.txt)
  ⎿  Read 20 lines

● Read(src/services/notification.py)
  ⎿  Read 42 lines

● Bash(ls -la /usercode/FILESYSTEM/src/api/)
  ⎿  total 24                                        
     drwxrwxrwt. 2 runner runner   75 Jun 19 20:19 .
     drwxrwxrwt. 6 runner runner  132 Jun 19 20:19 ..
     … +4 lines (ctrl+o to expand)

● Read(src/api/__init__.py)
  ⎿  Read 7 lines

● Read(src/models/comment.py)
  ⎿  Read 23 lines

● Bash(ls -la /usercode/FILESYSTEM/tests/)
  ⎿  total 40                                         
     drwxrwxrwt. 2 runner runner   145 Jun 19 20:19 .
     drwxrwxrwt. 8 root   root   16384 Jun 19 20:19 ..
     … +6 lines (ctrl+o to expand)

● Read(tests/test_task_api.py)
  ⎿  Read 48 lines

● Bash(find /usercode/FILESYSTEM -name "alembic.ini" -o -type d -name "alembic")
  ⎿  (No content)

● Bash(ls -la /usercode/FILESYSTEM/workspace/)
  ⎿  total 20                                         
     drwxrwxrwt. 3 runner runner    36 Jun 19 20:19 .
     drwxrwxrwt. 8 root   root   16384 Jun 19 20:19 ..
     … +2 lines (ctrl+o to expand)

● Read(specs/task-model-v1.0.md)
  ⎿  Read 38 lines

● Read(specs/task-api-v1.0.md)
  ⎿  Read 80 lines

● Bash(tree /usercode/FILESYSTEM/src -I "__pycache__")
  ⎿  Error: Exit code 127
     /bin/bash: line 1: tree: command not found

● Bash(find /usercode/FILESYSTEM/src -type f -name "*.py" | sort)
  ⎿  /usercode/FILESYSTEM/src/api/auth.py    
     /usercode/FILESYSTEM/src/api/comments.py
     /usercode/FILESYSTEM/src/api/__init__.py
     … +16 lines (ctrl+o to expand)

● Read(README.md)
  ⎿  Read 57 lines

● Based on my inspection of the TaskMaster codebase, here's my analysis:

  Existing Patterns Found

  ✓ Models (src/models/)

  - User (user.py): UUID primary keys, timezone-aware timestamps, password hashing
  - Task (task.py): UUID keys, status enum, relationships, business logic (update_status)
  - Comment (comment.py): UUID keys, foreign key relationships

  ✓ Schemas (src/schemas/)

  - Pydantic schemas for Task, User, Comment
  - Create/Update/Response patterns
  - Validation with Field constraints

  ✓ API Routes (src/api/)

  - auth.py, tasks.py, comments.py
  - Uses FastAPI routers
  - NOTE: Database access is DIRECTLY in routes (not following repository pattern)

  ✓ Authentication

  - JWT-based (src/services/auth.py)
  - get_current_user dependency available
  - HTTPBearer security

  ✓ Tests (tests/)

  - Pytest with fixtures (conftest.py)
  - TestClient setup with in-memory SQLite
  - Integration tests for API endpoints

  ✓ Services

  - auth.py: JWT token creation, current user extraction
  - notification.py: WebSocket notification service

  ✓ Configuration

  - Pydantic settings in config.py
  - Database setup in database.py
  - Main app in main.py

  Missing Essential Components

  ❌ Repository Layer

  CLAUDE.md references src/repositories/task_repository.py but this does not exist. Current code
  violates the repository pattern - all database queries are directly in API route handlers.

  ❌ Service Layer (for business logic)

  No service classes exist for Task or Comment business logic. API routes contain validation, business
  logic, and persistence mixed together, violating the service layer pattern from CLAUDE.md.

  ❌ Database Migrations

  - Alembic is in requirements.txt but no alembic.ini exists
  - No migrations directory exists
  - Database uses Base.metadata.create_all() instead of migrations

  ❌ File Storage Configuration

  - No S3 or file storage service
  - No boto3 or similar AWS SDK in requirements.txt
  - Required for the Task Attachments feature in technical_plan.md

  Summary

  The codebase has models, schemas, API routes, auth, and tests, BUT it does not follow the 
  architecture patterns specified in CLAUDE.md:
  - Missing repository pattern implementation
  - Missing service layer for business logic
  - Missing Alembic migration setup
  - Missing file storage infrastructure

> Given the specification for Task Attachments, generate a complete technical plan following the 
7-section structure from the lesson. Reference CLAUDE.md patterns and existing TaskMaster code. Fill 
@technical_plan.md completely. Be specific enough for task decomposition. Necessary only. 

● I'll generate a complete technical plan for the Task Attachments feature, following the patterns from
   CLAUDE.md and the existing TaskMaster codebase.

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 69 lines

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 496 additions and 35 removals           
         2    
         3    ## 1. Architecture (Component Interactions)
         4    
         5 -  <!-- TODO: Define how components interact
         6 -  - Describe the request flow from client to database
         7 -  - List each component and its responsibility
         8 -  - Explain the data flow for upload operations
         9 -  - Define rollback strategy if operations fail -->
         5 +  ### Request Flow
         6 +  ```
         7 +  Client → API Router → Service Layer → Repository Layer → Database
         8 +                      ↓
         9 +                    S3Service → AWS S3
        10 +  ```
        11    
        12 +  ### Components and Responsibilities
        13 +  
        14 +  **AttachmentRouter** (`src/api/attachments.py`)
        15 +  - Handle HTTP requests for upload, list, download, delete
        16 +  - Validate user authentication via `get_current_user` dependency
        17 +  - Parse multipart form data for file uploads
        18 +  - Return appropriate HTTP responses and error codes
        19 +  
        20 +  **AttachmentService** (`src/services/attachment_service.py`)
        21 +  - Validate file size and MIME type
        22 +  - Authorize user access (verify task ownership)
        23 +  - Coordinate upload: S3 upload → database save
        24 +  - Generate presigned URLs for downloads
        25 +  - Handle deletion: database delete → S3 cleanup
        26 +  - Implement rollback logic on failures
        27 +  
        28 +  **AttachmentRepository** (`src/repositories/attachment_repository.py`)
        29 +  - CRUD operations for Attachment model
        30 +  - Query attachments by task_id
        31 +  - Transaction management with database session
        32 +  
        33 +  **S3Service** (`src/services/s3_service.py`)
        34 +  - Upload files to S3 with unique keys
        35 +  - Delete files from S3
        36 +  - Generate presigned download URLs
        37 +  - Handle S3 client exceptions
        38 +  
        39 +  ### Upload Data Flow
        40 +  1. Client sends multipart/form-data to POST `/api/tasks/{task_id}/attachments`
        41 +  2. Router extracts file, validates request, calls service
        42 +  3. Service validates file size/type and task ownership
        43 +  4. Service calls S3Service to upload file → receives S3 key
        44 +  5. Service calls Repository to save attachment metadata
        45 +  6. Repository commits transaction
        46 +  7. Service returns attachment metadata to router
        47 +  8. Router returns 201 Created with attachment details
        48 +  
        49 +  ### Rollback Strategy
        50 +  - **If S3 upload fails**: Return 500 error, no database record created
        51 +  - **If database save fails after S3 upload**: Delete uploaded file from S3, return 500
           +  error
        52 +  - **If presigned URL generation fails**: Return 500 error, log issue
        53 +  - All database operations wrapped in try/except with session rollback
        54 +  
        55    ---
        56    
        57    ## 2. Data Model (Database Schema)
        58    
        59 -  <!-- TODO: Define the Attachment table
        60 -  - List all columns with types and constraints
        61 -  - Define foreign key relationships
        62 -  - Create necessary indexes
        63 -  - Provide SQLAlchemy model code -->
        59 +  ### Attachment Table
        60    
        61 +  ```python
        62 +  # src/models/attachment.py
        63 +  from sqlalchemy import Column, String, Integer, DateTime, ForeignKey
        64 +  from sqlalchemy.dialects.postgresql import UUID
        65 +  from sqlalchemy.orm import relationship
        66 +  from datetime import datetime, timezone
        67 +  import uuid
        68 +  from ..database import Base
        69 +  
        70 +  class Attachment(Base):
        71 +      __tablename__ = "attachments"
        72 +  
        73 +      id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
        74 +      task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id", ondelete="CASCADE"), 
           + nullable=False, index=True)
        75 +      uploader_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
        76 +      filename = Column(String(255), nullable=False)
        77 +      file_size = Column(Integer, nullable=False)  # bytes
        78 +      mime_type = Column(String(127), nullable=False)
        79 +      s3_key = Column(String(512), nullable=False, unique=True)
        80 +      s3_bucket = Column(String(255), nullable=False)
        81 +      created_at = Column(DateTime(timezone=True), default=lambda: 
           + datetime.now(timezone.utc))
        82 +  
        83 +      task = relationship("Task", back_populates="attachments")
        84 +      uploader = relationship("User")
        85 +  ```
        86 +  
        87 +  ### Updates to Existing Models
        88 +  
        89 +  **Task Model** (`src/models/task.py`) - Add relationship:
        90 +  ```python
        91 +  attachments = relationship("Attachment", back_populates="task", cascade="all, 
           + delete-orphan")
        92 +  ```
        93 +  
        94 +  ### Indexes
        95 +  - `task_id`: For efficient querying attachments by task (created via ForeignKey 
           + index=True)
        96 +  - `s3_key`: Unique constraint to prevent duplicate S3 keys
        97 +  
        98 +  ### Constraints
        99 +  - `task_id`: NOT NULL, CASCADE delete when task deleted
       100 +  - `uploader_id`: NOT NULL
       101 +  - `filename`: NOT NULL, max 255 chars
       102 +  - `file_size`: NOT NULL, positive integer
       103 +  - `mime_type`: NOT NULL, max 127 chars
       104 +  - `s3_key`: NOT NULL, unique, max 512 chars
       105 +  - `s3_bucket`: NOT NULL, max 255 chars
       106 +  
       107    ---
       108    
       109    ## 3. Storage Strategy (S3 Organization)
       110    
       111 -  <!-- TODO: Define how files are organized in S3
       112 -  - Describe bucket structure
       113 -  - Define S3 key format (path structure)
       114 -  - Explain why this organization makes sense
       115 -  - List S3 configuration requirements -->
       111 +  ### Bucket Structure
       112 +  - **Bucket name**: `taskmaster-attachments` (configurable via settings)
       113 +  - **Region**: us-east-1 (configurable via settings)
       114 +  - **Lifecycle policy**: None for MVP (future: archive after 90 days)
       115    
       116 +  ### S3 Key Format
       117 +  ```
       118 +  attachments/{task_id}/{attachment_id}/{sanitized_filename}
       119 +  ```
       120 +  
       121 +  **Example:**
       122 +  ```
       123 +  attachments/550e8400-e29b-41d4-a716-446655440000/7c9e6679-7425-40de-944b-e07fc1f90ae7/
           + project_diagram.png
       124 +  ```
       125 +  
       126 +  ### Rationale
       127 +  - **Task grouping**: All attachments for a task under same prefix enables efficient 
           + listing and cleanup
       128 +  - **Unique attachment_id**: Prevents filename collisions, enables atomic operations
       129 +  - **Original filename**: Preserves user-friendly names while ensuring uniqueness
       130 +  - **Flat hierarchy**: Simple structure, scales well, no deep nesting issues
       131 +  
       132 +  ### S3 Configuration Requirements
       133 +  
       134 +  Add to `src/config.py`:
       135 +  ```python
       136 +  s3_bucket_name: str = "taskmaster-attachments"
       137 +  s3_region: str = "us-east-1"
       138 +  aws_access_key_id: str = ""
       139 +  aws_secret_access_key: str = ""
       140 +  ```
       141 +  
       142 +  Environment variables: `S3_BUCKET_NAME`, `S3_REGION`, `AWS_ACCESS_KEY_ID`, 
           + `AWS_SECRET_ACCESS_KEY`
       143 +  
       144 +  ### Bucket Permissions
       145 +  - Service account needs: `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`
       146 +  - Presigned URLs require: `s3:GetObject` permission on bucket
       147 +  
       148    ---
       149    
       150    ## 4. Validation Rules
       151    
       152 -  <!-- TODO: Define all validation requirements
       153 -  - List allowed MIME types
       154 -  - Define file size limit
       155 -  - Describe virus scanning approach
       156 -  - Provide error message formats -->
       152 +  ### Allowed MIME Types
       153 +  ```python
       154 +  ALLOWED_MIME_TYPES = {
       155 +      # Images
       156 +      "image/png", "image/jpeg", "image/jpg", "image/gif", "image/webp",
       157 +      # Documents
       158 +      "application/pdf",
       159 +      "text/plain",
       160 +      "application/msword",  # .doc
       161 +      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",  # 
           + .docx
       162 +      "application/vnd.ms-excel",  # .xls
       163 +      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",  # .xlsx
       164 +      # Archives
       165 +      "application/zip",
       166 +      "application/x-tar",
       167 +      "application/gzip"
       168 +  }
       169 +  ```
       170    
       171 +  ### File Size Limit
       172 +  - **Maximum**: 10 MB (10,485,760 bytes)
       173 +  - **Validation**: Check before S3 upload to avoid wasted bandwidth
       174 +  - **Error**: 413 Payload Too Large if exceeded
       175 +  
       176 +  ### Filename Validation
       177 +  - **Maximum length**: 255 characters
       178 +  - **Sanitization**: Remove path traversal characters (`../`, `..\\`)
       179 +  - **Allowed characters**: alphanumeric, hyphens, underscores, periods, spaces
       180 +  - **Reject**: Null bytes, control characters
       181 +  
       182 +  ### Virus Scanning
       183 +  - **MVP approach**: Skip virus scanning (note as future enhancement)
       184 +  - **Future**: Integrate AWS S3 bucket scanning or ClamAV
       185 +  
       186 +  ### Error Message Formats
       187 +  
       188 +  Following CLAUDE.md pattern for clear, actionable messages:
       189 +  
       190 +  ```python
       191 +  # File too large
       192 +  "File size 15.2MB exceeds maximum allowed size of 10MB"
       193 +  
       194 +  # Invalid MIME type
       195 +  "File type 'application/exe' not allowed. Allowed types: images, PDFs, documents, 
           + archives"
       196 +  
       197 +  # Task not found
       198 +  "Task {task_id} not found"
       199 +  
       200 +  # Not authorized
       201 +  "Not authorized to upload attachments to this task"
       202 +  
       203 +  # Attachment not found
       204 +  "Attachment {attachment_id} not found"
       205 +  
       206 +  # S3 upload failure
       207 +  "Failed to upload file to storage. Please try again"
       208 +  ```
       209 +  
       210    ---
       211    
       212    ## 5. API Contracts (Endpoints)
       213    
       214 -  <!-- TODO: Define all API endpoints
       215 -  - POST /api/tasks/{task_id}/attachments (upload)
       216 -  - GET /api/tasks/{task_id}/attachments (list)
       217 -  - DELETE /api/attachments/{attachment_id} (delete)
       218 -  - For each: request format, response format, error codes -->
       214 +  ### POST /api/tasks/{task_id}/attachments
       215 +  Upload attachment to task.
       216    
       217 +  **Authentication**: Required (Bearer token)
       218 +  
       219 +  **Authorization**: User must be task owner
       220 +  
       221 +  **Request**: multipart/form-data
       222 +  ```
       223 +  Content-Type: multipart/form-data
       224 +  
       225 +  file: <binary data>
       226 +  ```
       227 +  
       228 +  **Response 201 Created:**
       229 +  ```json
       230 +  {
       231 +    "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
       232 +    "task_id": "550e8400-e29b-41d4-a716-446655440000",
       233 +    "filename": "project_diagram.png",
       234 +    "file_size": 245760,
       235 +    "mime_type": "image/png",
       236 +    "uploader_id": "123e4567-e89b-12d3-a456-426614174000",
       237 +    "created_at": "2024-01-20T15:30:00Z"
       238 +  }
       239 +  ```
       240 +  
       241 +  **Error Responses:**
       242 +  - `400 Bad Request`: No file provided, invalid filename
       243 +  - `401 Unauthorized`: Missing or invalid token
       244 +  - `403 Forbidden`: Not task owner
       245 +  - `404 Not Found`: Task not found
       246 +  - `413 Payload Too Large`: File exceeds 10MB
       247 +  - `415 Unsupported Media Type`: Invalid MIME type
       248 +  - `500 Internal Server Error`: S3 or database failure
       249 +  
       250    ---
       251    
       252 +  ### GET /api/tasks/{task_id}/attachments
       253 +  List all attachments for a task.
       254 +  
       255 +  **Authentication**: Required
       256 +  
       257 +  **Authorization**: User must be task owner
       258 +  
       259 +  **Response 200 OK:**
       260 +  ```json
       261 +  {
       262 +    "attachments": [
       263 +      {
       264 +        "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
       265 +        "task_id": "550e8400-e29b-41d4-a716-446655440000",
       266 +        "filename": "project_diagram.png",
       267 +        "file_size": 245760,
       268 +        "mime_type": "image/png",
       269 +        "uploader_id": "123e4567-e89b-12d3-a456-426614174000",
       270 +        "created_at": "2024-01-20T15:30:00Z"
       271 +      }
       272 +    ],
       273 +    "total": 1
       274 +  }
       275 +  ```
       276 +  
       277 +  **Error Responses:**
       278 +  - `401 Unauthorized`: Missing or invalid token
       279 +  - `403 Forbidden`: Not task owner
       280 +  - `404 Not Found`: Task not found
       281 +  
       282 +  ---
       283 +  
       284 +  ### GET /api/attachments/{attachment_id}/download
       285 +  Get presigned URL for downloading attachment.
       286 +  
       287 +  **Authentication**: Required
       288 +  
       289 +  **Authorization**: User must be owner of task that attachment belongs to
       290 +  
       291 +  **Response 200 OK:**
       292 +  ```json
       293 +  {
       294 +    "download_url": "https://taskmaster-attachments.s3.amazonaws.com/attachments/...",
       295 +    "expires_in": 3600,
       296 +    "filename": "project_diagram.png"
       297 +  }
       298 +  ```
       299 +  
       300 +  **Error Responses:**
       301 +  - `401 Unauthorized`: Missing or invalid token
       302 +  - `403 Forbidden`: Not authorized to access this attachment
       303 +  - `404 Not Found`: Attachment not found
       304 +  - `500 Internal Server Error`: Failed to generate presigned URL
       305 +  
       306 +  ---
       307 +  
       308 +  ### DELETE /api/attachments/{attachment_id}
       309 +  Delete an attachment.
       310 +  
       311 +  **Authentication**: Required
       312 +  
       313 +  **Authorization**: User must be owner of task that attachment belongs to
       314 +  
       315 +  **Response 204 No Content**
       316 +  
       317 +  **Error Responses:**
       318 +  - `401 Unauthorized`: Missing or invalid token
       319 +  - `403 Forbidden`: Not authorized to delete this attachment
       320 +  - `404 Not Found`: Attachment not found
       321 +  - `500 Internal Server Error`: Failed to delete from S3 or database
       322 +  
       323 +  ---
       324 +  
       325    ## 6. Security Considerations
       326    
       327 -  <!-- TODO: Define security requirements
       328 -  - Authorization rules for upload/list/delete
       329 -  - Presigned URL strategy and expiration
       330 -  - Input validation and sanitization
       331 -  - Protection against common attacks -->
       327 +  ### Authorization Rules
       328    
       329 +  **Upload** (`POST /api/tasks/{task_id}/attachments`):
       330 +  - User must be authenticated
       331 +  - User must be the owner of the task (`task.owner_id == current_user.id`)
       332 +  
       333 +  **List** (`GET /api/tasks/{task_id}/attachments`):
       334 +  - User must be authenticated
       335 +  - User must be the owner of the task
       336 +  
       337 +  **Download** (`GET /api/attachments/{attachment_id}/download`):
       338 +  - User must be authenticated
       339 +  - User must be owner of the task that attachment belongs to
       340 +  - Check: `attachment.task.owner_id == current_user.id`
       341 +  
       342 +  **Delete** (`DELETE /api/attachments/{attachment_id}`):
       343 +  - User must be authenticated
       344 +  - User must be owner of the task that attachment belongs to
       345 +  
       346 +  ### Presigned URL Strategy
       347 +  - **Expiration**: 1 hour (3600 seconds)
       348 +  - **Method**: GET only
       349 +  - **Generation**: On-demand when download endpoint called (not stored)
       350 +  - **Benefits**: No direct S3 access needed, temporary access, auto-expiring
       351 +  
       352 +  ### Input Validation and Sanitization
       353 +  
       354 +  **Filename sanitization**:
       355 +  ```python
       356 +  def sanitize_filename(filename: str) -> str:
       357 +      # Remove path traversal
       358 +      filename = os.path.basename(filename)
       359 +      # Remove non-safe characters
       360 +      filename = re.sub(r'[^\w\s\-\.]', '', filename)
       361 +      # Limit length
       362 +      return filename[:255]
       363 +  ```
       364 +  
       365 +  **MIME type validation**:
       366 +  - Use `python-magic` or file header inspection (not just extension)
       367 +  - Reject files with mismatched MIME types
       368 +  - Whitelist approach (explicit allowed types)
       369 +  
       370 +  **File size validation**:
       371 +  - Check `Content-Length` header before reading file
       372 +  - Stream file in chunks to avoid memory exhaustion
       373 +  - Reject if size exceeds limit
       374 +  
       375 +  ### Protection Against Common Attacks
       376 +  
       377 +  **Path Traversal**:
       378 +  - Sanitize filename to remove `../`, `..\\`
       379 +  - Use UUID-based S3 keys (not user-controlled paths)
       380 +  
       381 +  **File Upload Bombs**:
       382 +  - Enforce strict file size limit (10MB)
       383 +  - Validate MIME type before processing
       384 +  
       385 +  **MIME Type Confusion**:
       386 +  - Validate actual file content, not just extension
       387 +  - Use magic number detection
       388 +  
       389 +  **SSRF (Server-Side Request Forgery)**:
       390 +  - S3 service uses boto3 with proper AWS credentials
       391 +  - No user-controlled URLs for S3 operations
       392 +  
       393 +  **Denial of Service**:
       394 +  - Rate limiting on upload endpoints (future enhancement)
       395 +  - File size limits prevent large uploads
       396 +  - Per-task attachment count limit (future: max 20 attachments per task)
       397 +  
       398 +  **Unauthorized Access**:
       399 +  - All endpoints require authentication
       400 +  - Task ownership verified before any operation
       401 +  - Presigned URLs expire after 1 hour
       402 +  
       403    ---
       404    
       405    ## 7. Integration Points (Existing Code)
       406    
       407 -  <!-- TODO: Identify existing code to use
       408 -  - List existing components to reuse
       409 -  - List new components to create
       410 -  - Define how new code integrates with existing
       411 -  - Note any database migrations needed -->
       407   \ No newline at end of file
       408 +  ### Components to Reuse
       409 +  
       410 +  **Authentication** (`src/services/auth.py`):
       411 +  - `get_current_user` dependency for all endpoints
       412 +  - Returns `User` model with validated authentication
       413 +  
       414 +  **Database** (`src/database.py`):
       415 +  - `get_db` dependency for session management
       416 +  - `Base` for model inheritance
       417 +  
       418 +  **Task Model** (`src/models/task.py`):
       419 +  - Verify task existence: `db.query(Task).filter(Task.id == task_id).first()`
       420 +  - Check ownership: `task.owner_id == current_user.id`
       421 +  
       422 +  **Error Handling Pattern** (from `src/api/tasks.py`):
       423 +  ```python
       424 +  from fastapi import HTTPException, status
       425 +  
       426 +  if not task:
       427 +      raise HTTPException(
       428 +          status_code=status.HTTP_404_NOT_FOUND,
       429 +          detail=f"Task {task_id} not found"
       430 +      )
       431 +  if task.owner_id != current_user.id:
       432 +      raise HTTPException(
       433 +          status_code=status.HTTP_403_FORBIDDEN,
       434 +          detail="Not authorized"
       435 +      )
       436 +  ```
       437 +  
       438 +  **Testing Fixtures** (`tests/conftest.py`):
       439 +  - `client`: TestClient with dependency overrides
       440 +  - `test_user`: Authenticated test user
       441 +  - `auth_headers`: Bearer token headers
       442 +  - `db`: Test database session
       443 +  
       444 +  ---
       445 +  
       446 +  ### New Components to Create
       447 +  
       448 +  **Models:**
       449 +  - `src/models/attachment.py`: Attachment SQLAlchemy model
       450 +  
       451 +  **Repositories:**
       452 +  - `src/repositories/attachment_repository.py`: AttachmentRepository class
       453 +    - Methods: `create()`, `get_by_id()`, `list_by_task()`, `delete()`
       454 +  
       455 +  **Services:**
       456 +  - `src/services/attachment_service.py`: AttachmentService class
       457 +    - Methods: `upload()`, `list_by_task()`, `get_download_url()`, `delete()`
       458 +  - `src/services/s3_service.py`: S3Service class
       459 +    - Methods: `upload_file()`, `delete_file()`, `generate_presigned_url()`
       460 +  
       461 +  **Schemas:**
       462 +  - `src/schemas/attachment.py`: Pydantic schemas
       463 +    - `AttachmentResponse`: Response schema
       464 +    - `AttachmentList`: List response schema
       465 +    - `AttachmentDownloadResponse`: Download URL response
       466 +  
       467 +  **API Routes:**
       468 +  - `src/api/attachments.py`: FastAPI router with 4 endpoints
       469 +    - Add to `src/api/__init__.py` exports
       470 +    - Include router in `src/main.py`
       471 +  
       472 +  **Tests:**
       473 +  - `tests/test_attachment_api.py`: Integration tests for all endpoints
       474 +  - `tests/test_attachment_service.py`: Unit tests for service layer
       475 +  - `tests/test_s3_service.py`: Unit tests for S3 operations (mocked)
       476 +  
       477 +  **Configuration:**
       478 +  - Update `src/config.py`: Add S3 settings (bucket, region, credentials)
       479 +  
       480 +  **Dependencies:**
       481 +  - Add to `requirements.txt`: `boto3==1.34.7` for AWS S3 SDK
       482 +  
       483 +  ---
       484 +  
       485 +  ### Database Migration
       486 +  
       487 +  **Migration needed**: Create `attachments` table
       488 +  
       489 +  Since Alembic is not currently set up, use database initialization:
       490 +  
       491 +  **Update `src/database.py`**:
       492 +  - Import Attachment model to ensure table creation
       493 +  - `init_db()` will create table via `Base.metadata.create_all()`
       494 +  
       495 +  **Future**: Set up Alembic for proper migrations:
       496 +  ```bash
       497 +  alembic init alembic
       498 +  alembic revision --autogenerate -m "Add attachments table"
       499 +  alembic upgrade head
       500 +  ```
       501 +  
       502 +  ---
       503 +  
       504 +  ### Integration Flow
       505 +  
       506 +  1. **Update Task model**: Add `attachments` relationship
       507 +  2. **Create Attachment model**: Define SQLAlchemy model
       508 +  3. **Create AttachmentRepository**: Implement repository pattern
       509 +  4. **Create S3Service**: Implement S3 operations with boto3
       510 +  5. **Create AttachmentService**: Implement business logic, coordinate repo + S3
       511 +  6. **Create Attachment schemas**: Define Pydantic models
       512 +  7. **Create API router**: Implement endpoints using service layer
       513 +  8. **Update main.py**: Include attachment router
       514 +  9. **Update config.py**: Add S3 configuration settings
       515 +  10. **Write tests**: Integration tests for API, unit tests for services
       516 +  11. **Update requirements.txt**: Add boto3 dependency
       517 +  
       518 +  ### Dependency Chain
       519 +  ```
       520 +  API Router → AttachmentService → AttachmentRepository → Database
       521 +                               ↓
       522 +                           S3Service → AWS S3
       523 +  ```
       524 +  
       525 +  All new code follows CLAUDE.md patterns:
       526 +  - Repository pattern for database access
       527 +  - Service layer for business logic
       528 +  - Dependency injection via FastAPI Depends()
       529 +  - UUID primary keys, timezone-aware timestamps
       530 +  - HTTPException for errors with clear messages
       531 +  - Integration tests using TestClient fixtures
       532   \ No newline at end of file

● Technical Plan Complete

  I've filled out the complete technical plan for the Task Attachments feature at
  /usercode/FILESYSTEM/workspace/unit-4/task-1/technical_plan.md.

  Key Highlights

  Architecture (Section 1)
  - Request flow: Client → API Router → Service Layer → Repository → Database + S3
  - 4 components: AttachmentRouter, AttachmentService, AttachmentRepository, S3Service
  - Rollback strategy for S3 upload failures

  Data Model (Section 2)
  - Complete Attachment model with 8 columns (UUID primary key, foreign keys to Task/User)
  - Relationship addition to existing Task model
  - CASCADE delete when task is deleted

  Storage Strategy (Section 3)
  - S3 key format: attachments/{task_id}/{attachment_id}/{filename}
  - Configurable bucket name and region
  - Rationale: task grouping enables efficient cleanup

  Validation Rules (Section 4)
  - Allowed: images, PDFs, docs (docx, xlsx), archives
  - Max file size: 10 MB
  - Filename sanitization to prevent path traversal
  - Clear error messages following CLAUDE.md pattern

  API Contracts (Section 5)
  - POST /api/tasks/{task_id}/attachments - upload
  - GET /api/tasks/{task_id}/attachments - list
  - GET /api/attachments/{attachment_id}/download - presigned URL
  - DELETE /api/attachments/{attachment_id} - delete
  - Complete request/response formats and error codes for each

  Security (Section 6)
  - Authorization: task ownership verification for all operations
  - Presigned URLs: 1-hour expiration
  - Protection against: path traversal, file bombs, MIME confusion, SSRF
  - Input sanitization for filenames and MIME types

  Integration Points (Section 7)
  - Reuses: get_current_user, get_db, Task model, error handling patterns, test fixtures
  - Creates: Attachment model, AttachmentRepository, AttachmentService, S3Service, schemas, API routes,
   tests
  - Updates: config.py (S3 settings), Task model (relationship), requirements.txt (boto3)
  - Migration: Uses init_db() since Alembic not set up; notes future Alembic setup

  The plan is specific enough for task decomposition into individual implementation steps while
  following all CLAUDE.md patterns (repository pattern, service layer, dependency injection, UUID keys,
   timezone-aware timestamps).

> Review @technical_plan.md. Make every section concrete: component flow, DB columns, S3 key format, 
MIME list, size limit, virus scanning, API request and response bodies, error codes, auth rules, 
integration files, and migration notes. Fix gaps only. 

● I'll review the technical plan section by section and fix any gaps to ensure everything is concrete
  and actionable.

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 100 lines

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 150 lines

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 91 lines

● I'll review the technical plan and fix gaps to make every section fully concrete and actionable.

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 9 additions                            
       29    - CRUD operations for Attachment model
       30    - Query attachments by task_id
       31    - Transaction management with database session
       32 +  - Method signatures:
       33 +    - `create(attachment_data: dict) -> Attachment`
       34 +    - `get_by_id(attachment_id: UUID) -> Optional[Attachment]`
       35 +    - `list_by_task(task_id: UUID) -> List[Attachment]`
       36 +    - `delete(attachment_id: UUID) -> bool`
       37    
       38    **S3Service** (`src/services/s3_service.py`)
       39    - Upload files to S3 with unique keys
       40    - Delete files from S3
       41    - Generate presigned download URLs
       42    - Handle S3 client exceptions
       43 +  - Method signatures:
       44 +    - `upload_file(file_content: bytes, s3_key: str) -> str` (returns s3_key)
       45 +    - `delete_file(s3_key: str) -> bool`
       46 +    - `generate_presigned_url(s3_key: str, expiration: int = 3600) -> str` (returns URL)
       47    
       48    ### Upload Data Flow
       49    1. Client sends multipart/form-data to POST `/api/tasks/{task_id}/attachments`

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 5 additions                     
       24    - Generate presigned URLs for downloads
       25    - Handle deletion: database delete → S3 cleanup
       26    - Implement rollback logic on failures
       27 +  - Method signatures:
       28 +    - `upload(task_id: UUID, file: UploadFile, current_user: User) -> Attachment`
       29 +    - `list_by_task(task_id: UUID, current_user: User) -> List[Attachment]`
       30 +    - `get_download_url(attachment_id: UUID, current_user: User) -> dict`
       31 +    - `delete(attachment_id: UUID, current_user: User) -> bool`
       32    
       33    **AttachmentRepository** (`src/repositories/attachment_repository.py`)
       34    - CRUD operations for Attachment model

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 3 additions and 1 removal         
       100    
       101    ### Updates to Existing Models
       102    
       103 -  **Task Model** (`src/models/task.py`) - Add relationship:
       103 +  **Task Model** (`src/models/task.py`) - Add relationship
           +   after line 33 (after `comments` relationship):
       104    ```python
       105    attachments = relationship("Attachment", back_populates="task", cascade="all, 
             delete-orphan")
       106    ```
       107    
       108 +  **Location**: Insert in Task class definition, after the existing relationships.
       109 +  
       110    ### Indexes
       111    - `task_id`: For efficient querying attachments by task (created via ForeignKey 
             index=True)
       112    - `s3_key`: Unique constraint to prevent duplicate S3 keys

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 5 additions and 2 removals           
       196    - **Reject**: Null bytes, control characters
       197    
       198    ### Virus Scanning
       199 -  - **MVP approach**: Skip virus scanning (note as future enhancement)
       200 -  - **Future**: Integrate AWS S3 bucket scanning or ClamAV
       199 +  - **MVP implementation**: No virus scanning code required
       200 +  - **Rationale**: Reduces initial complexity; MIME type validation provides basic 
           + protection
       201 +  - **Implementation**: Simply do not include virus scanning logic in upload flow
       202 +  - **Future enhancement**: Integrate AWS S3 bucket scanning (Amazon GuardDuty) or 
           + ClamAV
       203 +  - **Documentation**: Add comment in upload service method noting virus scanning as 
           + TODO
       204    
       205    ### Error Message Formats
       206    

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 46 additions and 9 removals         
       239    
       240    **Request**: multipart/form-data
       241    ```
       242 -  Content-Type: multipart/form-data
       242 +  POST /api/tasks/550e8400-e29b-41d4-a716-446655440000/attachments
       243 +  Authorization: Bearer <token>
       244 +  Content-Type: multipart/form-data; boundary=----WebKitFormBoundary
       245    
       246 -  file: <binary data>
       246 +  ------WebKitFormBoundary
       247 +  Content-Disposition: form-data; name="file"; filename="project_diagram.png"
       248 +  Content-Type: image/png
       249 +  
       250 +  <binary file data>
       251 +  ------WebKitFormBoundary--
       252    ```
       253    
       254 +  **Field name**: `file` (required)
       255 +  
       256    **Response 201 Created:**
       257    ```json
       258    {
     ...
       258    ```
       259    
       260    **Error Responses:**
       261 -  - `400 Bad Request`: No file provided, invalid filename
       262 -  - `401 Unauthorized`: Missing or invalid token
       263 -  - `403 Forbidden`: Not task owner
       264 -  - `404 Not Found`: Task not found
       265 -  - `413 Payload Too Large`: File exceeds 10MB
       266 -  - `415 Unsupported Media Type`: Invalid MIME type
       267 -  - `500 Internal Server Error`: S3 or database failure
       261    
       262 +  `400 Bad Request` - No file provided:
       263 +  ```json
       264 +  {"detail": "No file provided in request"}
       265 +  ```
       266 +  
       267 +  `401 Unauthorized` - Missing or invalid token:
       268 +  ```json
       269 +  {"detail": "Could not validate credentials"}
       270 +  ```
       271 +  
       272 +  `403 Forbidden` - Not task owner:
       273 +  ```json
       274 +  {"detail": "Not authorized to upload attachments to this task"}
       275 +  ```
       276 +  
       277 +  `404 Not Found` - Task not found:
       278 +  ```json
       279 +  {"detail": "Task 550e8400-e29b-41d4-a716-446655440000 not found"}
       280 +  ```
       281 +  
       282 +  `413 Payload Too Large` - File exceeds limit:
       283 +  ```json
       284 +  {"detail": "File size 15.2MB exceeds maximum allowed size of 10MB"}
       285 +  ```
       286 +  
       287 +  `415 Unsupported Media Type` - Invalid MIME type:
       288 +  ```json
       289 +  {"detail": "File type 'application/exe' not allowed. Allowed types: images, PDFs, 
           + documents, archives"}
       290 +  ```
       291 +  
       292 +  `500 Internal Server Error` - S3 or database failure:
       293 +  ```json
       294 +  {"detail": "Failed to upload file to storage. Please try again"}
       295 +  ```
       296 +  
       297    ---
       298    
       299    ### GET /api/tasks/{task_id}/attachments

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 15 additions and 3 removals
       331    ```
       332    
       333    **Error Responses:**
       334 -  - `401 Unauthorized`: Missing or invalid token
       335 -  - `403 Forbidden`: Not task owner
       336 -  - `404 Not Found`: Task not found
       334    
       335 +  `401 Unauthorized`:
       336 +  ```json
       337 +  {"detail": "Could not validate credentials"}
       338 +  ```
       339 +  
       340 +  `403 Forbidden`:
       341 +  ```json
       342 +  {"detail": "Not authorized to access this task"}
       343 +  ```
       344 +  
       345 +  `404 Not Found`:
       346 +  ```json
       347 +  {"detail": "Task 550e8400-e29b-41d4-a716-446655440000 not found"}
       348 +  ```
       349 +  
       350    ---
       351    
       352    ### GET /api/attachments/{attachment_id}/download

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 20 additions and 4 removals
       366    ```
       367    
       368    **Error Responses:**
       369 -  - `401 Unauthorized`: Missing or invalid token
       370 -  - `403 Forbidden`: Not authorized to access this attachment
       371 -  - `404 Not Found`: Attachment not found
       372 -  - `500 Internal Server Error`: Failed to generate presigned URL
       369    
       370 +  `401 Unauthorized`:
       371 +  ```json
       372 +  {"detail": "Could not validate credentials"}
       373 +  ```
       374 +  
       375 +  `403 Forbidden`:
       376 +  ```json
       377 +  {"detail": "Not authorized to access this attachment"}
       378 +  ```
       379 +  
       380 +  `404 Not Found`:
       381 +  ```json
       382 +  {"detail": "Attachment 7c9e6679-7425-40de-944b-e07fc1f90ae7 not found"}
       383 +  ```
       384 +  
       385 +  `500 Internal Server Error`:
       386 +  ```json
       387 +  {"detail": "Failed to generate download URL. Please try again"}
       388 +  ```
       389 +  
       390    ---
       391    
       392    ### DELETE /api/attachments/{attachment_id}

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 20 additions and 4 removals
       399    **Response 204 No Content**
       400    
       401    **Error Responses:**
       402 -  - `401 Unauthorized`: Missing or invalid token
       403 -  - `403 Forbidden`: Not authorized to delete this attachment
       404 -  - `404 Not Found`: Attachment not found
       405 -  - `500 Internal Server Error`: Failed to delete from S3 or database
       402    
       403 +  `401 Unauthorized`:
       404 +  ```json
       405 +  {"detail": "Could not validate credentials"}
       406 +  ```
       407 +  
       408 +  `403 Forbidden`:
       409 +  ```json
       410 +  {"detail": "Not authorized to delete this attachment"}
       411 +  ```
       412 +  
       413 +  `404 Not Found`:
       414 +  ```json
       415 +  {"detail": "Attachment 7c9e6679-7425-40de-944b-e07fc1f90ae7 not found"}
       416 +  ```
       417 +  
       418 +  `500 Internal Server Error`:
       419 +  ```json
       420 +  {"detail": "Failed to delete attachment. Please try again"}
       421 +  ```
       422 +  
       423    ---
       424    
       425    ## 6. Security Considerations

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 15 additions and 6 removals           
       426    
       427    ### Authorization Rules
       428    
       429 +  All authorization checks implemented in **AttachmentService** layer (not in router).
       430 +  
       431    **Upload** (`POST /api/tasks/{task_id}/attachments`):
       432 -  - User must be authenticated
       433 -  - User must be the owner of the task (`task.owner_id == current_user.id`)
       432 +  - User must be authenticated (verified by `get_current_user` dependency in router)
       433 +  - Service validates: `task.owner_id == current_user.id`
       434 +  - Raise `HTTPException(403)` if not owner
       435    
       436    **List** (`GET /api/tasks/{task_id}/attachments`):
       437    - User must be authenticated
       438 -  - User must be the owner of the task
       438 +  - Service validates: `task.owner_id == current_user.id`
       439 +  - Raise `HTTPException(403)` if not owner
       440    
       441    **Download** (`GET /api/attachments/{attachment_id}/download`):
       442    - User must be authenticated
       443 -  - User must be owner of the task that attachment belongs to
       444 -  - Check: `attachment.task.owner_id == current_user.id`
       443 +  - Service retrieves attachment with task relationship
       444 +  - Service validates: `attachment.task.owner_id == current_user.id`
       445 +  - Raise `HTTPException(403)` if not owner
       446    
       447    **Delete** (`DELETE /api/attachments/{attachment_id}`):
       448    - User must be authenticated
       449 -  - User must be owner of the task that attachment belongs to
       449 +  - Service retrieves attachment with task relationship
       450 +  - Service validates: `attachment.task.owner_id == current_user.id`
       451 +  - Raise `HTTPException(403)` if not owner
       452    
       453 +  **Pattern**: Router handles authentication, Service handles authorization
       454 +  
       455    ### Presigned URL Strategy
       456    - **Expiration**: 1 hour (3600 seconds)
       457    - **Method**: GET only

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 44 additions and 6 removals             
       558    
       559    **Repositories:**
       560    - `src/repositories/attachment_repository.py`: AttachmentRepository class
       561 -    - Methods: `create()`, `get_by_id()`, `list_by_task()`, `delete()`
       561 +    ```python
       562 +    class AttachmentRepository:
       563 +        def __init__(self, db: Session = Depends(get_db))
       564 +        def create(self, attachment_data: dict) -> Attachment
       565 +        def get_by_id(self, attachment_id: UUID) -> Optional[Attachment]
       566 +        def list_by_task(self, task_id: UUID) -> List[Attachment]
       567 +        def delete(self, attachment_id: UUID) -> bool
       568 +    ```
       569    
       570    **Services:**
       571    - `src/services/attachment_service.py`: AttachmentService class
       572 -    - Methods: `upload()`, `list_by_task()`, `get_download_url()`, `delete()`
       572 +    ```python
       573 +    class AttachmentService:
       574 +        def __init__(self, repository: AttachmentRepository = Depends(), s3_service: 
           + S3Service = Depends())
       575 +        def upload(self, task_id: UUID, file: UploadFile, current_user: User, db: 
           + Session) -> Attachment
       576 +        def list_by_task(self, task_id: UUID, current_user: User, db: Session) -> 
           + List[Attachment]
       577 +        def get_download_url(self, attachment_id: UUID, current_user: User, db: Session)
           +  -> dict
       578 +        def delete(self, attachment_id: UUID, current_user: User, db: Session) -> bool
       579 +    ```
       580 +  
       581    - `src/services/s3_service.py`: S3Service class
       582 -    - Methods: `upload_file()`, `delete_file()`, `generate_presigned_url()`
       582 +    ```python
       583 +    class S3Service:
       584 +        def __init__(self)  # Initialize boto3 client
       585 +        def upload_file(self, file_content: bytes, s3_key: str) -> str
       586 +        def delete_file(self, s3_key: str) -> bool
       587 +        def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str
       588 +    ```
       589    
       590    **Schemas:**
       591    - `src/schemas/attachment.py`: Pydantic schemas
       592 -    - `AttachmentResponse`: Response schema
       593 -    - `AttachmentList`: List response schema
       594 -    - `AttachmentDownloadResponse`: Download URL response
       592 +    ```python
       593 +    class AttachmentResponse(BaseModel):
       594 +        id: UUID
       595 +        task_id: UUID
       596 +        filename: str
       597 +        file_size: int
       598 +        mime_type: str
       599 +        uploader_id: UUID
       600 +        created_at: datetime
       601 +        model_config = ConfigDict(from_attributes=True)
       602    
       603 +    class AttachmentList(BaseModel):
       604 +        attachments: List[AttachmentResponse]
       605 +        total: int
       606 +  
       607 +    class AttachmentDownloadResponse(BaseModel):
       608 +        download_url: str
       609 +        expires_in: int
       610 +        filename: str
       611 +    ```
       612 +  
       613    **API Routes:**
       614    - `src/api/attachments.py`: FastAPI router with 4 endpoints
       615      - Add to `src/api/__init__.py` exports

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 19 additions and 2 removals           
       612    
       613    **API Routes:**
       614    - `src/api/attachments.py`: FastAPI router with 4 endpoints
       615 -    - Add to `src/api/__init__.py` exports
       616 -    - Include router in `src/main.py`
       615 +    ```python
       616 +    router = APIRouter(prefix="/api", tags=["Attachments"])
       617    
       618 +    @router.post("/tasks/{task_id}/attachments", response_model=AttachmentResponse, 
           + status_code=201)
       619 +    @router.get("/tasks/{task_id}/attachments", response_model=AttachmentList)
       620 +    @router.get("/attachments/{attachment_id}/download", 
           + response_model=AttachmentDownloadResponse)
       621 +    @router.delete("/attachments/{attachment_id}", status_code=204)
       622 +    ```
       623 +  
       624 +  - Update `src/api/__init__.py`:
       625 +    ```python
       626 +    from .attachments import router as attachments_router
       627 +    __all__ = ["auth_router", "tasks_router", "comments_router", "attachments_router"]
       628 +    ```
       629 +  
       630 +  - Update `src/main.py` line 38 (after comments_router):
       631 +    ```python
       632 +    app.include_router(attachments_router)
       633 +    ```
       634 +  
       635    **Tests:**
       636    - `tests/test_attachment_api.py`: Integration tests for all endpoints
       637    - `tests/test_attachment_service.py`: Unit tests for service layer

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 18 additions and 2 removals             
       634    
       635    **Tests:**
       636    - `tests/test_attachment_api.py`: Integration tests for all endpoints
       637 -  - `tests/test_attachment_service.py`: Unit tests for service layer
       638 -  - `tests/test_s3_service.py`: Unit tests for S3 operations (mocked)
       637 +    - `test_upload_attachment()` - 201 success case
       638 +    - `test_upload_no_file()` - 400 error
       639 +    - `test_upload_file_too_large()` - 413 error
       640 +    - `test_upload_invalid_mime_type()` - 415 error
       641 +    - `test_upload_unauthorized()` - 403 error
       642 +    - `test_list_attachments()` - 200 success
       643 +    - `test_get_download_url()` - 200 success
       644 +    - `test_delete_attachment()` - 204 success
       645    
       646 +  - `tests/test_attachment_service.py`: Unit tests for service layer (with mocked repo &
           +  S3)
       647 +    - `test_upload_validates_task_ownership()`
       648 +    - `test_upload_rollback_on_db_failure()`
       649 +    - `test_delete_removes_from_s3_and_db()`
       650 +  
       651 +  - `tests/test_s3_service.py`: Unit tests for S3 operations (mocked boto3)
       652 +    - `test_upload_file_success()`
       653 +    - `test_generate_presigned_url()`
       654 +    - `test_delete_file_success()`
       655 +  
       656    **Configuration:**
       657    - Update `src/config.py`: Add S3 settings (bucket, region, credentials)
       658    

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 14 additions and 2 removals
       654      - `test_delete_file_success()`
       655    
       656    **Configuration:**
       657 -  - Update `src/config.py`: Add S3 settings (bucket, region, credentials)
       657 +  - Update `src/config.py` Settings class (add after line 14):
       658 +    ```python
       659 +    # S3 Configuration
       660 +    s3_bucket_name: str = "taskmaster-attachments"
       661 +    s3_region: str = "us-east-1"
       662 +    aws_access_key_id: str = ""
       663 +    aws_secret_access_key: str = ""
       664 +    max_upload_size: int = 10485760  # 10 MB in bytes
       665 +    ```
       666    
       667    **Dependencies:**
       668 -  - Add to `requirements.txt`: `boto3==1.34.7` for AWS S3 SDK
       668 +  - Add to `requirements.txt` (after line 20):
       669 +    ```
       670 +    boto3==1.34.7
       671 +    python-multipart==0.0.20  # Already present, needed for file uploads
       672 +    ```
       673    
       674    ---
       675    

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 18 additions and 3 removals     
       679    
       680    Since Alembic is not currently set up, use database initialization:
       681    
       682 -  **Update `src/database.py`**:
       683 -  - Import Attachment model to ensure table creation
       684 -  - `init_db()` will create table via `Base.metadata.create_all()`
       682 +  **Update `src/database.py`** (add import at top of file, around line 6):
       683 +  ```python
       684 +  from .models.attachment import Attachment  # Ensure model is imported
       685 +  ```
       686    
       687 +  This ensures the Attachment table is created when `init_db()` calls 
           + `Base.metadata.create_all()`.
       688 +  
       689 +  **Alternative**: Import in `src/models/__init__.py` (add to existing imports):
       690 +  ```python
       691 +  from .attachment import Attachment
       692 +  ```
       693 +  
       694    **Future**: Set up Alembic for proper migrations:
       695    ```bash
       696    alembic init alembic
       697 +  # Edit alembic.ini and alembic/env.py to configure database
       698    alembic revision --autogenerate -m "Add attachments table"
       699    alembic upgrade head
       700    ```
       701    
       702 +  **Verification**: After running app, check table exists:
       703 +  ```sql
       704 +  \dt attachments  -- in psql
       705 +  SELECT * FROM attachments LIMIT 1;
       706 +  ```
       707 +  
       708    ---
       709    
       710    ### Integration Flow

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 19 additions and 12 removals           
       707    
       708    ---
       709    
       710 -  ### Integration Flow
       710 +  ### Integration Flow (Implementation Order)
       711    
       712 -  1. **Update Task model**: Add `attachments` relationship
       713 -  2. **Create Attachment model**: Define SQLAlchemy model
       714 -  3. **Create AttachmentRepository**: Implement repository pattern
       715 -  4. **Create S3Service**: Implement S3 operations with boto3
       716 -  5. **Create AttachmentService**: Implement business logic, coordinate repo + S3
       717 -  6. **Create Attachment schemas**: Define Pydantic models
       718 -  7. **Create API router**: Implement endpoints using service layer
       719 -  8. **Update main.py**: Include attachment router
       720 -  9. **Update config.py**: Add S3 configuration settings
       721 -  10. **Write tests**: Integration tests for API, unit tests for services
       722 -  11. **Update requirements.txt**: Add boto3 dependency
       712 +  1. **Update requirements.txt**: Add `boto3==1.34.7` (line 21)
       713 +  2. **Update config.py**: Add S3 settings to Settings class (after line 14)
       714 +  3. **Create Attachment model**: `src/models/attachment.py` (complete file)
       715 +  4. **Update Task model**: Add `attachments` relationship in `src/models/task.py` 
           + (after line 33)
       716 +  5. **Update models __init__.py**: Import Attachment in `src/models/__init__.py`
       717 +  6. **Create repository directory**: `mkdir src/repositories`
       718 +  7. **Create AttachmentRepository**: `src/repositories/attachment_repository.py` 
           + (complete file)
       719 +  8. **Create S3Service**: `src/services/s3_service.py` (complete file)
       720 +  9. **Create AttachmentService**: `src/services/attachment_service.py` (complete file)
       721 +  10. **Create Attachment schemas**: `src/schemas/attachment.py` (complete file)
       722 +  11. **Create API router**: `src/api/attachments.py` (complete file)
       723 +  12. **Update api __init__.py**: Add attachments_router export (line 6-7)
       724 +  13. **Update main.py**: Include attachments_router (after line 38)
       725 +  14. **Write test fixtures**: Update `tests/conftest.py` if needed for S3 mocking
       726 +  15. **Write integration tests**: `tests/test_attachment_api.py` (complete file)
       727 +  16. **Write unit tests**: `tests/test_attachment_service.py` and 
           + `tests/test_s3_service.py`
       728 +  17. **Run tests**: `pytest tests/test_attachment_*.py -v`
       729 +  18. **Run application**: Verify table creation in database
       730    
       731    ### Dependency Chain
       732    ```

● Technical Plan Review Complete

  I've reviewed and fixed all gaps to make every section fully concrete and actionable:

  Fixes Applied

  1. Architecture (Section 1)
  - ✓ Added complete method signatures for all Repository and Service classes
  - ✓ Specified exact parameters and return types for each method

  2. Data Model (Section 2)
  - ✓ Specified exact line location (after line 33) for Task model relationship update
  - ✓ Added clear insertion point guidance

  3. Storage Strategy (Section 3)
  - ✓ Already concrete - no changes needed

  4. Validation Rules (Section 4)
  - ✓ Clarified virus scanning: "No virus scanning code required" for MVP
  - ✓ Added rationale and implementation note (simply omit the logic)
  - ✓ Added documentation requirement (comment in code)

  5. API Contracts (Section 5)
  - ✓ Made multipart/form-data format concrete with full HTTP example
  - ✓ Specified field name: file (required)
  - ✓ Added complete JSON error response bodies for ALL error codes (400, 401, 403, 404, 413, 415, 500)
  - ✓ Applied to all 4 endpoints (upload, list, download, delete)

  6. Security Considerations (Section 6)
  - ✓ Clarified authorization happens in AttachmentService layer (not router)
  - ✓ Added pattern note: "Router handles authentication, Service handles authorization"
  - ✓ Specified exact checks for each operation with code examples

  7. Integration Points (Section 7)
  - ✓ Added complete class signatures for Repository, Service, and S3Service
  - ✓ Added complete Pydantic schema definitions with all fields
  - ✓ Added router endpoint decorators with exact signatures
  - ✓ Specified exact file/line locations for all updates:
    - src/config.py after line 14
    - src/models/task.py after line 33
    - src/main.py after line 38
    - requirements.txt after line 20
  - ✓ Added complete test function names for all 3 test files
  - ✓ Added specific database migration instructions with import location
  - ✓ Added verification SQL commands
  - ✓ Converted Integration Flow to Implementation Order with 18 numbered steps
  - ✓ Added specific line numbers and file locations for each step

  Result

  Every section now contains:
  - Concrete component flows with method signatures
  - Complete DB column definitions with exact SQLAlchemy code
  - Exact S3 key format with examples
  - Complete MIME type list
  - Specific file size limit (10,485,760 bytes)
  - Clear virus scanning approach (skip for MVP)
  - Full API request/response bodies with multipart format details
  - Complete error codes with JSON response bodies
  - Detailed auth rules with implementation layer specified
  - Specific integration file paths with line numbers
  - Step-by-step migration notes with verification commands

  The plan is now ready for task decomposition and implementation.

> Check @technical_plan.md against the assignment. Confirm all 7 sections are complete: Architecture, 
Data Model, Storage, Validation, API, Security, Integration. Report only missing or vague items. 

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 744 lines

● All 7 sections are present and mostly complete. Here are the missing or vague items:

  Missing/Vague Items

  Section 1: Architecture

  VAGUE - Repository/Service database session handling:
  - AttachmentRepository.init shows db: Session = Depends(get_db)
  - But AttachmentService methods also show db: Session parameter
  - Issue: If repository gets db via Depends, service shouldn't pass it again. Design is ambiguous
  about who owns the session.
  - Fix needed: Clarify whether service passes db to repository methods, or repository holds db as
  instance variable.

  Section 4: Validation Rules

  VAGUE - MIME type validation method:
  - States: "Use python-magic or file header inspection (not just extension)"
  - Issue: "or" means choice is unclear. Implementation needs concrete decision.
  - Fix needed: Specify exactly which approach to use (e.g., "Use python-magic library" OR "Implement
  file header inspection with magic numbers")

  Section 6: Security Considerations

  VAGUE - MIME type validation (duplicate issue):
  - Same "python-magic or file header inspection" ambiguity
  - Fix needed: Be concrete about which validation method to implement

  Section 7: Integration Points

  INCOMPLETE - Repository method signature:
  - Shows: def __init__(self, db: Session = Depends(get_db))
  - Issue: Missing method body/implementation note
  - Fix needed: Add complete signature or note about implementation

  VAGUE - S3Service initialization:
  - Shows: def __init__(self)  # Initialize boto3 client
  - Issue: No details on how boto3 client is initialized (credentials source, config parameters)
  - Fix needed: Specify initialization like: self.s3_client = boto3.client('s3', 
  region_name=settings.s3_region, aws_access_key_id=settings.aws_access_key_id, 
  aws_secret_access_key=settings.aws_secret_access_key)

  MISSING - Repository init.py file:
  - Integration Flow step 6 says "Create repository directory: mkdir src/repositories"
  - Issue: No mention of creating src/repositories/__init__.py file
  - Fix needed: Add step to create empty __init__.py or specify imports

  Summary

  - 4 vague items: db session handling, MIME validation method (2 places), S3Service init
  - 2 incomplete items: Repository signature, repository init.py
  - All sections exist but need these 6 concrete clarifications for implementation.

> Fix only the missing or vague items in @technical_plan.md. Do not add extra sections. 

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 6 additions and 5 removals        
       33    **AttachmentRepository** (`src/repositories/attachment_repository.py`)
       34    - CRUD operations for Attachment model
       35    - Query attachments by task_id
       36 -  - Transaction management with database session
       36 +  - Transaction management with database session (stored as instance variable)
       37    - Method signatures:
       38 -    - `create(attachment_data: dict) -> Attachment`
       39 -    - `get_by_id(attachment_id: UUID) -> Optional[Attachment]`
       40 -    - `list_by_task(task_id: UUID) -> List[Attachment]`
       41 -    - `delete(attachment_id: UUID) -> bool`
       38 +    - `__init__(self, db: Session = Depends(get_db))` - Store db session as self.db
       39 +    - `create(attachment_data: dict) -> Attachment` - Use self.db
       40 +    - `get_by_id(attachment_id: UUID) -> Optional[Attachment]` - Use self.db
       41 +    - `list_by_task(task_id: UUID) -> List[Attachment]` - Use self.db
       42 +    - `delete(attachment_id: UUID) -> bool` - Use self.db
       43    
       44    **S3Service** (`src/services/s3_service.py`)
       45    - Upload files to S3 with unique keys

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 7 additions and 5 removals              
       24    - Generate presigned URLs for downloads
       25    - Handle deletion: database delete → S3 cleanup
       26    - Implement rollback logic on failures
       27 -  - Method signatures:
       28 -    - `upload(task_id: UUID, file: UploadFile, current_user: User) -> Attachment`
       29 -    - `list_by_task(task_id: UUID, current_user: User) -> List[Attachment]`
       30 -    - `get_download_url(attachment_id: UUID, current_user: User) -> dict`
       31 -    - `delete(attachment_id: UUID, current_user: User) -> bool`
       27 +  - Method signatures (repository and db passed via __init__, not as method params):
       28 +    - `__init__(self, repository: AttachmentRepository = Depends(), s3_service: S3Service
          +  = Depends())`
       29 +    - `upload(task_id: UUID, file: UploadFile, current_user: User, db: Session) -> 
          +  Attachment`
       30 +    - `list_by_task(task_id: UUID, current_user: User, db: Session) -> List[Attachment]`
       31 +    - `get_download_url(attachment_id: UUID, current_user: User, db: Session) -> dict`
       32 +    - `delete(attachment_id: UUID, current_user: User, db: Session) -> bool`
       33 +  - Note: db session passed to methods for Task model queries (not for repository, which 
          + gets its own db)
       34    
       35    **AttachmentRepository** (`src/repositories/attachment_repository.py`)
       36    - CRUD operations for Attachment model

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 3 additions and 2 removals         
       475    ```
       476    
       477    **MIME type validation**:
       478 -  - Use `python-magic` or file header inspection (not just extension)
       478 +  - Use FastAPI's UploadFile.content_type (relies on browser-provided MIME type)
       479 +  - Validate against ALLOWED_MIME_TYPES whitelist
       480    - Reject files with mismatched MIME types
       481 -  - Whitelist approach (explicit allowed types)
       481 +  - Note: For production, consider adding `python-magic` library for content-based 
           + validation
       482    
       483    **File size validation**:
       484    - Check `Content-Length` header before reading file

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 3 additions and 2 removals     
       496    - Validate MIME type before processing
       497    
       498    **MIME Type Confusion**:
       499 -  - Validate actual file content, not just extension
       500 -  - Use magic number detection
       499 +  - MVP: Validate using browser-provided MIME type from UploadFile.content_type
       500 +  - Whitelist approach with ALLOWED_MIME_TYPES
       501 +  - Future enhancement: Add python-magic for magic number detection
       502    
       503    **SSRF (Server-Side Request Forgery)**:
       504    - S3 service uses boto3 with proper AWS credentials

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 2 additions and 1 removal  
       565    - `src/repositories/attachment_repository.py`: AttachmentRepository class
       566      ```python
       567      class AttachmentRepository:
       568 -        def __init__(self, db: Session = Depends(get_db))
       568 +        def __init__(self, db: Session = Depends(get_db)):
       569 +            self.db = db
       570          def create(self, attachment_data: dict) -> Attachment
       571          def get_by_id(self, attachment_id: UUID) -> Optional[Attachment]
       572          def list_by_task(self, task_id: UUID) -> List[Attachment]

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 12 additions and 2 removals             
       577    - `src/services/attachment_service.py`: AttachmentService class
       578      ```python
       579      class AttachmentService:
       580 -        def __init__(self, repository: AttachmentRepository = Depends(), s3_service: 
           -  S3Service = Depends())
       580 +        def __init__(self, repository: AttachmentRepository = Depends(), s3_service: 
           +  S3Service = Depends()):
       581 +            self.repository = repository
       582 +            self.s3_service = s3_service
       583          def upload(self, task_id: UUID, file: UploadFile, current_user: User, db: 
             Session) -> Attachment
       584          def list_by_task(self, task_id: UUID, current_user: User, db: Session) -> 
             List[Attachment]
       585          def get_download_url(self, attachment_id: UUID, current_user: User, db: Session)
              -> dict
     ...
       587    - `src/services/s3_service.py`: S3Service class
       588      ```python
       589      class S3Service:
       590 -        def __init__(self)  # Initialize boto3 client
       590 +        def __init__(self):
       591 +            settings = get_settings()
       592 +            self.s3_client = boto3.client(
       593 +                's3',
       594 +                region_name=settings.s3_region,
       595 +                aws_access_key_id=settings.aws_access_key_id,
       596 +                aws_secret_access_key=settings.aws_secret_access_key
       597 +            )
       598 +            self.bucket_name = settings.s3_bucket_name
       599          def upload_file(self, file_content: bytes, s3_key: str) -> str
       600          def delete_file(self, s3_key: str) -> bool
       601          def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 13 additions and 12 removals            
       731    4. **Update Task model**: Add `attachments` relationship in `src/models/task.py` 
             (after line 33)
       732    5. **Update models __init__.py**: Import Attachment in `src/models/__init__.py`
       733    6. **Create repository directory**: `mkdir src/repositories`
       734 -  7. **Create AttachmentRepository**: `src/repositories/attachment_repository.py` 
           - (complete file)
       735 -  8. **Create S3Service**: `src/services/s3_service.py` (complete file)
       736 -  9. **Create AttachmentService**: `src/services/attachment_service.py` (complete file)
       737 -  10. **Create Attachment schemas**: `src/schemas/attachment.py` (complete file)
       738 -  11. **Create API router**: `src/api/attachments.py` (complete file)
       739 -  12. **Update api __init__.py**: Add attachments_router export (line 6-7)
       740 -  13. **Update main.py**: Include attachments_router (after line 38)
       741 -  14. **Write test fixtures**: Update `tests/conftest.py` if needed for S3 mocking
       742 -  15. **Write integration tests**: `tests/test_attachment_api.py` (complete file)
       743 -  16. **Write unit tests**: `tests/test_attachment_service.py` and 
           - `tests/test_s3_service.py`
       744 -  17. **Run tests**: `pytest tests/test_attachment_*.py -v`
       745 -  18. **Run application**: Verify table creation in database
       734 +  7. **Create repository __init__.py**: `src/repositories/__init__.py` (empty file or 
           + with imports)
       735 +  8. **Create AttachmentRepository**: `src/repositories/attachment_repository.py` 
           + (complete file)
       736 +  9. **Create S3Service**: `src/services/s3_service.py` (complete file)
       737 +  10. **Create AttachmentService**: `src/services/attachment_service.py` (complete file)
       738 +  11. **Create Attachment schemas**: `src/schemas/attachment.py` (complete file)
       739 +  12. **Create API router**: `src/api/attachments.py` (complete file)
       740 +  13. **Update api __init__.py**: Add attachments_router export (line 6-7)
       741 +  14. **Update main.py**: Include attachments_router (after line 38)
       742 +  15. **Write test fixtures**: Update `tests/conftest.py` if needed for S3 mocking
       743 +  16. **Write integration tests**: `tests/test_attachment_api.py` (complete file)
       744 +  17. **Write unit tests**: `tests/test_attachment_service.py` and 
           + `tests/test_s3_service.py`
       745 +  18. **Run tests**: `pytest tests/test_attachment_*.py -v`
       746 +  19. **Run application**: Verify table creation in database
       747    
       748    ### Dependency Chain
       749    ```

● Fixes Applied

  All missing/vague items have been fixed:

  1. Database Session Handling (Section 1 & 7)

  - Fixed: Clarified that AttachmentRepository.__init__ stores db as self.db instance variable
  - Fixed: Added note that AttachmentService methods receive db: Session parameter for Task model
  queries (separate from repository's db)
  - Fixed: Completed __init__ method body in Section 7: self.db = db

  2. MIME Type Validation Method (Section 6)

  - Fixed: Made concrete choice - "Use FastAPI's UploadFile.content_type (relies on browser-provided
  MIME type)"
  - Fixed: Added note about python-magic as future production enhancement
  - Removed: Ambiguous "or" language

  3. MIME Type Validation in Security (Section 6)

  - Fixed: Changed "Use magic number detection" to concrete "MVP: Validate using browser-provided MIME
  type from UploadFile.content_type"
  - Fixed: Added "Future enhancement: Add python-magic for magic number detection"

  4. AttachmentService init Body (Section 7)

  - Fixed: Added complete constructor body storing dependencies as instance variables:
  self.repository = repository
  self.s3_service = s3_service

  5. S3Service Initialization (Section 7)

  - Fixed: Added complete boto3 client initialization with all parameters:
  settings = get_settings()
  self.s3_client = boto3.client(
      's3',
      region_name=settings.s3_region,
      aws_access_key_id=settings.aws_access_key_id,
      aws_secret_access_key=settings.aws_secret_access_key
  )
  self.bucket_name = settings.s3_bucket_name

  6. Repository init.py File (Section 7)

  - Fixed: Added step 7 to Integration Flow: "Create repository init.py: src/repositories/__init__.py
  (empty file or with imports)"

  All sections remain complete with no extra content added. Technical plan is now fully concrete and
  ready for implementation.

> Final check: Is @technical_plan.md specific enough that someone can decompose it into tasks without 
guessing architecture decisions? Answer pass/fail with reasons only. 

● FAIL

  Reasons:

  1. Database Session Architecture Ambiguity

  - Plan specifies Repository gets db via Depends(get_db) and stores as self.db
  - Plan also specifies Service methods receive separate db: Session parameter
  - Issue: Two database sessions in a single request creates transaction isolation problems
  - Guesswork required: Should implementer use one session or two? How do changes in one session affect
   the other? Who manages transaction boundaries?

  2. Transaction Management Unclear

  - Upload flow says "Repository commits transaction" (step 6)
  - Rollback strategy says "Delete uploaded file from S3" if database save fails
  - Issue: If Repository auto-commits in create(), Service can't rollback on failure
  - Guesswork required: Does Repository commit or just add to session? Does Service manage the
  transaction? Where's the try/except block?

  3. Dependency Injection Wiring Missing

  - Service __init__ shows: def __init__(self, repository: AttachmentRepository = Depends()...)
  - Issue: FastAPI Depends() doesn't work in nested class constructors - it only works in route
  function parameters
  - Guesswork required: How to actually inject Service into Router? How does dependency chain work?

  4. Router Function Signatures Incomplete

  - Section 7 shows only decorators: @router.post("/tasks/{task_id}/attachments"...)
  - Missing actual function signatures with parameters
  - Guesswork required: How to inject service, db, current_user, file parameters? What's the correct
  FastAPI pattern?

  5. Conflicting Patterns

  - Note says: "db session passed to methods for Task model queries (not for repository, which gets its
   own db)"
  - Issue: This suggests two separate sessions, which is unusual and error-prone
  - Guesswork required: Is this intentional or a design flaw? Should implementer follow it or fix it?

  Conclusion

  While data model, storage strategy, validation rules, and API contracts are concrete, the core 
  architecture for dependency injection and transaction management requires guessing. An implementer
  cannot build the service/repository layer without making architectural decisions about session
  handling and dependency wiring.

> Fix @technical_plan.md only where needed. Remove the literal TODO word. Make DB session handling use 
one Session per request. Add get_attachment_service(db: Session = Depends(get_db)) that creates 
AttachmentRepository(db), S3Service(), and AttachmentService(...). Repository must not use Depends and 
must not commit or rollback. Service owns commit, rollback, and S3 cleanup. Add complete router 
function signatures for all 4 endpoints. Do not add extra sections. 

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 8 additions and 8 removals              
       23    - Coordinate upload: S3 upload → database save
       24    - Generate presigned URLs for downloads
       25    - Handle deletion: database delete → S3 cleanup
       26 -  - Implement rollback logic on failures
       27 -  - Method signatures (repository and db passed via __init__, not as method params):
       28 -    - `__init__(self, repository: AttachmentRepository = Depends(), s3_service: S3Service
          -  = Depends())`
       29 -    - `upload(task_id: UUID, file: UploadFile, current_user: User, db: Session) -> 
          - Attachment`
       30 -    - `list_by_task(task_id: UUID, current_user: User, db: Session) -> List[Attachment]`
       31 -    - `get_download_url(attachment_id: UUID, current_user: User, db: Session) -> dict`
       32 -    - `delete(attachment_id: UUID, current_user: User, db: Session) -> bool`
       33 -  - Note: db session passed to methods for Task model queries (not for repository, which 
          - gets its own db)
       26 +  - Owns transaction management: commit on success, rollback on failure
       27 +  - Owns S3 cleanup on transaction failures
       28 +  - Method signatures:
       29 +    - `__init__(self, repository: AttachmentRepository, s3_service: S3Service, db: 
          + Session)`
       30 +    - `upload(task_id: UUID, file: UploadFile, current_user: User) -> Attachment`
       31 +    - `list_by_task(task_id: UUID, current_user: User) -> List[Attachment]`
       32 +    - `get_download_url(attachment_id: UUID, current_user: User) -> dict`
       33 +    - `delete(attachment_id: UUID, current_user: User) -> bool`
       34    
       35    **AttachmentRepository** (`src/repositories/attachment_repository.py`)
       36    - CRUD operations for Attachment model

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 6 additions and 6 removals           
       35    **AttachmentRepository** (`src/repositories/attachment_repository.py`)
       36    - CRUD operations for Attachment model
       37    - Query attachments by task_id
       38 -  - Transaction management with database session (stored as instance variable)
       38 +  - Does NOT commit or rollback (Service layer handles transactions)
       39    - Method signatures:
       40 -    - `__init__(self, db: Session = Depends(get_db))` - Store db session as self.db
       41 -    - `create(attachment_data: dict) -> Attachment` - Use self.db
       42 -    - `get_by_id(attachment_id: UUID) -> Optional[Attachment]` - Use self.db
       43 -    - `list_by_task(task_id: UUID) -> List[Attachment]` - Use self.db
       44 -    - `delete(attachment_id: UUID) -> bool` - Use self.db
       40 +    - `__init__(self, db: Session)` - Store db session as self.db
       41 +    - `create(attachment_data: dict) -> Attachment` - Adds to session, does NOT commit
       42 +    - `get_by_id(attachment_id: UUID) -> Optional[Attachment]` - Query only
       43 +    - `list_by_task(task_id: UUID) -> List[Attachment]` - Query only
       44 +    - `delete(attachment_id: UUID) -> bool` - Marks for deletion, does NOT commit
       45    
       46    **S3Service** (`src/services/s3_service.py`)
       47    - Upload files to S3 with unique keys

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 13 additions                           
       49    - Generate presigned download URLs
       50    - Handle S3 client exceptions
       51    - Method signatures:
       52 +    - `__init__(self)` - Initialize boto3 client from settings
       53      - `upload_file(file_content: bytes, s3_key: str) -> str` (returns s3_key)
       54      - `delete_file(s3_key: str) -> bool`
       55      - `generate_presigned_url(s3_key: str, expiration: int = 3600) -> str` (returns URL)
       56    
       57 +  **Dependency Factory** (`src/services/attachment_service.py`)
       58 +  - Function to wire dependencies with single DB session per request
       59 +  - Signature:
       60 +    - `get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService`
       61 +  - Implementation:
       62 +    ```python
       63 +    def get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService:
       64 +        repository = AttachmentRepository(db)
       65 +        s3_service = S3Service()
       66 +        return AttachmentService(repository, s3_service, db)
       67 +    ```
       68 +  
       69    ### Upload Data Flow
       70    1. Client sends multipart/form-data to POST `/api/tasks/{task_id}/attachments`
       71    2. Router extracts file, validates request, calls service

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 7 additions and 6 removals       
       68    
       69    ### Upload Data Flow
       70    1. Client sends multipart/form-data to POST `/api/tasks/{task_id}/attachments`
       71 -  2. Router extracts file, validates request, calls service
       72 -  3. Service validates file size/type and task ownership
       71 +  2. Router extracts file, calls service with current_user
       72 +  3. Service validates file size/type and verifies task ownership using db session
       73    4. Service calls S3Service to upload file → receives S3 key
       74 -  5. Service calls Repository to save attachment metadata
       75 -  6. Repository commits transaction
       76 -  7. Service returns attachment metadata to router
       77 -  8. Router returns 201 Created with attachment details
       74 +  5. Service calls Repository to add attachment metadata to db session
       75 +  6. Service commits transaction (db.commit())
       76 +  7. On success: Service returns attachment metadata to router
       77 +  8. On failure: Service rolls back db and deletes S3 file
       78 +  9. Router returns 201 Created with attachment details
       79    
       80    ### Rollback Strategy
       81    - **If S3 upload fails**: Return 500 error, no database record created

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 18 additions and 4 removals             
        77    8. On failure: Service rolls back db and deletes S3 file
        78    9. Router returns 201 Created with attachment details
        79    
        80 -  ### Rollback Strategy
        81 -  - **If S3 upload fails**: Return 500 error, no database record created
        82 -  - **If database save fails after S3 upload**: Delete uploaded file from S3, return 500
           -  error
        80 +  ### Rollback Strategy (Service Layer Responsibility)
        81 +  - **If S3 upload fails**: Raise exception, no database changes made, return 500 error
        82 +  - **If database commit fails after S3 upload**: Service calls db.rollback(), then 
           + calls s3_service.delete_file(s3_key), return 500 error
        83    - **If presigned URL generation fails**: Return 500 error, log issue
        84 -  - All database operations wrapped in try/except with session rollback
        84 +  - Service wraps all operations in try/except:
        85 +    ```python
        86 +    try:
        87 +        # Upload to S3
        88 +        s3_key = self.s3_service.upload_file(...)
        89 +        # Save to database
        90 +        attachment = self.repository.create(...)
        91 +        self.db.commit()
        92 +        return attachment
        93 +    except Exception:
        94 +        self.db.rollback()
        95 +        if s3_key:
        96 +            self.s3_service.delete_file(s3_key)
        97 +        raise
        98 +    ```
        99    
       100    ---
       101    

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 1 removal                            
       231    - **Rationale**: Reduces initial complexity; MIME type validation provides basic 
             protection
       232    - **Implementation**: Simply do not include virus scanning logic in upload flow
       233    - **Future enhancement**: Integrate AWS S3 bucket scanning (Amazon GuardDuty) or 
             ClamAV
       234 -  - **Documentation**: Add comment in upload service method noting virus scanning as 
           - TODO
       234    
       235    ### Error Message Formats
       236    

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 23 additions and 5 removals             
       592    - `src/repositories/attachment_repository.py`: AttachmentRepository class
       593      ```python
       594      class AttachmentRepository:
       595 -        def __init__(self, db: Session = Depends(get_db)):
       595 +        def __init__(self, db: Session):
       596              self.db = db
       597 -        def create(self, attachment_data: dict) -> Attachment
       598 -        def get_by_id(self, attachment_id: UUID) -> Optional[Attachment]
       599 -        def list_by_task(self, task_id: UUID) -> List[Attachment]
       600 -        def delete(self, attachment_id: UUID) -> bool
       597 +  
       598 +        def create(self, attachment_data: dict) -> Attachment:
       599 +            # Creates instance, adds to session, does NOT commit
       600 +            attachment = Attachment(**attachment_data)
       601 +            self.db.add(attachment)
       602 +            self.db.flush()  # Get ID without committing
       603 +            self.db.refresh(attachment)
       604 +            return attachment
       605 +  
       606 +        def get_by_id(self, attachment_id: UUID) -> Optional[Attachment]:
       607 +            return self.db.query(Attachment).filter(Attachment.id == 
           + attachment_id).first()
       608 +  
       609 +        def list_by_task(self, task_id: UUID) -> List[Attachment]:
       610 +            return self.db.query(Attachment).filter(Attachment.task_id == task_id).all()
       611 +  
       612 +        def delete(self, attachment_id: UUID) -> bool:
       613 +            # Marks for deletion, does NOT commit
       614 +            attachment = self.get_by_id(attachment_id)
       615 +            if attachment:
       616 +                self.db.delete(attachment)
       617 +                return True
       618 +            return False
       619      ```
       620    
       621    **Services:**

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 25 additions and 6 removals             
       619      ```
       620    
       621    **Services:**
       622 -  - `src/services/attachment_service.py`: AttachmentService class
       622 +  - `src/services/attachment_service.py`: AttachmentService class and dependency factory
       623      ```python
       624      class AttachmentService:
       625 -        def __init__(self, repository: AttachmentRepository = Depends()
           -  , s3_service: S3Service = Depends()):
       625 +        def __init__(self, repository: AttachmentRepository, s3_service: S3Service, db: 
           +  Session):
       626              self.repository = repository
       627              self.s3_service = s3_service
       628 -        def upload(self, task_id: UUID, file: UploadFile, current_user: User, db: 
           - Session) -> Attachment
       629 -        def list_by_task(self, task_id: UUID, current_user: User, db: Session) -> 
           - List[Attachment]
       630 -        def get_download_url(self, attachment_id: UUID, current_user: User, db: Session)
           -  -> dict
       631 -        def delete(self, attachment_id: UUID, current_user: User, db: Session) -> bool
       628 +            self.db = db
       629 +  
       630 +        def upload(self, task_id: UUID, file: UploadFile, current_user: User) -> 
           + Attachment:
       631 +            # Validate, upload to S3, save to DB, commit, handle rollback
       632 +            pass
       633 +  
       634 +        def list_by_task(self, task_id: UUID, current_user: User) -> List[Attachment]:
       635 +            # Verify task ownership, return attachments
       636 +            pass
       637 +  
       638 +        def get_download_url(self, attachment_id: UUID, current_user: User) -> dict:
       639 +            # Verify ownership, generate presigned URL
       640 +            pass
       641 +  
       642 +        def delete(self, attachment_id: UUID, current_user: User) -> bool:
       643 +            # Verify ownership, delete from DB, delete from S3, commit
       644 +            pass
       645 +  
       646 +    def get_attachment_service(db: Session = Depends(get_db)) -> AttachmentService:
       647 +        """Dependency factory: creates service with single DB session"""
       648 +        repository = AttachmentRepository(db)
       649 +        s3_service = S3Service()
       650 +        return AttachmentService(repository, s3_service, db)
       651      ```
       652    
       653    - `src/services/s3_service.py`: S3Service class

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 35 additions                           
       693    **API Routes:**
       694    - `src/api/attachments.py`: FastAPI router with 4 endpoints
       695      ```python
       696 +    from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
       697 +    from ..services.attachment_service import get_attachment_service, AttachmentService
       698 +    from ..services.auth import get_current_user
       699 +    from ..models.user import User
       700 +  
       701      router = APIRouter(prefix="/api", tags=["Attachments"])
       702    
       703      @router.post("/tasks/{task_id}/attachments", response_model=AttachmentResponse, 
             status_code=201)
       704 +    async def upload_attachment(
       705 +        task_id: UUID,
       706 +        file: UploadFile = File(...),
       707 +        current_user: User = Depends(get_current_user),
       708 +        service: AttachmentService = Depends(get_attachment_service)
       709 +    ):
       710 +        return service.upload(task_id, file, current_user)
       711 +  
       712      @router.get("/tasks/{task_id}/attachments", response_model=AttachmentList)
       713 +    def list_attachments(
       714 +        task_id: UUID,
       715 +        current_user: User = Depends(get_current_user),
       716 +        service: AttachmentService = Depends(get_attachment_service)
       717 +    ):
       718 +        attachments = service.list_by_task(task_id, current_user)
       719 +        return AttachmentList(attachments=attachments, total=len(attachments))
       720 +  
       721      @router.get("/attachments/{attachment_id}/download", 
             response_model=AttachmentDownloadResponse)
       722 +    def get_download_url(
       723 +        attachment_id: UUID,
       724 +        current_user: User = Depends(get_current_user),
       725 +        service: AttachmentService = Depends(get_attachment_service)
       726 +    ):
       727 +        return service.get_download_url(attachment_id, current_user)
       728 +  
       729      @router.delete("/attachments/{attachment_id}", status_code=204)
       730 +    def delete_attachment(
       731 +        attachment_id: UUID,
       732 +        current_user: User = Depends(get_current_user),
       733 +        service: AttachmentService = Depends(get_attachment_service)
       734 +    ):
       735 +        service.delete(attachment_id, current_user)
       736 +        return None
       737      ```
       738    
       739    - Update `src/api/__init__.py`:

● Update(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Updated workspace/unit-4/task-1/technical_plan.md with 18 additions and 6 removals
       846    
       847    ### Dependency Chain
       848    ```
       849 -  API Router → AttachmentService → AttachmentRepository → Database
       850 -                               ↓
       851 -                           S3Service → AWS S3
       849 +  FastAPI Request
       850 +      ↓
       851 +  get_db() → db: Session (one per request)
       852 +      ↓
       853 +  get_attachment_service(db) → creates:
       854 +      ├─ AttachmentRepository(db)
       855 +      ├─ S3Service()
       856 +      └─ AttachmentService(repository, s3_service, db)
       857 +          ↓
       858 +  API Router endpoint → service.method(...)
       859 +      ↓
       860 +  Service owns commit/rollback
       861 +  Repository performs queries (no commit/rollback)
       862 +  S3Service performs S3 operations
       863    ```
       864    
       865    All new code follows CLAUDE.md patterns:
       866 -  - Repository pattern for database access
       867 -  - Service layer for business logic
       868 -  - Dependency injection via FastAPI Depends()
       866 +  - Repository pattern for database access (no transaction management)
       867 +  - Service layer for business logic and transaction ownership
       868 +  - Dependency injection via FastAPI Depends() with factory function
       869 +  - Single DB session per request
       870    - UUID primary keys, timezone-aware timestamps
       871    - HTTPException for errors with clear messages
       872    - Integration tests using TestClient fixtures
       873   \ No newline at end of file

● Read(workspace/unit-4/task-1/technical_plan.md)
  ⎿  Read 70 lines

● All fixes have been applied to the technical plan:

  Changes Made

  1. Removed "TODO" word

  - Removed from virus scanning section (line 233)

  2. Fixed DB Session Handling - One Session Per Request

  - Repository __init__ no longer uses Depends(get_db), takes db: Session directly
  - Service __init__ takes db: Session as parameter
  - Added get_attachment_service(db: Session = Depends(get_db)) factory function
  - Factory creates all dependencies with single shared db session

  3. Repository Does NOT Commit/Rollback

  - Explicitly stated: "Does NOT commit or rollback (Service layer handles transactions)"
  - Methods documented as: "Adds to session, does NOT commit" and "Marks for deletion, does NOT commit"
  - Added db.flush() in create method to get ID without committing
  - Complete repository implementation provided (lines 594-619)

  4. Service Owns Commit/Rollback/S3 Cleanup

  - Explicitly stated: "Owns transaction management: commit on success, rollback on failure"
  - Explicitly stated: "Owns S3 cleanup on transaction failures"
  - Updated rollback strategy with complete try/except code example (lines 85-98)
  - Upload data flow shows Service commits transaction (step 6)

  5. Complete Router Function Signatures

  - All 4 endpoints now have complete function signatures with parameters (lines 703-737):
    - upload_attachment(task_id, file, current_user, service)
    - list_attachments(task_id, current_user, service)
    - get_download_url(attachment_id, current_user, service)
    - delete_attachment(attachment_id, current_user, service)
  - All dependencies injected via Depends()
  - Includes imports at top

  6. Dependency Chain Diagram

  - Updated to show complete flow from request → get_db() → get_attachment_service() → router endpoint
  (lines 848-863)
  - Shows Service owns commit/rollback, Repository performs queries only

  The plan is now architecturally sound with no guesswork required for implementation.

───────────────────────────────────────────────────────────────────────────────────────────────────────────
>  
───────────────────────────────────────────────────────────────────────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle)