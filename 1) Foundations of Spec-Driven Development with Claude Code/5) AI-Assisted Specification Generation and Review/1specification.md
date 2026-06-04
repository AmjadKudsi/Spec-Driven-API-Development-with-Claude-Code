# Use Claude Code to create workspace/specs/task-tags/specification.md, then evaluate it against 5 scoring dimensions until it reaches 75/100 or higher
# make Claude Code fill workspace/specs/task-tags/evaluation-report.md, including the first score, refinement feedback, final score, and what Claude got wrong initially

# Functional Specification: Task Tags

**Feature:** Task Tags
**System:** TaskMaster API
**Version:** 1.1
**Status:** Draft
**Author:** Claude Code (Generated)
**Last Updated:** 2026-06-04

---

## 1. Purpose

Users need a flexible way to organize and categorize their tasks beyond status and priority. Tags provide a lightweight, user-defined labeling system that enables better task organization and retrieval.

**Current Problem:** Users can only filter tasks by status (pending, in_progress, completed) and priority (1-3), which is insufficient for organizing diverse task types. There's no way to group related tasks across different statuses or priorities (e.g., "work", "urgent", "review").

**Solution:** Implement a tag system where users can attach multiple text labels to tasks, filter tasks by one or more tags, and view their tag catalog with usage statistics.

---

## 2. User Stories

### Story 1: Add Tags to Task

**As a** task owner
**I want to** add tags to my tasks
**So that** I can categorize and organize tasks using custom labels

**Acceptance Criteria:**

**Given** I own a task
**When** I add tags `["work", "urgent", "backend"]` to the task
**Then** the new tags are added to any existing tags on the task (append operation)
**And** the tags are stored in lowercase format
**And** the tags appear in alphabetical order in the response
**And** the task's `updated_at` timestamp is updated
**And** the response returns status 200 with updated task details including all tags

**Given** I attempt to add an 11th tag to a task that already has 10 tags
**When** I send the request
**Then** the response returns status 400
**And** the error message is `{"detail": "Maximum 10 tags allowed per task"}`

**Given** I attempt to add a tag with invalid characters like `"work@home"`
**When** I send the request
**Then** the response returns status 422
**And** the error message is `{"detail": "Tag 'work@home' contains invalid characters. Only alphanumeric and hyphens allowed"}`

**Given** I send a request with duplicate tags in the array `["work", "work", "urgent"]`
**When** the request is processed
**Then** duplicates are removed and only unique tags are added
**And** the task receives tags `["urgent", "work"]` (alphabetical order)

### Story 2: Remove Tags from Task

**As a** task owner
**I want to** remove specific tags from my tasks
**So that** I can update task categorization as needs change

**Acceptance Criteria:**

**Given** a task has tags `["backend", "urgent", "work"]`
**When** I remove tags `["urgent"]`
**Then** the task retains only `["backend", "work"]`
**And** the task's `updated_at` timestamp is updated
**And** the response returns status 200

**Given** I attempt to remove a tag that doesn't exist on the task
**When** I send the request
**Then** the operation succeeds silently (idempotent)
**And** the response returns status 200

**Given** I send an empty tags array `[]`
**When** I send the request
**Then** no tags are removed (no-op)
**And** the response returns status 200

### Story 3: Filter Tasks by Tags

**As a** task owner
**I want to** filter my tasks by one or more tags
**So that** I can quickly find all tasks matching any of the specified tags

**Acceptance Criteria:**

**Given** I have tasks with various tag combinations:
- Task A: `["urgent", "work"]`
- Task B: `["backend", "work"]`
- Task C: `["personal", "urgent"]`
**When** I filter by tags `["work"]`
**Then** I receive Task A and Task B only
**And** the response includes total count = 2

**Given** the same tasks
**When** I filter by tags `["work", "urgent"]` (OR logic)
**Then** I receive all three tasks (A, B, and C)
**And** the response includes total count = 3

**Given** I filter by tags `["nonexistent"]`
**When** I send the request
**Then** I receive an empty task list
**And** total count = 0

### Story 4: List All User Tags

