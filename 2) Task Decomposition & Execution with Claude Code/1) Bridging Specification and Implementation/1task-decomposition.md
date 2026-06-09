# Use Claude Code to fill task-decomposition.md with a 6-8 task breakdown.
# Produce only the required deliverable and verify it against the success criteria.

# Task Decomposition: Task Comments

**Feature:** Task Comments
**Student:** Amjad Ali Kudsi
**Date:** 2026-06-09

---

## Overview

**Total Tasks:** 7 tasks across 4 phases
**Total Estimated Time:** 5.75 hours (345 minutes)
**Files Created/Modified:** 5 files total (1 new, 4 modified)

---

## Phase 1: Service Layer Infrastructure

**Goal:** Establish service layer following repository pattern for business logic separation

**Dependencies:** None

### [T001] Create Comment Service Layer

**Files Modified:**
1. `src/services/comment.py` (NEW)
2. `src/services/__init__.py` (UPDATE)

**Acceptance Criteria:**
- [ ] CommentService class implements create_comment method with authorization check
- [ ] CommentService class implements get_comments method with pagination support
- [ ] CommentService class implements update_comment method with author verification
- [ ] CommentService class implements delete_comment method with owner/author authorization
- [ ] Service properly handles notification triggering for comment events
- [ ] Service exported from services/__init__.py

**Dependencies:** None

**Time Estimate:** 45 minutes

**Handoff:** Provides CommentService class for API refactoring (T002) and enables proper business logic encapsulation

---

### [T002] Refactor API Routes to Use Service Layer

**Files Modified:**
1. `src/api/comments.py` (UPDATE)

**Acceptance Criteria:**
- [ ] POST /api/tasks/{task_id}/comments delegates to CommentService.create_comment
- [ ] GET /api/tasks/{task_id}/comments delegates to CommentService.get_comments
- [ ] PUT /api/comments/{comment_id} delegates to CommentService.update_comment
- [ ] DELETE /api/comments/{comment_id} delegates to CommentService.delete_comment
- [ ] All existing tests in test_comment_api.py still pass
- [ ] API routes contain only request/response handling, no business logic

**Dependencies:** T001

**Time Estimate:** 60 minutes

**Handoff:** Clean API layer ready for comprehensive testing, service layer properly integrated

---

## Phase 2: Schema Validation Enhancement

**Goal:** Add dedicated update schema and improve validation patterns

**Dependencies:** None

### [T003] Add CommentUpdate Schema

**Files Modified:**
1. `src/schemas/comment.py` (UPDATE)

**Acceptance Criteria:**
- [ ] CommentUpdate schema created with content field validation (min 1, max 2000 chars)
- [ ] CommentUpdate includes field-level whitespace stripping
- [ ] Schema validation prevents empty or whitespace-only comments
- [ ] Updated_at field properly handled in response schema

**Dependencies:** None

**Time Estimate:** 30 minutes

**Handoff:** Proper validation schemas ready for comprehensive test coverage

---

## Phase 3: Core Test Coverage

**Goal:** Implement complete test coverage for all CRUD operations and authorization rules

**Dependencies:** T002, T003

### [T004] Add Delete and Authorization Tests

**Files Modified:**
1. `tests/test_comment_api.py` (UPDATE)

**Acceptance Criteria:**
- [ ] test_delete_comment verifies 204 response and comment removal
- [ ] test_delete_comment_as_task_owner verifies task owner can delete any comment
- [ ] test_delete_comment_unauthorized verifies 403 when neither author nor owner
- [ ] test_update_comment_unauthorized verifies 403 when not author
- [ ] test_create_comment_unauthorized verifies 403 when not task owner
- [ ] test_get_comments_unauthorized verifies 403 when not task owner

**Dependencies:** T002, T003

**Time Estimate:** 60 minutes

**Handoff:** Core authorization logic validated, foundation for edge case testing

---

### [T005] Add Validation and Edge Case Tests

**Files Modified:**
1. `tests/test_comment_api.py` (UPDATE)

**Acceptance Criteria:**
- [ ] test_create_comment_empty_content verifies 422 validation error
- [ ] test_create_comment_whitespace_only verifies content stripped and rejected if empty
- [ ] test_create_comment_exceeds_max_length verifies 422 for content >2000 chars
- [ ] test_comment_on_nonexistent_task verifies 404 response
- [ ] test_update_nonexistent_comment verifies 404 response
- [ ] test_delete_nonexistent_comment verifies 404 response

**Dependencies:** T004

**Time Estimate:** 45 minutes

