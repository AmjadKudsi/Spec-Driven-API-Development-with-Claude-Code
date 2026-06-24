# Complete get_parallel_groups() and calculate_critical_path() in task_plan.py.
# use Claude Code to patch only the TODO logic and verify tests.

# Technical Plan: Bulk Status Update Feature

## Feature Overview
Allow users to update the status of 2-50 tasks in a single API request with all-or-nothing validation. If any task fails validation, the entire operation is rejected. If all tasks pass validation, all updates are committed atomically.

## Requirements
- Validate that all tasks exist
- Validate that the user owns all tasks
- Validate that all status transitions are valid
- Perform updates atomically (all succeed or all fail)
- Handle 2-50 tasks per request efficiently

## Task Breakdown

### T001: StatusTransitionValidator
**Description**: Create a validator that checks if a single task can transition from its current status to a new status.

**Acceptance Criteria**:
- Validate transitions like "todo" → "in_progress" (valid)
- Reject invalid transitions like "done" → "todo"
- Return clear error messages for invalid transitions

**Dependencies**: None

**Estimated Time**: 30 minutes

---

### T002: BulkOwnershipValidator
**Description**: Create a validator that checks if a user owns all tasks in a bulk update request.

**Acceptance Criteria**:
- Accept a user_id and list of task_ids
- Query the TaskRepository to verify ownership
- Return False if user doesn't own any task in the list

**Dependencies**: None (uses existing TaskRepository)

**Estimated Time**: 30 minutes

---

### T003: BulkValidationService
**Description**: Orchestrate both validators to perform complete validation of a bulk update request.

**Acceptance Criteria**:
- Use StatusTransitionValidator to check all transitions
- Use BulkOwnershipValidator to verify ownership
- Collect all validation errors
- Return success only if all validations pass

**Dependencies**: T001 (StatusTransitionValidator), T002 (BulkOwnershipValidator)

**Estimated Time**: 45 minutes

---

### T004: BulkUpdateRepository
**Description**: Handle atomic database updates using transaction management.

**Acceptance Criteria**:
- Use existing TaskRepository for individual updates
- Wrap all updates in a single transaction
- Rollback all changes if any update fails
- Commit only when all updates succeed

**Dependencies**: Existing TaskRepository

**Estimated Time**: 45 minutes

---

### T005: BulkUpdateService
**Description**: Main orchestration layer that coordinates validation and repository updates.

**Acceptance Criteria**:
- Call BulkValidationService first
- If validation passes, call BulkUpdateRepository
- Handle errors from both services
- Return clear success/failure status

**Dependencies**: T003 (BulkValidationService), T004 (BulkUpdateRepository)

**Estimated Time**: 30 minutes

---

### T006: BulkUpdateAPI
**Description**: API endpoint handler for POST /api/tasks/bulk-status-update

**Acceptance Criteria**:
- Extract user_id and task_updates from request
- Call BulkUpdateService
- Return appropriate HTTP status codes
- Return error details on validation failure

**Dependencies**: T005 (BulkUpdateService)

**Estimated Time**: 30 minutes

---

## Parallel Execution Analysis

### Tasks That Can Run in Parallel

**T001, T002, T004** have no dependencies and can start immediately at time 0.

**T003** can start at its earliest time (30min) once both T001 and T002 finish.

**T005** can start at its earliest time (75min) once both T003 and T004 finish.

**T006** can start at its earliest time (105min) once T005 finishes.

---

### Dependency Graph

```
T001 ──┐
       ├──> T003 ──┐
T002 ──┘           ├──> T005 ──> T006
                   │
T004 ──────────────┘
```

---

### Earliest-Start and Finish Times

**T001**: Start=0min, Finish=30min
**T002**: Start=0min, Finish=30min
**T004**: Start=0min, Finish=45min
**T003**: Start=30min, Finish=75min (waits for T001, T002)
**T005**: Start=75min, Finish=105min (waits for T003, T004)
**T006**: Start=105min, Finish=135min

---

### Sequential vs Parallel Timeline

**Sequential execution**: T001→T002→T003→T004→T005→T006 = 30+30+45+45+30+30 = **210 minutes**

**Parallel execution**: Following the dependency graph above = **135 minutes**

---

### Time Saved

**75 minutes saved** (210min - 135min) by executing independent tasks in parallel.