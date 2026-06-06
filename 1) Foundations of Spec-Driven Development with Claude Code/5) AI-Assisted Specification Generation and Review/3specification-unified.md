# Use Claude Code to compare specification-agent-1.md and specification-agent-2.md, then document at least 5 divergences in divergence-analysis.md
# make Claude create specification-unified.md, evaluate it, and ensure score is 85/100 or higher with Consistency 19-20/20.

# Bulk Status Update: Multi-Task Status Modification

**Version:** 1.0
**Status:** Draft
**Consolidated From:** specification-agent-1.md, specification-agent-2.md

## Purpose
Enable task owners to efficiently update the status of multiple tasks simultaneously through a single API request. This reduces network overhead and improves user experience when managing task workflows in bulk (e.g., advancing all pending tasks to in_progress, completing all in-progress tasks in a sprint).

## User Stories

### US-1: Task Owner Updates Multiple Task Statuses
**As a** task owner managing multiple tasks
**I want to** update the status of several tasks at once
**So that** I can efficiently manage my workflow without making individual requests

**Acceptance Criteria:**
- **Given** I own 10 tasks in "pending" status
  **When** I send bulk update request with task IDs and target status "in_progress"
  **Then** all 10 tasks transition to "in_progress" status
  **And** I receive confirmation with updated task count

- **Given** I request bulk update for 5 tasks
  **When** 1 task belongs to another user
  **Then** the entire operation fails with 403 Forbidden
  **And** no tasks are updated
  **And** I receive error identifying which task caused failure

- **Given** I request status update to "pending"
  **When** one task is in "completed" status (invalid transition)
  **Then** the entire operation fails with 422 Unprocessable Entity
  **And** no tasks are updated
  **And** I receive error explaining invalid transition

**Out of Scope:**
- Updating other task properties (title, description, priority)
- Bulk operations across different users' tasks
- Partial success (all-or-nothing only)

### US-2: System Enforces Request Limits
**As a** system administrator
**I want to** limit bulk operations to reasonable size
**So that** system performance remains stable

**Acceptance Criteria:**
- **Given** I request bulk update with 1 task ID
  **When** I submit the request
  **Then** I receive 400 Bad Request
  **And** error message states "Minimum 2 tasks required"

- **Given** I request bulk update with 51 task IDs
  **When** I submit the request
  **Then** I receive 422 Unprocessable Entity
  **And** error message states "Maximum 50 tasks allowed"

**Out of Scope:**
- Dynamic limits based on user tier
- Queueing large operations

## API Contract

### POST /api/tasks/bulk-update-status

**Request Headers:**
- `Authorization: Bearer <jwt_token>` (required)
- `Content-Type: application/json` (required)

**Request Body:**
```json
{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440003"
  ],
  "status": "in_progress"
}
```

**Field Specifications:**
- `task_ids`: Array of UUID strings (required)
  - Minimum length: 2
  - Maximum length: 50
  - Each ID must be valid UUID format
  - All tasks must exist
  - All tasks must belong to authenticated user
  - No duplicate IDs allowed
- `status`: String (required)
  - Allowed values: `"pending"`, `"in_progress"`, `"completed"`
  - Must be valid transition from current task status

**Valid Status Transitions:**
Based on existing TaskMaster transition rules (src/models/task.py:36-40):
- `pending` → `in_progress`
- `pending` → `completed`
- `in_progress` → `completed`

**Invalid Transitions:**
- `completed` → any other status (completed is final)
- Any transition not listed above

**Success Response (200 OK):**
```json
{
  "message": "Successfully updated 3 tasks",
  "updated_count": 3,
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440003"
  ]
}
```

**Error Response (400 Bad Request):**
```json
{
  "detail": "Minimum 2 tasks required"
}
```
or
```json
{
  "detail": "Duplicate task IDs not allowed"
}
```

**Error Response (403 Forbidden):**
```json
{
  "detail": "Task 550e8400-e29b-41d4-a716-446655440002 does not belong to current user"
}
```

**Error Response (404 Not Found):**
```json
{
  "detail": "Task 550e8400-e29b-41d4-a716-446655440003 not found"
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "detail": "Maximum 50 tasks allowed"
}
```
or
```json
{
  "detail": "Invalid status transition for task 550e8400-e29b-41d4-a716-446655440001: cannot transition from 'pending' to 'pending'"
}
```

**HTTP Status Codes:**
- `200 OK` - All tasks successfully updated
- `400 Bad Request` - Invalid request format or too few tasks
- `401 Unauthorized` - Missing or invalid authentication token
- `403 Forbidden` - User does not own one or more tasks
- `404 Not Found` - One or more task IDs do not exist
- `422 Unprocessable Entity` - Too many tasks or invalid status transition

## Behavior