**Handoff:** Validation rules fully tested, edge cases covered

---

## Phase 4: Advanced Feature Testing

**Goal:** Validate pagination, listing functionality, and notification integration

**Dependencies:** T004

### [T006] Add Pagination and Listing Tests

**Files Modified:**
1. `tests/test_comment_api.py` (UPDATE)

**Acceptance Criteria:**
- [ ] test_list_comments_pagination verifies skip/limit query parameters work
- [ ] test_list_comments_ordering verifies comments ordered by created_at ascending
- [ ] test_list_comments_total_count verifies accurate total field in response
- [ ] test_list_comments_empty verifies empty list for task with no comments
- [ ] test_list_comments_includes_author_username verifies author info in response

**Dependencies:** T004

**Time Estimate:** 45 minutes

**Handoff:** Pagination logic validated, listing functionality complete

---

### [T007] Add Notification Integration Tests

**Files Modified:**
1. `tests/test_comment_api.py` (UPDATE)

**Acceptance Criteria:**
- [ ] test_create_comment_sends_notification verifies notification_service called
- [ ] test_notification_includes_comment_metadata verifies correct notification payload
- [ ] test_notification_sent_to_task_owner verifies recipient is task owner
- [ ] Mock notification service properly to avoid WebSocket dependencies in tests
- [ ] All notification tests pass with >90% coverage

**Dependencies:** T004

**Time Estimate:** 60 minutes

**Handoff:** Complete test suite ready for production, notification integration validated

---

## Dependency Graph

```
Phase 1 (Service Layer):
T001 (Create Service) → T002 (Refactor API)
                              ↓
                         [Tests Depend]

Phase 2 (Schema):
T003 (Add Schema) ────────────┘
                              ↓
Phase 3 (Core Tests):         ↓
                         T004 (Delete & Auth Tests)
                              ↓
                    ┌─────────┼─────────┐
                    ↓         ↓         ↓
Phase 4:       T005      T006      T007
           (Validation) (Pagination) (Notifications)
```

**Critical Path:** T001 → T002 → T004 → (T005 | T006 | T007)

**Parallel Opportunities:**
- T001 and T003 can execute in parallel (different files, no dependencies)
- T005, T006, and T007 can execute in parallel (same file, different test functions)

---

## Task Execution Strategy

### Sequential Execution
**Recommended for single-developer workflow:**

1. **Day 1 Morning:** T001 (45 min) → T002 (60 min) → T003 (30 min) = 2.25 hours
2. **Day 1 Afternoon:** T004 (60 min) = 1 hour
3. **Day 2:** T005 (45 min) → T006 (45 min) → T007 (60 min) = 2.5 hours

**Total Sequential Time:** 5.75 hours across 2 days

### Parallel Execution
**Optimized for team or multi-session workflow:**

1. **Sprint 1 (Parallel):**
   - Developer A: T001 (45 min)
   - Developer B: T003 (30 min)
   - **Wait for both** before proceeding

2. **Sprint 2 (Sequential):**
   - Either developer: T002 (60 min) [requires T001]
   - Either developer: T004 (60 min) [requires T002, T003]

3. **Sprint 3 (Parallel):**
   - Developer A: T005 (45 min)
   - Developer B: T006 (45 min)
   - Developer C: T007 (60 min)

**Total Parallel Time:** 3.5 hours (with 2-3 developers)

---

## File Organization

```
src/
├── services/
│   ├── __init__.py          [UPDATE] - Export comment_service
│   └── comment.py           [NEW]    - CommentService class
├── schemas/
│   └── comment.py           [UPDATE] - Add CommentUpdate schema
└── api/
    └── comments.py          [UPDATE] - Refactor to use service layer

tests/
└── test_comment_api.py      [UPDATE] - Add 20+ comprehensive tests
```

**Summary:**
- 1 new file: `src/services/comment.py`
- 3 modified files: `src/services/__init__.py`, `src/schemas/comment.py`, `src/api/comments.py`, `tests/test_comment_api.py`

---

## Validation Checklist

**Before declaring complete:**
- [x] All tasks affect ≤3 files (max is 2 files per task)
- [x] All tasks estimated 30-90 minutes (range: 30-60 min)
- [x] Dependencies clearly stated (T001→T002, T002+T003→T004, T004→T005/T006/T007)
- [ ] Tests pass (`pytest tests/test_comment_api.py -v`)
- [ ] Coverage ≥90% (`pytest --cov=src.services.comment --cov=src.api.comments --cov-report=term-missing`)
