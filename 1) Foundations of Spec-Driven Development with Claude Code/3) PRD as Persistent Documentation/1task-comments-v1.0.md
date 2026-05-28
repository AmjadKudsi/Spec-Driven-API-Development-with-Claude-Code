# PRD: Task Comments

**Version:** 1.0  
**Created:** 2024-01-10  
**Owner:** Product Team  
**Status:** Approved

---

## Problem Statement

Users need a way to discuss tasks with collaborators without switching to external communication tools like Slack or email. Currently, task context is lost when discussions happen outside TaskMaster, leading to:
- Fragmented communication across multiple tools
- Lost context when revisiting tasks later
- Difficulty for team members to catch up on task discussions
- No audit trail of task-related decisions

**User Impact:**
- 62% of surveyed users report using Slack for task discussions
- Users estimate 15-20 minutes per day switching between tools
- 45% report difficulty finding historical task discussions

---

## Users and Personas

### Primary User: Task Owner
**Profile:** Individual managing 10-30 tasks, coordinating with 2-5 team members  
**Need:** Discuss task details, ask questions, provide updates  
**Pain Point:** "I wish I could discuss tasks right in TaskMaster without switching to Slack"  
**Success:** All task-related communication in one place

### Secondary User: Task Collaborator
**Profile:** Team member working on assigned tasks  
**Need:** Ask clarifying questions, provide status updates, share blockers  
**Pain Point:** "When I find a task days later, I can't remember what we discussed about it"  
**Success:** Task has complete discussion history attached

---

## Requirements

### Functional Requirements

1. **Add Comments:** Users can add text comments to any task they have access to
2. **View Comments:** Users can view all comments on a task in chronological order (oldest first)
3. **Delete Comments:** Comment authors can delete their own comments
4. **Comment Metadata:** Each comment shows author name and creation timestamp
5. **Access Control:** Only users with task access can view/add comments

### User Stories

#### US-1: Add Comment to Task
**As a** task owner  
**I want to** add comments to my tasks  
**So that** I can document decisions, questions, and updates

**Acceptance Criteria:**
- Given I own a task
- When I add a comment with text content
- Then the comment appears in the task's comment list
- And the comment shows my name and timestamp
- And other users with task access can see the comment

#### US-2: View Task Comments
**As a** team member  
**I want to** view all comments on a task  
**So that** I can understand the discussion history

**Acceptance Criteria:**
- Given I have access to a task with comments
- When I view the task
- Then I see all comments in chronological order
- And each comment shows author name and timestamp
- And comments are easy to read (formatted properly)

#### US-3: Delete Own Comment
**As a** comment author  
**I want to** delete my comments  
**So that** I can remove mistakes or outdated information

**Acceptance Criteria:**
- Given I authored a comment
- When I choose to delete it
- Then the comment is removed from the task
- And other users no longer see the deleted comment
- And the deletion is immediate (no undo)

---

## Constraints

### Technical Constraints
- Must integrate with existing Task model (src/models/task.py)
- Must use TaskMaster authentication (JWT via get_current_user)
- Must follow repository pattern per CLAUDE.md
- Must work with existing FastAPI/PostgreSQL stack

### Business Constraints
- No rich text formatting in v1.0 (plain text only)
- No file attachments in v1.0 (scope management)
- No comment threading/replies in v1.0 (flat list simpler)
- No @mentions or notifications in v1.0 (separate feature)

### Performance Constraints
- Comment list query must complete <200ms
- Adding comment must complete <100ms
- Support up to 1000 comments per task

---

## Success Metrics

### Adoption Metrics
- **Target:** 80% of teams (3+ users) use comments within first week
- **Measurement:** Count unique teams with ≥1 comment

### Usage Metrics
- **Target:** Average 3 comments per task (for tasks with comments)
- **Target:** 50% of active users add ≥1 comment per week
- **Measurement:** Track comment creation rates

### Quality Metrics
- **Target:** <5% of comments reported as spam/abuse
- **Target:** <2% of comments deleted by author within 1 hour
- **Measurement:** Monitor deletion patterns