### All-or-Nothing Validation
The system validates all tasks before updating any:
1. Verify all task IDs exist in system
2. Verify authenticated user owns all tasks
3. Verify all status transitions are valid
4. If any validation fails, return error and update no tasks
5. If all validations pass, update all tasks atomically

### Validation Order
Validations are performed in this order to provide the most actionable error first:
1. Request format (JSON structure, required fields present)
2. Task count limits (minimum 2, maximum 50 tasks)
3. Duplicate detection (task_ids array contains unique values)
4. Task existence (404 if any task ID not found)
5. Task ownership (403 if any task not owned by authenticated user)
6. Status transitions (422 if any transition invalid)

### Update Process
When all validations pass:
1. Update `status` field for all specified tasks
2. Update `updated_at` timestamp for all tasks (automatic via SQLAlchemy)
3. Commit transaction atomically
4. Return success response with count and task IDs

## Constraints

### Request Limits
- Minimum tasks per request: 2
- Maximum tasks per request: 50
- All task IDs must be unique (no duplicates)
- Request body size limit: 10KB
- Each task_id must be valid UUID format

### Authentication
- Valid JWT Bearer token required
- Token must not be expired
- User must be active (not suspended/deleted)

### Authorization
- User can only update their own tasks
- User cannot update tasks owned by other users
- Authorization check applies to ALL tasks before ANY updates

### Status Transitions
Allowed transitions (based on src/models/task.py:36-40):
- `pending` → `in_progress`
- `pending` → `completed`
- `in_progress` → `completed`

Invalid transitions (return 422):
- `completed` → any status (completed is final, no rollback)
- Any same-status transition (e.g., `pending` → `pending`)

### Database Transactions
- All updates must occur in a single database transaction
- Transaction rolls back completely if any error occurs
- Ensures data consistency across all affected tasks

## Edge Cases

### Edge Case 1: Duplicate Task IDs
**Trigger:** Request contains the same task ID multiple times
**System Behavior:** Return 400 Bad Request with message "Duplicate task IDs not allowed"
**Rationale:** Prevents ambiguous operations and ensures accurate update count. Duplicate IDs suggest client-side error that should be fixed.

### Edge Case 2: All Tasks Already in Target Status
**Trigger:** All tasks already have the requested status
**System Behavior:** Return 200 OK with `{"message": "0 tasks updated (all already in target status)", "updated_count": 0, "task_ids": [...]}`
**Rationale:** Not an error condition. Operation is idempotent and succeeds without changes. Client can distinguish between "nothing to do" and "update failed."

### Edge Case 3: Mixed Valid and Invalid Transitions
**Trigger:** Request contains tasks where some can transition and others cannot
**System Behavior:** Return 422 with details on first invalid transition, update no tasks
**Rationale:** All-or-nothing ensures data consistency. Partial updates would leave system in unexpected state. Error identifies specific blocking task.

### Edge Case 4: Task Deleted During Request Processing
**Trigger:** Task exists at initial validation but is deleted before update transaction commits
**System Behavior:** Return 404 Not Found for the deleted task, update no tasks
**Rationale:** Maintains all-or-nothing guarantee. Database transaction will detect missing task during update phase.

### Edge Case 5: Concurrent Bulk Updates to Same Tasks
**Trigger:** Two requests attempt to bulk update overlapping task sets simultaneously
**System Behavior:** Both requests succeed if validations pass; last write wins for final status
**Rationale:** Follows standard TaskMaster concurrency behavior. Database transactions ensure no data corruption. No locks required for status-only updates.

### Edge Case 6: Request with Only Non-Existent Task IDs
**Trigger:** All task IDs in request do not exist in database
**System Behavior:** Return 404 Not Found for first non-existent task ID
**Rationale:** Validation order checks existence before ownership, so 404 is returned (not 403).

### Edge Case 7: Empty Task Array
**Trigger:** Request body contains `{"task_ids": [], "status": "completed"}`
**System Behavior:** Return 400 Bad Request with message "Minimum 2 tasks required"
**Rationale:** Empty array fails minimum count validation. Clear error message guides client to correct usage.

## Success Metrics

### Adoption Metrics
- **Target:** 40% of active users perform at least one bulk update within first month
- **Measurement:** Track unique user_ids calling bulk-update-status endpoint
- **Success Threshold:** ≥35% adoption by month 2

### Usage Patterns
- **Target:** Average bulk operation updates 8 tasks
- **Measurement:** Mean task_ids array length across all successful requests
- **Success Threshold:** 6-12 tasks per operation (indicates optimal batch sizing)

### Reliability
- **Target:** <1% failure rate due to system errors (5xx responses)
- **Measurement:** Count of 5xx responses / total requests
- **Success Threshold:** 99.5% success rate (excluding client errors 4xx)

### Performance
- **Target:** 95th percentile response time <500ms for 10-task updates
- **Measurement:** P95 latency from request received to response sent
- **Success Threshold:** <750ms P95 (allows for database transaction overhead)

