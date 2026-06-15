# Create task-tags-decomposition.md from scratch with 6-8 atomic tasks
# Use Claude Code to generate, verify, and fix a complete decomposition with dependencies, parallelism, and timeline math

# Task Tags System - Complete Decomposition

## Feature Overview

Implement a tagging system that allows users to organize tasks using reusable tags. Users can create tags, add multiple tags to tasks, filter tasks by tags, and get auto-complete suggestions when typing tag names.

**Key Requirements:**
- Many-to-many relationship (tasks ↔ tags)
- Case-insensitive tag matching (prevent duplicates)
- Tag validation (1-50 chars, alphanumeric + hyphens)
- Efficient querying (avoid N+1 problems)
- Auto-complete suggestions
- Tag usage statistics

---

## Task Breakdown

### Phase 1: Foundation

#### T001: Tag Model and Junction Table
**Description:** Create the Tag SQLAlchemy model and task_tags association table to establish the many-to-many relationship with proper indexing and constraints.

**Files Modified:**
1. `src/models/tag.py` (NEW)
2. `src/models/task.py` (UPDATE)
3. `src/models/__init__.py` (UPDATE)

**Acceptance Criteria:**
- [ ] Tag model with id, name (lowercase, unique), created_at fields
- [ ] Association table task_tags with task_id, tag_id, created_at columns
- [ ] Unique constraint on tag.name and composite index on task_tags
- [ ] Task.tags relationship configured with lazy='selectinload' for N+1 prevention
- [ ] Unit tests pass: `pytest tests/models/test_tag.py -v`
- [ ] Coverage ≥90% for tag model

**Dependencies:** None

**Estimated Time:** 75 minutes

**Delivers:** Working database schema for tags with optimized many-to-many relationship

---

#### T002: Tag Schemas and Validation Rules
**Description:** Define Pydantic schemas for tag operations with validation logic for name format, length constraints, and sanitization.

**Files Modified:**
1. `src/schemas/tag.py` (NEW)
2. `src/schemas/task.py` (UPDATE)
3. `tests/schemas/test_tag.py` (NEW)

**Acceptance Criteria:**
- [ ] TagCreate schema with name validator (1-50 chars, alphanumeric + hyphens)
- [ ] TagResponse and TagWithStats schemas defined
- [ ] TaskResponse schema updated to include tags: list[TagResponse]
- [ ] Validator normalizes tag names to lowercase and strips whitespace
- [ ] Unit tests verify validation rejects invalid names (spaces, special chars, length)
- [ ] Coverage ≥95% for schema validation logic

**Dependencies:** None

**Estimated Time:** 45 minutes

**Delivers:** Type-safe schemas with enforced validation rules

---

### Phase 2: Logic

#### T003: TagRepository Core Create/Get/Attach/Remove
**Description:** Implement repository layer with atomic operations for creating tags, retrieving by ID/name, attaching tags to tasks, and removing associations.

**Files Modified:**
1. `src/repositories/tag_repository.py` (NEW)
2. `tests/repositories/test_tag_repository.py` (NEW)

**Acceptance Criteria:**
- [ ] Methods: create(), get_by_id(), get_by_name(), get_or_create()
- [ ] Methods: attach_to_task(), remove_from_task(), get_task_tags()
- [ ] Case-insensitive duplicate prevention in get_or_create()
- [ ] All methods use database transactions with proper rollback on errors
- [ ] Integration tests with real database verify all operations
- [ ] Coverage ≥90% for repository methods

**Dependencies:** T001

**Estimated Time:** 75 minutes

**Delivers:** Data access layer for core tag operations with transactional safety

---

#### T004: TagRepository Query Features: List, Filter, Stats, Autocomplete
**Description:** Add advanced query methods for listing tags, filtering by usage, computing statistics, and autocomplete prefix search.

**Files Modified:**
1. `src/repositories/tag_repository.py` (UPDATE)
2. `tests/repositories/test_tag_repository.py` (UPDATE)

**Acceptance Criteria:**
- [ ] Methods: list_all(), search_by_prefix(), get_popular_tags(), get_tag_stats()
- [ ] search_by_prefix() uses ILIKE with index optimization, ordered by usage count
- [ ] get_popular_tags() returns tags with task_count using JOIN and GROUP BY
- [ ] Performance test: autocomplete on 1000+ tags completes in <100ms
- [ ] Query count test verifies no N+1 queries in list operations
- [ ] Coverage ≥90% for query methods