**As a** task owner
**I want to** view all my tags with usage counts
**So that** I can see which tags I use and manage tag consistency

**Acceptance Criteria:**

**Given** I have tasks with tags:
- Task A: `["urgent", "work"]`
- Task B: `["backend", "work"]`
- Task C: `["personal"]`
**When** I request my tag list
**Then** I receive:
```json
[
  {"name": "backend", "count": 1},
  {"name": "personal", "count": 1},
  {"name": "urgent", "count": 1},
  {"name": "work", "count": 2}
]
```
**And** tags are sorted alphabetically by name
**And** the response returns status 200

**Given** I have no tasks with tags
**When** I request my tag list
**Then** I receive an empty array

---

## 3. API Contract

### POST /api/tasks/{task_id}/tags

**Endpoint:** `POST /api/tasks/{task_id}/tags`

**Description:** Adds tags to a task (append operation). Does not replace existing tags.

**Path Parameters:**
- `task_id` (UUID, required) — ID of the task to add tags to

**Request Body:**
```json
{
  "tags": ["work", "urgent", "backend"]
}
```

**Request Body Schema:**
- `tags` (array of strings, required) — List of tags to add. Minimum 0 items, maximum 10 items.

**Behavior:**
- Tags are appended to existing tags (not replaced)
- Duplicates are automatically removed (both within request and against existing tags)
- Tags are normalized to lowercase
- Tags are returned in alphabetical order
- Empty tags array is valid but performs no operation
- Task's `updated_at` timestamp is updated

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Implement API endpoint",
  "description": "Create new REST endpoint for tags",
  "status": "in_progress",
  "priority": 1,
  "owner_id": "123e4567-e89b-12d3-a456-426614174000",
  "tags": ["backend", "urgent", "work"],
  "due_date": "2026-06-10T15:00:00Z",
  "created_at": "2026-06-01T10:00:00Z",
  "updated_at": "2026-06-04T14:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request` — Maximum 10 tags per task exceeded
  ```json
  {
    "detail": "Maximum 10 tags allowed per task"
  }
  ```
- `401 Unauthorized` — Missing or invalid authentication token
  ```json
  {
    "detail": "Not authenticated"
  }
  ```
- `403 Forbidden` — User does not own this task
  ```json
  {
    "detail": "Not authorized"
  }
  ```
- `404 Not Found` — Task does not exist
  ```json
  {
    "detail": "Task not found"
  }
  ```
- `422 Unprocessable Entity` — Request body missing or tag validation failed
  ```json
  {
    "detail": "Tag 'work_project' contains invalid characters. Only alphanumeric and hyphens allowed"
  }
  ```

---

### DELETE /api/tasks/{task_id}/tags

**Endpoint:** `DELETE /api/tasks/{task_id}/tags`

**Description:** Removes specified tags from a task.

**Path Parameters:**
- `task_id` (UUID, required) — ID of the task to remove tags from

**Request Body:**
```json
{
  "tags": ["urgent"]
}
```

**Request Body Schema:**
- `tags` (array of strings, required) — List of tags to remove. Minimum 0 items.

**Behavior:**
- Removes only the specified tags
- Idempotent: removing non-existent tags succeeds silently
- Empty tags array is valid but performs no operation
- Task's `updated_at` timestamp is updated only if tags were actually removed

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Implement API endpoint",
  "description": "Create new REST endpoint for tags",
  "status": "in_progress",
  "priority": 1,
  "owner_id": "123e4567-e89b-12d3-a456-426614174000",
  "tags": ["backend", "work"],
  "due_date": "2026-06-10T15:00:00Z",
  "created_at": "2026-06-01T10:00:00Z",
  "updated_at": "2026-06-04T14:30:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` — Missing or invalid authentication token
  ```json
  {
    "detail": "Not authenticated"
  }
  ```
- `403 Forbidden` — User does not own this task
  ```json
  {
    "detail": "Not authorized"
  }
  ```
- `404 Not Found` — Task does not exist
  ```json
  {
    "detail": "Task not found"
  }
  ```