## Examples

### Example 1: Successful Bulk Update
**Scenario:** User advances 5 pending tasks to in_progress status

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440003",
    "550e8400-e29b-41d4-a716-446655440004",
    "550e8400-e29b-41d4-a716-446655440005"
  ],
  "status": "in_progress"
}
```

**Response (200 OK):**
```json
{
  "message": "Successfully updated 5 tasks",
  "updated_count": 5,
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440003",
    "550e8400-e29b-41d4-a716-446655440004",
    "550e8400-e29b-41d4-a716-446655440005"
  ]
}
```

### Example 2: Authorization Failure
**Scenario:** User attempts to update tasks, but one task belongs to another user

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002"
  ],
  "status": "completed"
}
```

**Response (403 Forbidden):**
```json
{
  "detail": "Task 550e8400-e29b-41d4-a716-446655440002 does not belong to current user"
}
```

**Note:** No tasks were updated due to all-or-nothing validation.

### Example 3: Invalid Status Transition
**Scenario:** User attempts to transition completed task back to pending (not allowed)

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440003"
  ],
  "status": "pending"
}
```

**Response (422 Unprocessable Entity):**
```json
{
  "detail": "Invalid status transition for task 550e8400-e29b-41d4-a716-446655440001: cannot transition from 'completed' to 'pending'"
}
```

### Example 4: Too Few Tasks
**Scenario:** User attempts bulk update with only 1 task (should use PUT /api/tasks/{task_id} instead)

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001"
  ],
  "status": "completed"
}
```

**Response (400 Bad Request):**
```json
{
  "detail": "Minimum 2 tasks required"
}
```

### Example 5: Idempotent Operation (No Changes Needed)
**Scenario:** All requested tasks are already in target status

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002"
  ],
  "status": "completed"
}
```

**Response (200 OK):**
```json
{
  "message": "0 tasks updated (all already in target status)",
  "updated_count": 0,
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002"
  ]
}
```

### Example 6: Duplicate Task IDs
**Scenario:** Request contains the same task ID multiple times

**Request:**
```bash
POST /api/tasks/bulk-update-status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "task_ids": [
    "550e8400-e29b-41d4-a716-446655440001",
    "550e8400-e29b-41d4-a716-446655440002",
    "550e8400-e29b-41d4-a716-446655440001"
  ],
  "status": "in_progress"
}
```

**Response (400 Bad Request):**
```json
{
  "detail": "Duplicate task IDs not allowed"
}
```

## Implementation Notes

### Database Transaction
```python
# Pseudocode for implementation
with db.begin():  # Start transaction
    tasks = db.query(Task).filter(Task.id.in_(task_ids)).all()

    # Validate count matches request
    if len(tasks) != len(task_ids):
        # Some tasks not found
        raise NotFound()

    # Validate all ownership
    for task in tasks:
        if task.owner_id != current_user.id:
            raise Forbidden(f"Task {task.id} does not belong to current user")

    # Validate all transitions
    for task in tasks:
        if new_status not in valid_transitions[task.status]:
            raise UnprocessableEntity(f"Invalid status transition for task {task.id}...")

    # All validations passed - update all tasks
    updated_count = 0
    for task in tasks:
        if task.status != new_status:
            task.update_status(new_status)
            updated_count += 1

    db.commit()  # Atomic commit
```

### Performance Considerations
- Database query uses `WHERE id IN (...)` for efficiency
- Single transaction minimizes lock time
- No notifications sent (unlike single task update in src/api/tasks.py:88-101)
  - Reduces overhead for bulk operations
  - Can be added in future version if needed

### Security Considerations
- 10KB request body limit prevents large payloads
- UUID validation prevents injection attacks
- Authentication required on all requests
- Authorization checked before any database writes
- No user can affect tasks they don't own

## Future Enhancements

These features are explicitly out of scope for v1.0 but may be considered for future versions:

1. **Cancelled status support:** Add CANCELLED to TaskStatus enum to support bulk cancellation
2. **Partial success mode:** Optional flag to update successful tasks even if some fail
3. **Bulk update other fields:** Support updating priority, due_date in bulk
4. **Progress notifications:** Send real-time notifications during bulk updates
5. **Async processing:** Queue large bulk operations (>50 tasks) for background processing
6. **Audit logging:** Detailed logging of which tasks changed from what status to what

## Open Questions
None at this time.

## Assumptions
1. TaskMaster system has task status field with values: pending, in_progress, completed (src/models/task.py:12-16)
2. User authentication and authorization infrastructure exists (src/services/auth.py)
3. Task ownership tracked via owner_id foreign key on tasks table (src/models/task.py:26)
4. System supports database transactions for all-or-nothing operations (SQLAlchemy transactions)
5. Existing Task.update_status() method handles status transitions (src/models/task.py:35-45)
6. No notifications are sent for bulk operations (unlike individual task updates)