**Dependencies:** T001

**Estimated Time:** 75 minutes

**Delivers:** Efficient querying with autocomplete and analytics capabilities

---

#### T005: TagService Mutation Workflows
**Description:** Implement service layer orchestrating tag creation, task tagging/untagging workflows with business logic and error handling.

**Files Modified:**
1. `src/services/tag_service.py` (NEW)
2. `tests/services/test_tag_service.py` (NEW)

**Acceptance Criteria:**
- [ ] Methods: create_tag(), delete_tag(), add_tags_to_task(), remove_tags_from_task()
- [ ] add_tags_to_task() accepts tag names array, creates missing tags automatically
- [ ] delete_tag() prevents deletion of tags in use (raises clear error)
- [ ] All methods validate ownership (users can only tag their own tasks)
- [ ] Service tests verify business rules and permission checks
- [ ] Coverage ≥90% for service mutation methods

**Dependencies:** T002, T003

**Estimated Time:** 90 minutes

**Delivers:** Business logic layer for tag mutations with permission enforcement

---

#### T006: TagService Query Workflows
**Description:** Implement service layer for tag queries including search, autocomplete, statistics, and task filtering by tags.

**Files Modified:**
1. `src/services/tag_service.py` (UPDATE)
2. `tests/services/test_tag_service.py` (UPDATE)

**Acceptance Criteria:**
- [ ] Methods: autocomplete(), get_popular_tags(), get_tag_usage(), filter_tasks_by_tags()
- [ ] autocomplete() limits results to reasonable count (default 10)
- [ ] filter_tasks_by_tags() supports AND logic (task has all specified tags)
- [ ] All queries respect user permissions (only see own tasks)
- [ ] Service tests verify correct filtering and statistics
- [ ] Coverage ≥90% for service query methods

**Dependencies:** T002, T004

**Estimated Time:** 75 minutes

**Delivers:** Complete query workflows with permission-aware filtering

---

### Phase 3: API

#### T007: Tag API Endpoints
**Description:** Create REST API endpoints for tag management, autocomplete, statistics, and task-tag association with OpenAPI documentation.

**Files Modified:**
1. `src/api/tags.py` (NEW)
2. `src/api/tasks.py` (UPDATE)
3. `src/main.py` (UPDATE)

**Acceptance Criteria:**
- [ ] Endpoints: POST /api/tags, GET /api/tags, DELETE /api/tags/{id}
- [ ] GET /api/tags?prefix={text} returns autocomplete suggestions
- [ ] GET /api/tags/popular returns top tags with usage counts
- [ ] PUT /api/tasks/{id}/tags sets tag array (creates missing tags)
- [ ] GET /api/tasks?tags=tag1,tag2 filters tasks by tags (AND logic)
- [ ] All endpoints require authentication and return proper HTTP status codes

**Dependencies:** T005, T006

**Estimated Time:** 90 minutes

**Delivers:** Full REST API for tag operations with proper HTTP semantics

---

#### T008: Integration Tests
**Description:** Create comprehensive end-to-end integration tests covering complete user workflows through the API layer.

**Files Modified:**
1. `tests/integration/test_tag_workflows.py` (NEW)
2. `tests/api/test_tags.py` (NEW)

**Acceptance Criteria:**
- [ ] Test workflow: Create tags → Assign to tasks → Filter → Verify results
- [ ] Test autocomplete: Search prefix → Verify ordered by usage → Use in tagging
- [ ] Test duplicate prevention: Attempt "Python" and "python" → Verify single tag
- [ ] Test permissions: User A cannot tag User B's tasks
- [ ] Test statistics: Create tagged tasks → Verify popular tags counts
- [ ] All integration tests pass with ≥85% coverage of API endpoints

**Dependencies:** T007

**Estimated Time:** 90 minutes

**Delivers:** Verified complete feature with comprehensive test coverage

---

## Dependency Graph