### Performance Metrics
- **Target:** p95 latency <200ms for comment list queries
- **Target:** p95 latency <100ms for adding comments
- **Measurement:** Application performance monitoring

---

## Out of Scope

### v1.0 Does NOT Include

**Rich Text Formatting:**
- No bold, italic, links, or markdown
- Rationale: Keeps UI simple, reduces complexity
- Future: May add in v2.0 if users request

**File Attachments:**
- No images, documents, or files
- Rationale: Attachments are separate feature (planned separately)
- Future: File attachments as standalone feature

**Comment Threading:**
- No replies to specific comments
- All comments in flat chronological list
- Rationale: Threading adds UI complexity
- Future: May add if flat list proves insufficient

**@Mentions and Notifications:**
- No ability to @mention users
- No notifications when comments added
- Rationale: Notifications are separate system (complex)
- Future: Integrate when notification system exists

**Comment Editing:**
- Cannot edit comments after creation
- Must delete and re-create if wrong
- Rationale: Simplifies audit trail, reduces complexity
- Future: May add edit within 5-minute window

---

## Open Questions → Decisions

**Q:** Should task owners be able to delete others' comments?  
**A:** No - only comment authors can delete their own comments. Prevents abuse, maintains trust.

**Q:** Can users see who deleted a comment?  
**A:** No - deleted comments are hard-deleted (not soft-deleted). Keeps it simple.

**Q:** What's the maximum comment length?  
**A:** 5000 characters. Long enough for substantive comments, short enough to prevent abuse.

**Q:** Should comments be required when closing tasks?  
**A:** No - comments are optional. Not all tasks need discussion.

**Q:** Can anonymous users view comments?  
**A:** No - must be authenticated. Comments contain sensitive task information.

---

## Integration with TaskMaster

### Existing Code Integration Points

**Models:**
- Extends Task model relationship (src/models/task.py)
- References User model for author (src/models/user.py)
- Follows existing model patterns (UUIDs, timestamps, relationships)

**Authentication:**
- Uses get_current_user from src/services/auth.py
- JWT authentication required for all comment endpoints
- Same auth pattern as existing task endpoints

**Repository Pattern:**
- Follows pattern in src/repositories/task_repository.py
- CommentRepository with CRUD methods
- Dependency injection for database session

**API Structure:**
- Endpoints under /api/tasks/{id}/comments
- Follows existing /api/tasks patterns
- Standard status codes (201, 400, 401, 403, 404)

### Database

**New Tables:**
- `comments` table with: id, task_id, user_id, content, created_at, updated_at
- Foreign keys: task_id → tasks(id), user_id → users(id)
- Indexes on task_id (for listing), user_id (for author queries)

**Migrations:**
- Alembic migration following existing patterns
- Migration scripts in alembic/versions/
- Both up and down migrations (rollback support)

---

## Testing Strategy

**Unit Tests:**
- CommentRepository methods (mocked database)
- Comment model validation
- Business logic in service layer
- Target: 95%+ coverage for repository

**Integration Tests:**
- API endpoints with FastAPI TestClient
- End-to-end comment workflows
- Authorization edge cases
- Target: 90%+ coverage for API

**Performance Tests:**
- Verify <200ms for comment list queries
- Verify <100ms for comment creation
- Load test with 1000 comments per task

---

## Timeline and Effort

- **Specification:** 2 days
- **Implementation:** 3 days (models, repository, service, API)
- **Testing:** 1 day (unit + integration)
- **Review & Deploy:** 1 day
- **Total:** ~1.5 weeks

---

## Appendix: User Research

**Survey Results (n=120 users):**
- 62% use Slack for task discussions
- 45% report difficulty finding historical discussions
- 78% want integrated task comments
- Users estimate 15-20 min/day saved with integrated comments

**Feature Requests from Users:**
- "Add comments right in tasks"
- "See discussion history on tasks"
- "Don't make me switch to Slack for quick questions"

**Competitive Analysis:**
- Asana: Has comments with @mentions
- Trello: Has comments with attachments
- Jira: Has threaded comments with rich text
- **Our differentiation:** Start simple (plain text), iterate based on usage