- `422 Unprocessable Entity` — Request body missing or malformed
  ```json
  {
    "detail": "Field required"
  }
  ```

---

### GET /api/tasks (Enhanced)

**Endpoint:** `GET /api/tasks`

**Description:** Lists user's tasks with optional filtering, including new tag-based filtering.

**Query Parameters:**
- `status` (TaskStatus, optional) — Filter by task status
- `priority` (int, optional) — Filter by priority (1-3)
- `tags` (string[], optional) — Filter by one or more tags using OR logic
- `skip` (int, optional, default=0) — Pagination offset
- `limit` (int, optional, default=50, max=100) — Results per page

**Tag Filter Behavior:**
- Multiple tags use OR logic (returns tasks matching ANY of the specified tags)
- Tag matching is case-insensitive
- Non-existent tags return empty results (not an error)
- Can be combined with status and priority filters (AND logic across filter types)

**Example Request:**
```
GET /api/tasks?tags=work&tags=urgent&limit=20
```

**Response (200):**
```json
{
  "tasks": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Implement API endpoint",
      "description": "Create new REST endpoint for tags",
      "status": "in_progress",
      "priority": 1,
      "owner_id": "123e4567-e89b-12d3-a456-426614174000",
      "tags": ["backend", "urgent", "work"],
      "due_date": "2026-06-10T15:00:00Z",
      "created_at": "2026-06-01T10:00:00Z",
      "updated_at": "2026-06-04T14:30:00Z"
    }
  ],
  "total": 1,
  "skip": 0,
  "limit": 20
}
```

**Error Responses:**
- `401 Unauthorized` — Missing or invalid authentication token
  ```json
  {
    "detail": "Not authenticated"
  }
  ```
- `422 Unprocessable Entity` — Invalid query parameters
  ```json
  {
    "detail": "Field required"
  }
  ```

---

### GET /api/tags

**Endpoint:** `GET /api/tags`

**Description:** Returns all tags used by the current user with usage counts.

**Response (200):**
```json
[
  {
    "name": "backend",
    "count": 3
  },
  {
    "name": "personal",
    "count": 1
  },
  {
    "name": "urgent",
    "count": 5
  },
  {
    "name": "work",
    "count": 8
  }
]
```

**Response Schema:**
- Returns array of tag objects
- `name` (string) — Tag name in lowercase
- `count` (int) — Number of tasks with this tag
- Tags sorted alphabetically by name
- Empty array if user has no tags

**Error Responses:**
- `401 Unauthorized` — Missing or invalid authentication token
  ```json
  {
    "detail": "Not authenticated"
  }
  ```

---

## 4. Validation Rules

### Tag Format

- **Characters:** Only alphanumeric characters (a-z, A-Z, 0-9) and hyphens (`-`)
- **Length:** Minimum 1 character, maximum 30 characters
- **Case handling:** Tags are case-insensitive; stored and returned in lowercase
- **Whitespace:** Leading and trailing whitespace is trimmed before validation; internal whitespace not allowed
- **Normalization:** Tags are normalized to lowercase before storage and comparison

**Examples:**
- ✅ Valid: `"work"`, `"urgent-review"`, `"q1-2026"`, `"backend-api"`, `"a"`, `"123"`
- ❌ Invalid: `"work project"` (contains space)
- ❌ Invalid: `"urgent!"` (contains special character)
- ❌ Invalid: `""` (empty string)
- ❌ Invalid: `"a"*31` (exceeds 30 characters)
- ❌ Invalid: `"work_task"` (underscore not allowed)
- ❌ Invalid: `"   "` (only whitespace, becomes empty after trim)

### Tag Limits

- **Per-task maximum:** 10 unique tags per task
- **Duplicate handling:** Duplicates are automatically removed (case-insensitive comparison)
- **Empty array:** Sending an empty `tags` array is valid and performs no operation
- **Ordering:** Tags are always returned in alphabetical order

### Request Body Validation

- **Required field:** `tags` field is required in request body for POST and DELETE endpoints
- **Array type:** `tags` must be an array of strings
- **Null handling:** `null` or missing `tags` field returns 422 error