```
Phase 1: Foundation
┌──────────┐     ┌──────────┐
│   T001   │     │   T002   │
│ 75 min   │     │ 45 min   │
└────┬─────┘     └────┬─────┘
     │                │
     ├────────────────┼──────────────┐
     │                │              │
     ▼                ▼              ▼
┌──────────┐    ┌──────────┐   ┌──────────┐
│   T003   │    │   T004   │   │          │
│ 75 min   │    │ 75 min   │   │          │
└────┬─────┘    └────┬─────┘   │          │
     │                │         │          │
     │                │         │          │
     ▼                ▼         ▼          │
┌──────────┐    ┌──────────┐              │
│   T005   │    │   T006   │              │
│ 90 min   │    │ 75 min   │◄─────────────┘
└────┬─────┘    └────┬─────┘
     │                │
     └────────┬───────┘
              ▼
       ┌──────────┐
       │   T007   │
       │ 90 min   │
       └────┬─────┘
            ▼
       ┌──────────┐
       │   T008   │
       │ 90 min   │
       └──────────┘

Critical Path: T001 → T004 → T006 → T007 → T008 (420 min)
```

---

## Parallel Execution Analysis

### Sequential Execution (One developer)
T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008

**Total:** 615 minutes (10.25 hours)

---

### Optimal Parallel Execution

**Phase 1: Foundation (75 min)**
- T001 (75 min) - Model and junction table
- T002 (45 min) - Schemas (runs parallel, completes at 45 min)
- Max time: 75 min

**Phase 2a: Repository Layer (75 min)**
- T003 (75 min) - depends on T001, runs parallel with T004
- T004 (75 min) - depends on T001, runs parallel with T003
- Max time: 75 min

**Phase 2b: Service Layer (90 min)**
- T005 (90 min) - depends on T002, T003, runs parallel with T006
- T006 (75 min) - depends on T002, T004, runs parallel with T005 (completes at 75 min)
- Max time: 90 min

**Phase 3a: API Layer (90 min)**
- T007 (90 min) - depends on T005, T006

**Phase 3b: Integration Tests (90 min)**
- T008 (90 min) - depends on T007

**Total Parallel Time:** 420 minutes (7 hours)

**Time Savings:** 615 - 420 = 195 minutes (31.7% faster)

---

## Parallel Opportunities

### Opportunity 1: Foundation Parallelization

**What:** T001 (model) and T002 (schemas) can run simultaneously as they have no dependencies

**Why they're independent:** T001 creates database models while T002 defines Pydantic validation schemas. They work on completely different files with different concerns (persistence vs API contracts). Teams can work independently and merge without conflicts.

