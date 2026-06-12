# Evaluate 10 scenarios and classify each as NEEDS FULL PLAN, CAN SKIP PLAN, or BORDERLINE with brief indicator-based reasoning.
# Update only workspace/unit-1/task-4/plan-evaluation.md, complete the summary section, verify no placeholders remain, and commit the file.

# Technical Plan Evaluation Exercise

For each scenario below, classify it and provide reasoning.

**Classification Options:**
- **NEEDS FULL PLAN**: Requires comprehensive technical plan with architecture, data model, API contracts, testing strategy
- **CAN SKIP PLAN**: Can proceed directly to implementation without formal technical plan
- **BORDERLINE**: Depends on context (explain what factors would tip it either way)

---

## Scenario 1: Adding Priority Field to Tasks

**Description:** Add a "priority" field (low/medium/high) to the Task model. Update the model, repository, service, API, and tests across all layers.

**Your Classification:** BORDERLINE

**Your Reasoning:** This is a multi-layer change touching the model, repository, service, API, and tests, but follows an existing pattern already used for other fields. Small teams or experienced developers may skip a full plan and implement directly. However, if there's migration risk (existing tasks need defaults), production concerns, or team coordination needs, a lightweight plan documenting the data migration strategy would be justified.


---

## Scenario 2: Building First Real-Time Notification System

**Description:** Implement a real-time notification system using WebSockets for connections, Redis for pub/sub, and event publishing from task/comment operations. First time implementing WebSockets or Redis in this codebase.

**Your Classification:** NEEDS FULL PLAN

**Your Reasoning:** Introduces new architecture (WebSockets, Redis pub/sub) and external components for the first time. Requires designing event flow, connection management, pub/sub patterns, integration with existing task/comment operations, and error handling strategies. This level of architectural change demands a comprehensive technical plan.


---

## Scenario 3: Bug Fix - Comments Not Deleted with Tasks

**Description:** Fix a bug where deleting a task leaves orphaned comments in the database. Add cascade deletion to the existing relationship.

**Your Classification:** CAN SKIP PLAN

**Your Reasoning:** Focused bug fix using an existing relationship pattern (cascade deletion is a standard ORM feature). No new architecture or components needed. The fix is straightforward and localized to the existing Task-Comment relationship configuration.


---

## Scenario 4: Prototype OAuth Integration

**Description:** Build a throwaway prototype to evaluate whether Google OAuth integration is feasible for our authentication system. Code will not go to production.

**Your Classification:** CAN SKIP PLAN

**Your Reasoning:** Throwaway feasibility prototype for exploratory work. The code won't go to production, so a formal technical plan is unnecessary. The goal is rapid experimentation to evaluate feasibility, not production-ready implementation.


---

## Scenario 5: Add Another Endpoint to Existing Comments API

**Description:** Add GET /api/comments/{id}/history endpoint to show comment edit history. Comments API already exists with established patterns. Repository already has get_comment_history() method.

**Your Classification:** CAN SKIP PLAN

**Your Reasoning:** Small endpoint addition to an existing API using established patterns. The repository method already exists, so this is simply exposing existing functionality through a new endpoint. Follows the existing architectural pattern with minimal complexity.


---

## Scenario 6: Implement File Attachments with S3 Storage

**Description:** Allow users to attach files to tasks. Requires: Attachment model, S3 client for cloud storage, file validation (MIME types, size limits, virus scanning), upload/download/delete API endpoints, presigned URLs for secure access.

**Your Classification:** NEEDS FULL PLAN

**Your Reasoning:** Introduces new model, external system (S3), security concerns (file validation, virus scanning, presigned URLs), and multiple new API endpoints (upload/download/delete). This complexity requires a full design covering data model, security strategy, S3 integration patterns, error handling, and API contracts.


---

## Scenario 7: Migrate from Session-Based to JWT Authentication

**Description:** Replace current session-based authentication with JWT tokens. Affects: authentication middleware, login/register endpoints, token generation/validation, user session management.

**Your Classification:** NEEDS FULL PLAN

**Your Reasoning:** Authentication architecture migration that is security-sensitive and cross-cutting. Affects middleware, multiple endpoints, and session management. Requires careful planning of token generation/validation strategy, refresh token handling, migration path, and security considerations. This type of architectural change demands a comprehensive plan.


---

## Scenario 8: Add Pagination Limit Configuration

**Description:** Change hardcoded pagination limit from 50 to a configurable value in config.py. Update API documentation to reflect this.

**Your Classification:** CAN SKIP PLAN

**Your Reasoning:** Small configuration change following an existing pattern for config values, plus a documentation update. No architectural changes or new components. Straightforward implementation that doesn't require formal planning.


---

## Scenario 9: Refactor All Repositories to Async

**Description:** Convert all repository methods from synchronous to async/await. Affects 5 repositories (User, Task, Comment, Attachment, Notification), all services that call them, and all API endpoints.

**Your Classification:** NEEDS FULL PLAN

**Your Reasoning:** Cross-codebase architectural refactor affecting repositories, services, and APIs across the entire application. This architectural change requires planning the migration strategy, identifying dependencies, determining rollout approach (incremental vs. all-at-once), and ensuring all async/await patterns are correctly implemented throughout the call chain.


---

## Scenario 10: Add Validation to Comment Length

**Description:** Add validation to the CommentService to enforce 1-5000 character limit for comment content. Currently only validated in the schema.

**Your Classification:** CAN SKIP PLAN

**Your Reasoning:** Small validation addition to an existing service layer using the existing service pattern. No new architecture or components. This is a straightforward enhancement to add server-side validation for an existing constraint.


---

## Summary

After completing your evaluations, reflect on these questions:

**What patterns did you notice?**

Tasks introducing new architecture, external systems, or security changes consistently need full plans. Bug fixes, config changes, and small additions to existing patterns can skip planning. Multi-layer changes following established patterns are borderline and depend on team context and risk factors.

**What indicators most strongly suggested "needs a plan"?**

New external systems (Redis, S3, WebSockets), security/authentication changes, architectural migrations (sync to async), and cross-cutting refactors affecting multiple components. First-time implementations of new technologies or patterns also strongly indicate need for planning.

**What indicators most strongly suggested "can skip"?**

Bug fixes using existing patterns, throwaway prototypes, small config/documentation updates, adding endpoints to established APIs with existing repository methods, and isolated validation additions to existing service layers.

**Which scenarios were hardest to classify? Why?**

Scenario 1 (adding priority field) was hardest because it touches multiple layers but follows existing patterns. The classification depends on context: small teams with simple migrations can skip, but production systems with data migration concerns or larger teams needing coordination benefit from a lightweight plan.