---

## 5. Edge Cases

### Duplicate Tag Addition

**Scenario:** User adds tag `"work"` to a task that already has `"work"`
**Behavior:** Operation succeeds (200), tag list remains unchanged (idempotent)

### Case Sensitivity

**Scenario:** User adds `"Work"` to a task that already has `"work"`
**Behavior:** Both are treated as the same tag (normalized to `"work"`); no duplicate created

### Duplicates Within Request

**Scenario:** User sends `{"tags": ["work", "WORK", "Work"]}`
**Behavior:** Duplicates removed; only `"work"` is added once

### Tag Removal of Non-existent Tag

**Scenario:** User attempts to remove tag `"urgent"` from a task that doesn't have it
**Behavior:** Operation succeeds (200), tag list unchanged, `updated_at` not modified

### Filtering with Multiple Tags

**Scenario:** User filters by `tags=["work", "personal"]`
**Behavior:** Returns tasks that have **either** `"work"` OR `"personal"` (union, not intersection)

### Task Deletion Impact

**Scenario:** User deletes a task that has tags
**Behavior:** The task and its tag associations are removed; user's other tasks unaffected

### Empty Tag Name After Trim

**Scenario:** User sends tag `"   "` (only whitespace)
**Behavior:** After trimming, tag is empty string; validation fails with 422 error

### Maximum Tags Boundary

**Scenario:** Task has 10 tags; user attempts to add 1 more unique tag
**Behavior:** Request fails with 400 error; no tags are added

**Scenario:** Task has 9 tags; user adds 2 new unique tags in one request
**Behavior:** Request fails with 400 error; no tags are added (atomic operation)

**Scenario:** Task has 5 tags; user adds 5 tags where 3 are duplicates of existing tags
**Behavior:** Operation succeeds; only 2 new tags are added (total = 7 tags)

### Empty Tags Array

**Scenario:** User sends `{"tags": []}` to POST or DELETE endpoint
**Behavior:** Operation succeeds (200), no changes made, `updated_at` not modified

### Missing Request Body

**Scenario:** User sends POST/DELETE request with no body or `null` body
**Behavior:** Request fails with 422 error

---

## 6. Error Conditions

### Maximum Tags Exceeded (400)
```json
{
  "detail": "Maximum 10 tags allowed per task"
}
```

### Invalid Tag Format (422)
```json
{
  "detail": "Tag 'work project' contains invalid characters. Only alphanumeric and hyphens allowed"
}
```

### Tag Too Long (422)
```json
{
  "detail": "Tag exceeds maximum length of 30 characters"
}
```

### Tag Too Short (422)
```json
{
  "detail": "Tag cannot be empty"
}
```

### Missing Required Field (422)
```json
{
  "detail": "Field required"
}
```

### Task Not Found (404)
```json
{
  "detail": "Task not found"
}
```

### Not Authorized (403)
```json
{
  "detail": "Not authorized"
}
```

### Not Authenticated (401)
```json
{
  "detail": "Not authenticated"
}
```

---

## 7. Success Metrics

### Tag Adoption Rate
- **Target:** 60% of active users create at least one tag within 30 days
- **Measurement:** Count unique users with tagged tasks / total active users

### Tag Usage Depth
- **Target:** Average 3-5 tags per tagged task
- **Measurement:** Sum of all tags on all tasks / count of tasks with tags

---

## 8. Examples

### Example 1: Add Tags to Task

**Request:**
```http
POST /api/tasks/550e8400-e29b-41d4-a716-446655440000/tags
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
Content-Type: application/json

{
  "tags": ["work", "Q2-2026", "backend-api"]
}
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Implement task tags feature",
  "description": "Add tagging system to TaskMaster API",
  "status": "in_progress",
  "priority": 1,
  "owner_id": "123e4567-e89b-12d3-a456-426614174000",
  "tags": ["backend-api", "q2-2026", "work"],
  "due_date": "2026-06-15T17:00:00Z",
  "created_at": "2026-06-01T09:00:00Z",
  "updated_at": "2026-06-04T14:45:00Z"
}
```