**Time savings:** 45 minutes (T002 completes during T001's 75-min window)

### Opportunity 2: Repository Layer Parallelization

**What:** T003 (repository core operations) and T004 (repository query features) can run simultaneously after T001

**Why they're independent:** Both depend only on T001 completing. T003 implements core CRUD operations while T004 implements advanced query features. While they modify the same file (tag_repository.py), they work on different methods with no conflicts - teams can coordinate or use feature branches and merge.

**Time savings:** 75 minutes (both 75-min tasks complete in single 75-min window vs 150 min sequential)

### Opportunity 3: Service Layer Parallelization

**What:** T005 (service mutations) and T006 (service queries) can run simultaneously after their dependencies are met

**Why they're independent:** T005 depends on T002 and T003, while T006 depends on T002 and T004. Both complete by time 150. T005 implements mutation workflows while T006 implements query workflows. While they modify the same file (tag_service.py), they work on different methods (mutations vs queries), allowing parallel development with coordination.

**Time savings:** 75 minutes (T006 completes during T005's 90-min window vs 165 min sequential)

---

## Phase Organization

### Phase 1: Foundation (75 min parallel, 120 min sequential)
**Goal:** Establish database schema and API contracts

**Tasks:**
- T001: Tag model and junction table (75 min)
- T002: Tag schemas and validation (45 min, parallel with T001)

**Deliverable:** Database can store tags with validated Pydantic schemas

### Phase 2: Logic Layer (165 min parallel, 315 min sequential)
**Goal:** Implement repository and service layers with all business logic

**Tasks:**
- T003: TagRepository core operations (75 min, depends on T001, parallel with T004)
- T004: TagRepository query features (75 min, depends on T001, parallel with T003)
- T005: TagService mutation workflows (90 min, depends on T002+T003, parallel with T006)
- T006: TagService query workflows (75 min, depends on T002+T004, parallel with T005)

**Deliverable:** Complete data access and business logic for tag management

### Phase 3: API & Testing (180 min parallel, 180 min sequential)
**Goal:** Expose via REST API and verify with comprehensive tests

**Tasks:**
- T007: Tag API endpoints (90 min, depends on T005+T006)
- T008: Integration tests (90 min, depends on T007)

**Deliverable:** Production-ready tag system with verified API

---

## Task Scope Validation

| Task | Time | Files | Criteria | Atomic? |
|------|------|-------|----------|---------|
| T001 | 75 min | 3 | 6 | ✅ |
| T002 | 45 min | 3 | 6 | ✅ |
| T003 | 75 min | 2 | 6 | ✅ |
| T004 | 75 min | 2 | 6 | ✅ |
| T005 | 90 min | 2 | 6 | ✅ |
| T006 | 75 min | 2 | 6 | ✅ |
| T007 | 90 min | 3 | 6 | ✅ |
| T008 | 90 min | 2 | 6 | ✅ |

**Verification:**
- [x] All tasks 30-90 minutes
- [x] All tasks max 3 files
- [x] All tasks have 6 criteria
- [x] Dependencies clearly stated
- [x] Each task delivers working capability

---

## Key Decisions and Rationale

### Why Introduce Repository Layer?

**Decision:** Create dedicated repository layer (tag_repository.py) separating data access from business logic

**Rationale:** Repository pattern isolates SQLAlchemy query logic from service layer, making both layers more testable and maintainable. Services can focus on business rules and orchestration while repositories handle efficient data access. This follows clean architecture principles and matches production patterns in modern Python APIs.

**Alternative considered:** Direct database access in service layer would reduce files but mix concerns, making complex queries harder to test and optimize independently.

### Why Separate Mutation and Query Service Tasks?

**Decision:** Split TagService implementation into T005 (mutations) and T006 (queries) instead of single service task

**Rationale:** Mutations (create, update, delete) and queries (search, filter, statistics) have different concerns: mutations focus on validation and state changes, queries focus on optimization and aggregation. Separating them keeps tasks atomic (60-90 min), allows parallel development, and follows CQRS principles for clearer code organization.

**Alternative considered:** Single service task would exceed 90-minute limit and create merge conflicts if multiple developers work on the feature.

### Why Store Normalized Lowercase Tag Names?

**Decision:** Store tag.name in lowercase at database level with unique constraint, not preserve original casing

**Rationale:** Database-enforced uniqueness prevents race conditions where concurrent requests create "Python" and "python". Lowercasing simplifies all queries and comparisons. Users can still display tags with custom casing in UI, but the backend treats "Python", "python", "PYTHON" as identical, which matches user expectations for tags.

**Alternative considered:** Storing original case with application-level deduplication is vulnerable to race conditions and requires complex case-insensitive index configuration varying by database vendor.

---

## Testing Strategy

### Unit Tests
**Coverage target:** ≥90%

**What to test:**
- Tag model field validation (name length, character restrictions, uniqueness)
- Schema validators (sanitization, normalization, error messages)
- Repository methods in isolation with test database
- Service business rules (permissions, ownership, duplicate prevention)

### Integration Tests
**Coverage target:** ≥85%

**What to test:**
- Complete database transactions (create tag → attach to task → verify persistence)
- Query performance with large datasets (1000+ tags, verify <100ms autocomplete)
- Concurrent operations (race condition prevention in get_or_create)
- N+1 query prevention (measure query count when fetching tasks with tags)

### End-to-End Tests
**Focus:** User workflows through API layer (T008)

**Scenarios:**
- Tag lifecycle: Create tag → Use in task → Search by tag → Delete tag → Verify cleanup
- Autocomplete workflow: Type "pyt" → Get "python, pytest" → Select → Tag task
- Multi-tag filtering: Create tasks with various tags → Filter by 2+ tags → Verify AND logic
- Permissions: User A tags their task → User B attempts to modify → Verify 403 error

---

## Summary

**Total Tasks:** 8 tasks across 3 phases

**Time:**
- Sequential: 615 minutes (10.25 hours)
- Parallel: 420 minutes (7 hours)
- Savings: 195 minutes (31.7% faster with 2 developers)

**Parallel Opportunities:** 3 major opportunities (foundation, repository layer, service layer) providing 195 minutes total savings through parallelization

**Atomic:** All tasks meet 30-90 min range, max 3 files, 6 acceptance criteria, clear dependencies

**Deliverable:** Production-ready task tagging system with:
- Many-to-many relationship using junction table
- Case-insensitive duplicate prevention via database constraints
- Repository pattern for efficient data access (no N+1 queries)
- Service layer with permission enforcement
- REST API with autocomplete, filtering, and statistics
- Comprehensive test suite (≥90% unit, ≥85% integration coverage)
