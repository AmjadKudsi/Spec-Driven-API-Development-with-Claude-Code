# Task Priority Feature Specification

## Purpose
Allow users to assign priority levels to tasks for better organization and filtering.

## Data Model Changes

### Task Model
Add field:
- `priority`: Enum with values ["low", "medium", "high", "urgent"]
- Default: "medium"
- Required: Yes
- Validation: Must be one of the enum values

## API Changes

### POST /api/tasks
**Request Schema (TaskCreate):**
```json
{
  "title": "string (1-200 chars, required)",
  "description": "string (optional)",
  "priority": "low|medium|high|urgent (optional, default: medium)"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "priority": "medium",
  "created_at": "2024-01-15T10:00:00Z"
}
```

## Validation Rules
- Priority must be one of: low, medium, high, urgent (case-sensitive)
- Invalid priority returns 422 Unprocessable Entity
- Missing priority on creation defaults to "medium"
```

`specs/task-priority/tasks.md`
```markdown
# Task Priority - Implementation Tasks

## T001: Add priority field to Task model
**Estimated time:** 20 minutes

**Acceptance Criteria:**
- [ ] Task model has `priority` field (Enum: low/medium/high/urgent)
- [ ] Default value is "medium"
- [ ] Database migration created and applied
- [ ] Unit tests verify field exists and defaults correctly
- [ ] Type hints are complete

**Files to modify:**
- `src/models/task.py`
- `tests/unit/test_task_model.py`
- `alembic/versions/xxx_add_priority.py` (new)

**Dependencies:** None