---

### Example 2: Remove Tags

**Request:**
```http
DELETE /api/tasks/550e8400-e29b-41d4-a716-446655440000/tags
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
Content-Type: application/json

{
  "tags": ["q2-2026"]
}
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Implement task tags feature",
  "description": "Add tagging system to TaskMaster API",
  "status": "in_progress",
  "priority": 1,
  "owner_id": "123e4567-e89b-12d3-a456-426614174000",
  "tags": ["backend-api", "work"],
  "due_date": "2026-06-15T17:00:00Z",
  "created_at": "2026-06-01T09:00:00Z",
  "updated_at": "2026-06-04T14:50:00Z"
}
```

---

### Example 3: Filter Tasks by Tags

**Request:**
```http
GET /api/tasks?tags=work&tags=urgent&limit=10
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
```

**Response (200):**
```json
{
  "tasks": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Implement task tags feature",
      "description": "Add tagging system to TaskMaster API",
      "status": "in_progress",
      "priority": 1,
      "owner_id": "123e4567-e89b-12d3-a456-426614174000",
      "tags": ["backend-api", "work"],
      "due_date": "2026-06-15T17:00:00Z",
      "created_at": "2026-06-01T09:00:00Z",
      "updated_at": "2026-06-04T14:50:00Z"
    },
    {
      "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "title": "Fix authentication bug",
      "description": "Token refresh not working correctly",
      "status": "pending",
      "priority": 1,
      "owner_id": "123e4567-e89b-12d3-a456-426614174000",
      "tags": ["bug", "security", "urgent"],
      "due_date": "2026-06-05T12:00:00Z",
      "created_at": "2026-06-03T11:30:00Z",
      "updated_at": "2026-06-03T11:30:00Z"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 10
}
```

---

### Example 4: List All User Tags

**Request:**
```http
GET /api/tags
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
```

**Response (200):**
```json
[
  {
    "name": "backend-api",
    "count": 3
  },
  {
    "name": "bug",
    "count": 2
  },
  {
    "name": "security",
    "count": 1
  },
  {
    "name": "urgent",
    "count": 4
  },
  {
    "name": "work",
    "count": 7
  }
]
```

---

### Example 5: Validation Error - Invalid Tag Format

**Request:**
```http
POST /api/tasks/550e8400-e29b-41d4-a716-446655440000/tags
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
Content-Type: application/json

{
  "tags": ["work", "high_priority"]
}
```

**Response (422):**
```json
{
  "detail": "Tag 'high_priority' contains invalid characters. Only alphanumeric and hyphens allowed"
}
```

---

### Example 6: Maximum Tags Exceeded

**Request:**
```http
POST /api/tasks/550e8400-e29b-41d4-a716-446655440000/tags
Authorization: Bearer eyJ0eXAiOiJKV1QiLC...
Content-Type: application/json

{
  "tags": ["tag11"]
}
```

**Context:** Task already has 10 tags

**Response (400):**
```json
{
  "detail": "Maximum 10 tags allowed per task"
}
```

---

## 9. Out of Scope

The following features are explicitly NOT included in this specification:

- **Tag sharing** — Tags are private to each user; no shared or team tags
- **Tag hierarchies** — No parent/child tag relationships or nested tags
- **Tag colors** — No UI color coding or visual customization
- **Tag suggestions** — No autocomplete or tag recommendations
- **Tag analytics** — No insights like "most used tags this week"
- **AND filtering** — Only OR logic supported; filtering by ALL tags simultaneously not supported
- **Tag descriptions** — Tags are labels only, no additional metadata
- **Tag renaming** — To rename a tag, remove old tag and add new one to all affected tasks
- **Tag merging** — No automatic consolidation of similar tags
- **Global tag limits** — No restriction on total number of unique tags per user
- **Batch tag operations** — No endpoint to add/remove tags across multiple tasks simultaneously
- **Tag history** — No tracking of when tags were added or removed

---

**Approval Status:** [X] Draft [ ] In Review [ ] Approved
**Reviewer:** TBD
**Approval Date:** TBD
