# Use Claude Code to analyze TaskMaster’s existing codebase and generate a complete PRD for Task Reminders that matches real project patterns, not guessed code
# The PRD should focus on the why/what, while referencing real models, auth, API, and repository conventions, similar to how the Task Comments PRD references TaskMaster integration points.

# Product Requirements Document: Task Reminders v1.0

**Version:** 1.0
**Status:** Draft
**Last Updated:** 2026-05-29
**Owner:** Product Team
**Engineering Lead:** TBD

---

## Table of Contents
1. [Problem Statement](#problem-statement)
2. [Personas](#personas)
3. [Requirements](#requirements)
4. [User Stories](#user-stories)
5. [Constraints](#constraints)
6. [Success Metrics](#success-metrics)
7. [Out of Scope](#out-of-scope)
8. [Technical Decisions](#technical-decisions)
9. [Integration Points](#integration-points)
10. [Testing Strategy](#testing-strategy)
11. [Timeline](#timeline)

---

## Problem Statement

TaskMaster users currently have no systematic way to receive proactive notifications about upcoming or overdue tasks. While tasks can have due dates, users must manually check the application to monitor deadlines. This leads to:

- **Missed deadlines**: Users forget about tasks until it's too late
- **Reactive task management**: Users discover overdue tasks only when reviewing their task list
- **Reduced productivity**: Lack of timely reminders forces users to maintain external reminder systems
- **Poor user engagement**: Without proactive notifications, users don't return to the application regularly

A reminder system will enable users to set customizable notifications for their tasks, ensuring they stay on top of deadlines and maintain productive workflows.

---

## Personas

### Primary Persona: Sarah - The Busy Professional
**Role:** Project Manager
**Age:** 32
**Tech Savviness:** High

**Goals:**
- Manage multiple projects with overlapping deadlines
- Receive timely notifications without being overwhelmed
- Set reminders at strategic times (morning of due date, day before, etc.)

**Pain Points:**
- Forgets to check TaskMaster regularly
- Misses critical deadlines when juggling multiple priorities
- Needs advance warning to prepare for deadline-driven tasks

**Reminder Usage:**
- Sets multiple reminders per task (e.g., 1 week before, 1 day before, morning of)
- Uses daily recurring reminders for routine tasks
- Wants notifications via WebSocket for real-time alerts

### Secondary Persona: Michael - The Freelancer
**Role:** Independent Contractor
**Age:** 28
**Tech Savviness:** Medium

**Goals:**
- Track client deliverables with firm deadlines
- Maintain work-life balance with structured reminders
- Use simple, predictable reminder patterns

**Pain Points:**
- Works across multiple time zones and loses track of deadlines
- Needs consistent daily reminders for ongoing tasks
- Overwhelmed by complex scheduling systems

**Reminder Usage:**
- Sets single reminder per task (usually day before)
- Uses daily recurrence for routine client check-ins
- Prefers straightforward reminder interface

---

## Requirements

### Functional Requirements

#### FR1: Create Task Reminders
- Users SHALL be able to create reminders for tasks they own
- Each reminder SHALL have a due date and time (timezone-aware)
- Each reminder SHALL have an optional description field (max 500 characters)
- Each reminder SHALL support recurrence: `none`, `daily`, `weekly`
- Multiple reminders per task SHALL be supported (up to 10 per task)
- Creating a reminder SHALL require authentication and task ownership verification

#### FR2: List Task Reminders
- Users SHALL be able to view all reminders for a specific task
- Users SHALL be able to view all their upcoming reminders across all tasks
- Reminder lists SHALL include reminder status: `pending`, `sent`, `completed`
- Reminder lists SHALL support pagination (skip/limit pattern)
- Reminders SHALL be ordered by due date (ascending)

#### FR3: Update Task Reminders
- Users SHALL be able to mark reminders as completed
- Users SHALL be able to update reminder due date, description, and recurrence
- Status transitions SHALL be validated:
  - `pending` � `sent` (system-triggered only)
  - `pending` � `completed` (user action)
  - `sent` � `completed` (user action)
- Updating a reminder SHALL update the `updated_at` timestamp

#### FR4: Delete Task Reminders
- Users SHALL be able to delete reminders for tasks they own
- Deleting a task SHALL cascade-delete all associated reminders
- Deleting a completed reminder SHALL be allowed (for cleanup)
- Deleting a pending recurring reminder SHALL not affect already-sent occurrences

#### FR5: Reminder Notifications
- When a reminder's due datetime is reached, a notification SHALL be sent via WebSocket
- Notification payload SHALL include: task details, reminder description, reminder ID
- After sending, reminder status SHALL transition from `pending` to `sent`
- For recurring reminders:
  - Daily: Next reminder SHALL be created for +1 day
  - Weekly: Next reminder SHALL be created for +7 days
  - Next reminder SHALL inherit description and recurrence settings
- Sent recurring reminders SHALL remain as `sent` (not deleted)
- Notifications SHALL only be sent to active users (`is_active = True`)

#### FR6: Reminder Validation
- Reminder due datetime SHALL be in the future (at creation time)
- Reminder due datetime SHALL use timezone-aware timestamps (UTC)
- Task ownership SHALL be verified before any reminder operation
- Recurrence type SHALL be validated against enum: `none`, `daily`, `weekly`

#### FR7: Reminder Business Rules
- Reminders SHALL only be created for tasks in `pending` or `in_progress` status
- When a task transitions to `completed` status, all pending reminders SHALL remain but not trigger notifications
- Reminders SHALL only send notifications if the task owner's `is_active` status is `True`
- Reminder ownership follows task ownership (if task is transferred, reminders go with it)
- Notifications SHALL only be delivered to users with active WebSocket connections
- Users not connected at notification time SHALL not receive missed notifications (no queuing)
- Recurring reminders SHALL stop generating new occurrences once marked `completed`

### Non-Functional Requirements

#### NFR1: Performance
- Reminder listing SHALL return results in <200ms for up to 100 reminders
- Notification delivery SHALL occur within 60 seconds of due datetime
- Background reminder processor SHALL check for due reminders every 30 seconds

#### NFR2: Scalability
- System SHALL support up to 10,000 active reminders per user
- System SHALL support up to 1 million total reminders across all users
- Reminder processor SHALL handle up to 1,000 notifications per minute

#### NFR3: Reliability
- Reminder notifications SHALL have 99.5% delivery rate
- Failed notifications SHALL be retried up to 3 times with exponential backoff
- Reminder processor SHALL recover gracefully from crashes

#### NFR4: Security
- All reminder endpoints SHALL require JWT authentication
- Users SHALL only access reminders for tasks they own
- Reminder descriptions SHALL be sanitized to prevent XSS

---

## User Stories

### Epic 1: Reminder Creation

**US1.1: Create Simple Reminder**
*As a TaskMaster user,*
*I want to create a one-time reminder for my task,*
*So that I receive a notification at a specific date and time.*

**Acceptance Criteria:**
- User can specify due date and time via API
- User can optionally add a description
- Recurrence defaults to "none"
- API returns 201 with reminder details
- Reminder appears in task's reminder list

---

**US1.2: Create Recurring Reminder**
*As a project manager,*
*I want to set daily reminders for ongoing tasks,*
*So that I'm consistently prompted to work on them.*

**Acceptance Criteria:**
- User can select "daily" or "weekly" recurrence
- First reminder is created with specified due datetime
- After first reminder is sent, next occurrence is auto-created
- Recurring reminders can be completed individually
- Parent task shows all future occurrences

---

**US1.3: Create Multiple Reminders**
*As a busy professional,*
*I want to set multiple reminders for important tasks,*
*So that I receive advance warnings at different intervals.*

**Acceptance Criteria:**
- User can create up to 10 reminders per task
- Each reminder has independent due datetime
- Each reminder can have different description
- API returns 400 if limit exceeded
- All reminders shown in task reminder list

---

### Epic 2: Reminder Management

**US2.1: View Task Reminders**
*As a user,*
*I want to see all reminders for a specific task,*
*So that I know when I'll be notified.*

**Acceptance Criteria:**
- GET endpoint returns all reminders for task
- Response includes due datetime, description, status, recurrence
- Reminders ordered by due datetime (ascending)
- Only task owner can view reminders
- Pagination supported (skip/limit)

---

**US2.2: View Upcoming Reminders**
*As a user,*
*I want to see all my upcoming reminders across all tasks,*
*So that I can plan my schedule accordingly.*

**Acceptance Criteria:**
- GET endpoint returns user's reminders across all tasks
- Can filter by status (pending, sent, completed)
- Can filter by date range
- Response includes task details (title, priority)
- Pagination supported

---

**US2.3: Mark Reminder Complete**
*As a user,*
*I want to mark a reminder as completed,*
*So that I can track which reminders I've acted on.*

**Acceptance Criteria:**
- PUT endpoint updates reminder status to "completed"
- Completed reminders remain in database (not deleted)
- Completed recurring reminders don't generate new occurrences
- Status transition validated (pending/sent � completed only)
- Returns 200 with updated reminder

---

**US2.4: Delete Reminder**
*As a user,*
*I want to delete reminders I no longer need,*
*So that I'm not notified unnecessarily.*

**Acceptance Criteria:**
- DELETE endpoint removes reminder from database
- Only task owner can delete reminders
- Returns 204 on success
- Deleted reminders don't send notifications
- Can delete pending or completed reminders

---

### Epic 3: Reminder Notifications

**US3.1: Receive Reminder Notification**
*As a user,*
*I want to receive a real-time notification when my reminder is due,*
*So that I'm immediately aware of the task.*

**Acceptance Criteria:**
- WebSocket notification sent at due datetime (�60 seconds)
- Notification includes task title, description, priority, due date
- Notification includes reminder description
- Notification type is "task_reminder"
- Reminder status changes to "sent"

---

**US3.2: Recurring Reminder Behavior**
*As a user,*
*I want recurring reminders to automatically create the next occurrence,*
*So that I don't have to manually recreate them.*

**Acceptance Criteria:**
- After daily reminder sent, new reminder created for +1 day
- After weekly reminder sent, new reminder created for +7 days
- Next occurrence inherits description and recurrence type
- Previous occurrence remains as "sent" status
- User can complete or delete future occurrences

---

## Constraints

### Technical Constraints

**TC1: Database**
- Must use PostgreSQL with UUID primary keys (existing pattern)
- Must use SQLAlchemy ORM (existing pattern)
- Must use timezone-aware DateTime columns (existing pattern)
- Reminder table must support cascade deletion from Task table

**TC2: API Framework**
- Must use FastAPI with async support (existing pattern)
- Must use Pydantic schemas for validation (existing pattern)
- Must follow existing API patterns: `Depends(get_db)`, `Depends(get_current_user)`
- Must return appropriate HTTP status codes (201, 200, 204, 400, 403, 404)

**TC3: Authentication**
- Must use JWT Bearer token authentication (existing pattern)
- Must use `get_current_user` dependency for all endpoints
- Must verify task ownership before reminder operations

**TC4: Notification System**
- Must use existing WebSocket notification service
- Must follow existing notification payload structure
- Must integrate with `notification_service.send_notification()`

### Business Constraints

**BC1: Reminder Limits**
- Maximum 10 reminders per task (prevent spam)
- Maximum 10,000 active reminders per user (resource limits)
- Reminder due datetime must be within 1 year from creation

**BC2: Recurrence Patterns**
- v1.0 supports only: none, daily, weekly
- Custom intervals (every 3 days, monthly, etc.) are out of scope
- Recurring reminders don't have end dates (user must delete)

**BC3: Notification Delivery**
- Notifications only sent via WebSocket (no email/SMS in v1.0)
- Users must be connected to WebSocket to receive notifications
- Missed notifications (when disconnected) are not queued

---

## Success Metrics

### Primary Metrics

**PM1: Adoption Rate**
- Target: 60% of active users create at least one reminder within 30 days of feature launch
- Measurement: SQL query on `reminders.user_id` vs `users` table
- Tracking: Daily dashboard query, report weekly
- Data source: `reminders` and `users` tables

**PM2: Reminder Usage per Task**
- Target: Average 3 reminders per task (for tasks with reminders)
- Measurement: Total reminder count divided by distinct task count
- Tracking: Weekly analytics query
- Data source: `reminders` table grouped by `task_id`

**PM3: Notification Delivery Timeliness**
- Target: 99.5% of reminders send notifications within 60 seconds of `due_at`
- Measurement: Log timestamp when notification sent, compare to `due_at` field
- Tracking: Application logging with timestamp tracking, daily aggregation
- Data source: Application logs and `reminders.due_at` field

### Secondary Metrics

**SM1: Recurring Reminder Adoption**
- Target: 30% of reminders use daily or weekly recurrence
- Measurement: Query `reminders.recurrence` field, count non-'none' values
- Tracking: Monthly analytics review
- Data source: `reminders.recurrence` column

**SM2: Reminder Completion Rate**
- Target: 70% of sent reminders are marked completed within 7 days
- Measurement: Compare `status='completed'` vs `status='sent'` where `updated_at - created_at <= 7 days`
- Tracking: Weekly analytics query
- Data source: `reminders.status`, `reminders.created_at`, `reminders.updated_at`

**SM3: User Engagement Increase**
- Target: 40% increase in daily active users after reminder launch
- Measurement: Count distinct users making API requests per day, compare 30-day average pre/post launch
- Tracking: Daily active user metrics from API logs
- Data source: API access logs, JWT token authentication records

### Health Metrics

**HM1: API Response Time**
- Target: P95 response time for reminder endpoints <300ms
- Measurement: Track response times for all reminder API endpoints
- Tracking: Continuous monitoring via application logging
- Data source: API response time logs

**HM2: Background Processing Performance**
- Target: Reminder processing cycle completes in <5 seconds per run
- Measurement: Log start and end time of each processor cycle
- Tracking: Continuous monitoring via processor logs
- Data source: Background processor service logs

**HM3: Error Rates**
- Target: Reminder creation error rate <1%, notification send error rate <0.5%
- Measurement: Count 4xx/5xx responses for reminder endpoints, count notification send failures
- Tracking: Daily error rate aggregation from logs
- Data source: API error logs, notification service error logs

---

## Out of Scope

The following features are explicitly out of scope for v1.0:

### OS1: Advanced Recurrence
- Custom intervals (every 3 days, every 2 weeks, etc.)
- Monthly recurrence (specific day of month)
- Complex patterns (e.g., "every weekday", "first Monday of month")
- End dates for recurring reminders
- **Rationale:** Adds significant complexity; evaluate demand post-v1.0

### OS2: Multiple Notification Channels
- Email notifications
- SMS notifications
- Push notifications (mobile)
- Slack/Discord integrations
- **Rationale:** Requires integration with external services; prioritize core functionality first

### OS3: Reminder Snooze
- Snooze reminder for custom duration
- Multiple snooze options (5 min, 1 hour, 1 day)
- **Rationale:** Adds UI/UX complexity; evaluate post-v1.0 based on user feedback

### OS4: Shared Task Reminders
- Reminders for tasks shared with other users
- Team-wide reminder broadcasts
- **Rationale:** TaskMaster doesn't support task sharing yet; prerequisite feature

### OS5: Smart Reminders
- AI-suggested reminder times based on user behavior
- Automatic reminder creation based on due dates
- Priority-based reminder frequency
- **Rationale:** Requires ML infrastructure; future enhancement

### OS6: Reminder Templates
- Save reminder patterns as templates
- Apply templates to multiple tasks
- **Rationale:** Nice-to-have; evaluate demand post-v1.0

### OS7: Reminder History
- Detailed logs of all sent reminders
- Reminder effectiveness analytics
- **Rationale:** Focus on core functionality first; analytics in future version

---

## Technical Decisions

### TD1: Data Model

**Decision:** Create new `Reminder` database table with fields for scheduling and status tracking

**Key Fields:**
- `id`: UUID primary key (follows existing pattern: Task, User, Comment)
- `task_id`: Foreign key to tasks table with cascade delete
- `user_id`: Foreign key to users table (denormalized from task.owner_id for query performance)
- `due_at`: Timezone-aware datetime for when notification should trigger
- `description`: Optional text field (max 500 chars) for reminder context
- `recurrence`: Enum: none, daily, weekly (follows existing TaskStatus enum pattern)
- `status`: Enum: pending, sent, completed (similar to Task.status)
- `created_at`, `updated_at`: Timestamp tracking (existing pattern)

**Relationships:**
- Task has many Reminders (one-to-many, cascade delete)
- User has many Reminders (one-to-many, cascade delete)
- Follows existing relationship pattern from Task-Comment and User-Comment

**Rationale:**
- Consistent with existing TaskMaster database patterns (UUID, timezone-aware, enums)
- Denormalized user_id improves query performance for user-wide reminder lists
- Cascade deletion ensures data integrity when tasks or users are deleted
- Status tracking enables audit trail and recurring reminder management

---

### TD2: API Design

**Decision:** RESTful API following existing TaskMaster endpoint patterns

**Endpoints:**
```
POST   /api/tasks/{task_id}/reminders          Create reminder
GET    /api/tasks/{task_id}/reminders          List task reminders
GET    /api/reminders/upcoming                 List user's upcoming reminders
PUT    /api/reminders/{reminder_id}            Update reminder
DELETE /api/reminders/{reminder_id}            Delete reminder
PUT    /api/reminders/{reminder_id}/complete   Mark reminder complete
```

**Rationale:**
- Nested routes for task-specific reminders (follows comments pattern)
- Top-level routes for cross-task operations (follows existing pattern)
- Separate `/complete` endpoint for clarity (explicit action)
- Uses existing auth patterns: `Depends(get_current_user)`
- Follows existing response patterns: Pydantic schemas

---

### TD3: Background Reminder Processor

**Decision:** Implement scheduled background service to check for due reminders and trigger notifications

**Approach:**
- Background service runs on 30-second intervals
- Queries database for reminders where `due_at <= current_time` and `status = 'pending'`
- Sends notifications via existing WebSocket notification service
- Updates reminder status to 'sent'
- For recurring reminders, creates next occurrence with appropriate time offset
- Service starts with application startup, stops on shutdown

**Technology Choice:** APScheduler (async-compatible Python scheduler)
- Lightweight, no external infrastructure (Redis, RabbitMQ) required
- Integrates with existing FastAPI async architecture
- Similar singleton pattern to existing notification_service

**Rationale:**
- 30-second check interval provides notifications within 60-second target window
- Scheduled approach simpler than event-driven for v1.0
- Reuses existing notification infrastructure (no new channels needed)
- Minimal operational complexity for initial release

---

### TD4: Notification Integration

**Decision:** Use existing WebSocket notification service without modification

**Integration Approach:**
- Background processor calls existing `notification_service.send_notification()` method
- New notification type: `"task_reminder"`
- Payload follows existing pattern: `{type, data}` structure
- Includes task context (title, priority, due_date) and reminder details in payload
- Leverages existing WebSocket connection management
- No changes required to notification service code

**Notification Delivery:**
- Notifications only sent to users with active WebSocket connections (existing behavior)
- If user not connected, notification is not queued (existing limitation)
- Follows existing pattern from task status updates and comment notifications

**Rationale:**
- Zero changes to proven notification infrastructure
- Consistent user experience across all notification types
- Reduced implementation complexity and risk

---

### TD5: Recurring Reminder Implementation

**Decision:** Create new reminder record after sending (preserve history approach)

**Behavior:**
When a recurring reminder is sent:
1. Original reminder status updated to 'sent' (preserved for history)
2. New reminder record created with:
   - Due date: +1 day (daily) or +7 days (weekly) from original
   - Same description and recurrence setting
   - Status: pending
3. Users can complete or delete future occurrences independently

**Rationale:**
- Maintains audit trail of all sent reminders
- Simpler than updating single record with "next occurrence" calculation
- Users have control over each occurrence (can delete future ones)
- Aligns with user expectation that each occurrence is distinct

**Trade-offs:**
- Generates more database records over time (acceptable for v1.0 scale)
- Old "sent" reminders accumulate (future cleanup feature needed)

---

### TD6: Timezone Handling

**Decision:** Store all reminder datetimes in UTC (follows existing TaskMaster pattern)

**Approach:**
- Database stores all timestamps in UTC (consistent with existing Task.due_date pattern)
- API accepts ISO 8601 datetime strings with timezone information
- Background processor uses UTC for all time comparisons
- API responses return UTC timestamps in ISO 8601 format
- Client applications responsible for displaying user's local timezone

**Rationale:**
- Consistent with existing TaskMaster timezone handling for tasks
- Prevents timezone conversion bugs in reminder processing
- Simplifies server-side logic (single timezone)
- Standard practice for distributed systems with global users

---

## Integration Points

### IP1: Database Layer

**Location:** `src/database.py`, database migration scripts

**Changes Required:**
- Create new `reminders` table with appropriate schema
- Add foreign keys to `tasks` and `users` tables with cascade delete
- Create indexes for common queries: by task_id, by user_id, by status+due_at
- No changes to existing tables or `get_db()` dependency function

**Impact:** Low - Additive only, existing functionality unaffected

---

### IP2: Model Layer

**Location:** `src/models/`

**Changes Required:**
- Create new `reminder.py` with Reminder model, ReminderStatus enum, ReminderRecurrence enum
- Add relationship to Task model: `reminders` (one-to-many, cascade delete)
- Add relationship to User model: `reminders` (one-to-many, cascade delete)
- Update `__init__.py` to export new model

**Impact:** Low - Relationship additions only, no breaking changes to existing models

---

### IP3: Schema Layer

**Location:** `src/schemas/`

**Changes Required:**
- Create new `reminder.py` with Pydantic schemas
- Schemas needed: ReminderCreate, ReminderUpdate, ReminderResponse, ReminderWithTask, ReminderList
- Follow existing patterns: TaskCreate/TaskUpdate/TaskResponse/TaskList structure
- Update `__init__.py` to export new schemas

**Impact:** Low - New file only, follows existing validation patterns

---

### IP4: API Layer

**Location:** `src/api/`

**Changes Required:**
- Create new `reminders.py` with router and 6 endpoints (create, list task reminders, list upcoming, update, delete, complete)
- Register router in `__init__.py` exports
- Include router in main application (`src/main.py`)
- All endpoints use existing `get_current_user` and `get_db` dependencies

**Impact:** Low - New router, no changes to existing API routes

---

### IP5: Notification Service

**Location:** `src/services/notification.py`

**Changes Required:**
- No code changes required
- Background processor will call existing `send_notification()` method
- Add new notification type constant: `"task_reminder"`

**Impact:** None - Pure consumption of existing service

---

### IP6: Background Processor Service

**Location:** `src/services/`

**Changes Required:**
- Create new `reminder_processor.py` with scheduled job logic
- Register service startup/shutdown in `src/main.py` application events
- Add APScheduler dependency to requirements

**Impact:** Medium - New background service requires application lifecycle integration

---

### IP7: Authentication Integration

**Location:** `src/services/auth.py`

**Changes Required:**
- No changes required
- All reminder endpoints will use existing `get_current_user` dependency
- Task ownership verification follows existing pattern from Task and Comment APIs

**Impact:** None - Pure consumption of existing authentication

---

## Testing Strategy

### Unit Tests

**UT1: Model Tests** (`tests/models/test_reminder.py`)
- Test Reminder model creation with valid data
- Test enum validation (ReminderRecurrence, ReminderStatus)
- Test relationship integrity (task, user)
- Test cascade deletion (delete task � reminders deleted)
- Test default values (status=pending, recurrence=none)

**UT2: Schema Tests** (`tests/schemas/test_reminder.py`)
- Test ReminderCreate validation (due_at required, description max length)
- Test ReminderUpdate validation (all fields optional)
- Test ReminderResponse serialization
- Test invalid enum values rejected

**UT3: API Endpoint Tests** (`tests/api/test_reminders.py`)
- Test create reminder: success (201), unauthorized (401), forbidden (403), not found (404)
- Test list task reminders: success (200), pagination, filtering
- Test update reminder: success (200), validation errors (400)
- Test delete reminder: success (204), not found (404)
- Test complete reminder: success (200), invalid status transition (400)
- Test reminder limit enforcement (max 10 per task)

### Integration Tests

**IT1: End-to-End Reminder Flow** (`tests/integration/test_reminder_flow.py`)
- Create task � Create reminder � Verify in database
- Update reminder � Verify changes persisted
- Complete reminder � Verify status change
- Delete reminder � Verify removal from database
- Delete task � Verify cascade deletion of reminders

**IT2: Notification Integration** (`tests/integration/test_reminder_notifications.py`)
- Mock reminder processor
- Create past-due reminder
- Trigger processor
- Verify notification sent via WebSocket
- Verify reminder status updated to 'sent'

**IT3: Recurring Reminder Flow** (`tests/integration/test_recurring_reminders.py`)
- Create daily recurring reminder
- Trigger processor (past due time)
- Verify notification sent
- Verify original reminder status = 'sent'
- Verify new reminder created with due_at = +1 day
- Repeat for weekly recurrence

### System Tests

**ST1: Background Processor** (`tests/system/test_reminder_processor.py`)
- Start processor service
- Create multiple reminders with different due times
- Wait for processing cycle
- Verify all due reminders processed
- Verify pending future reminders untouched
- Verify processor handles database errors gracefully

**ST2: Performance Tests** (`tests/performance/test_reminder_load.py`)
- Create 1,000 reminders across 100 tasks
- Query list endpoints
- Verify response times <200ms (P95)
- Test processor with 100 simultaneous due reminders
- Verify all processed within 60 seconds

**ST3: Timezone Tests** (`tests/system/test_reminder_timezones.py`)
- Create reminders with various timezone offsets
- Verify storage in UTC
- Verify correct processing at due time
- Verify correct serialization in responses

### Manual Testing

**MT1: User Acceptance Testing**
- Create reminder via API and verify WebSocket notification received
- Test recurring reminders across multiple days
- Test marking reminders complete
- Test deleting reminders
- Test multiple reminders per task

**MT2: Edge Cases**
- Create reminder with due_at in past (should fail)
- Create 11th reminder on task (should fail)
- Create reminder on non-existent task (should fail)
- Update reminder with invalid status transition (should fail)
- Test WebSocket reconnection (verify notifications still work)

---

## Timeline

### Phase 1: Foundation (Week 1)
**Goal:** Database and model layer complete

- **Day 1-2:** Database schema design and migration
  - Create `reminders` table with indexes
  - Run migration on dev environment
  - Verify cascade deletion behavior

- **Day 3-4:** Model implementation
  - Create `src/models/reminder.py`
  - Add relationships to Task and User models
  - Write model unit tests
  - Achieve 100% model test coverage

- **Day 5:** Schema implementation
  - Create `src/schemas/reminder.py`
  - Define all request/response schemas
  - Write schema validation tests

**Deliverables:**
- `reminders` table created
- Reminder model with relationships
- Pydantic schemas with validation
- Unit tests passing

---

### Phase 2: API Layer (Week 2)
**Goal:** All reminder endpoints functional

- **Day 1-3:** CRUD endpoints
  - POST /api/tasks/{task_id}/reminders
  - GET /api/tasks/{task_id}/reminders
  - GET /api/reminders/upcoming
  - PUT /api/reminders/{reminder_id}
  - DELETE /api/reminders/{reminder_id}
  - PUT /api/reminders/{reminder_id}/complete
  - Write endpoint unit tests

- **Day 4-5:** API integration tests
  - End-to-end flow tests
  - Authorization tests (ownership verification)
  - Error handling tests (400, 403, 404)
  - Pagination tests

**Deliverables:**
- All 6 endpoints implemented
- API tests passing
- Postman collection for manual testing

---

### Phase 3: Background Processor (Week 3)
**Goal:** Reminder notifications working

- **Day 1-2:** Processor implementation
  - Create `src/services/reminder_processor.py`
  - Implement APScheduler integration
  - Query logic for due reminders
  - Notification sending logic

- **Day 3:** Recurring reminder logic
  - Implement daily recurrence
  - Implement weekly recurrence
  - Create next occurrence after sending

- **Day 4-5:** Processor testing
  - Unit tests for processor methods
  - Integration tests with notification service
  - System tests with real database
  - Performance testing (100 simultaneous reminders)

**Deliverables:**
- ReminderProcessor service functional
- Notifications sent for due reminders
- Recurring reminders working
- All tests passing

---

### Phase 4: Integration & Testing (Week 4)
**Goal:** Production-ready system

- **Day 1-2:** End-to-end testing
  - Full user flow testing
  - WebSocket integration testing
  - Timezone testing
  - Edge case testing

- **Day 3:** Performance testing
  - Load testing with 1,000+ reminders
  - Processor performance under load
  - API response time verification (P95 <300ms)
  - Database query optimization if needed

- **Day 4:** Documentation
  - API documentation (OpenAPI/Swagger)
  - Deployment guide
  - Monitoring setup guide
  - User-facing documentation

- **Day 5:** Bug fixes and polish
  - Address issues from testing
  - Code review feedback
  - Final QA pass

**Deliverables:**
- All tests passing (unit, integration, system)
- Performance benchmarks met
- Documentation complete
- Ready for deployment

---

### Phase 5: Deployment & Monitoring (Week 5)
**Goal:** Live in production with monitoring

- **Day 1:** Staging deployment
  - Deploy to staging environment
  - Run smoke tests
  - Manual UAT with stakeholders

- **Day 2:** Production deployment
  - Database migration on production
  - Deploy application code
  - Start background processor
  - Verify WebSocket notifications working

- **Day 3-4:** Monitoring setup
  - Set up APM metrics (response times, error rates)
  - Set up processor health checks
  - Set up notification delivery metrics
  - Configure alerts (error rate >1%, P95 >500ms)

- **Day 5:** Post-launch monitoring
  - Monitor metrics closely
  - Address any immediate issues
  - Gather initial user feedback
  - Document lessons learned

**Deliverables:**
- Production deployment complete
- Monitoring dashboards live
- Success metrics tracking started
- Post-launch retrospective

---

### Summary Timeline

| Phase | Duration | Key Milestone |
|-------|----------|---------------|
| Phase 1: Foundation | Week 1 | Database and models complete |
| Phase 2: API Layer | Week 2 | All endpoints functional |
| Phase 3: Background Processor | Week 3 | Notifications working |
| Phase 4: Integration & Testing | Week 4 | Production-ready |
| Phase 5: Deployment & Monitoring | Week 5 | Live in production |

**Total Duration:** 5 weeks (25 business days)

**Critical Path:**
1. Database schema � Models � API endpoints � Processor � Deployment
2. Any delay in Phases 1-2 will delay Phase 3 (processor depends on models)
3. Testing can run parallel with development (TDD approach)

**Risk Mitigation:**
- Start processor work in Week 2 (parallel with API endpoints)
- Continuous testing throughout (don't wait until Week 4)
- Daily standups to identify blockers early
- Staging environment ready by end of Week 3

---

## Appendix

### A. API Request/Response Examples

**Create Reminder:**
```http
POST /api/tasks/123e4567-e89b-12d3-a456-426614174000/reminders
Authorization: Bearer <token>
Content-Type: application/json

{
  "due_at": "2026-06-01T09:00:00Z",
  "description": "Review project deliverables",
  "recurrence": "none"
}

Response: 201 Created
{
  "id": "987fcdeb-51a2-43f1-b123-567890abcdef",
  "task_id": "123e4567-e89b-12d3-a456-426614174000",
  "user_id": "456e7890-e12b-34c5-d678-901234567abc",
  "due_at": "2026-06-01T09:00:00Z",
  "description": "Review project deliverables",
  "recurrence": "none",
  "status": "pending",
  "created_at": "2026-05-29T10:30:00Z",
  "updated_at": "2026-05-29T10:30:00Z"
}
```

**List Upcoming Reminders:**
```http
GET /api/reminders/upcoming?status=pending&skip=0&limit=50
Authorization: Bearer <token>

Response: 200 OK
{
  "reminders": [
    {
      "id": "987fcdeb-51a2-43f1-b123-567890abcdef",
      "task_id": "123e4567-e89b-12d3-a456-426614174000",
      "task_title": "Complete project proposal",
      "task_priority": 1,
      "task_status": "in_progress",
      "due_at": "2026-06-01T09:00:00Z",
      "description": "Review project deliverables",
      "recurrence": "none",
      "status": "pending",
      "created_at": "2026-05-29T10:30:00Z",
      "updated_at": "2026-05-29T10:30:00Z"
    }
  ],
  "total": 1,
  "skip": 0,
  "limit": 50
}
```

**WebSocket Notification:**
```json
{
  "type": "task_reminder",
  "data": {
    "reminder_id": "987fcdeb-51a2-43f1-b123-567890abcdef",
    "task_id": "123e4567-e89b-12d3-a456-426614174000",
    "task_title": "Complete project proposal",
    "task_priority": 1,
    "task_due_date": "2026-06-05T17:00:00Z",
    "reminder_description": "Review project deliverables",
    "reminder_due_at": "2026-06-01T09:00:00Z"
  }
}
```

### B. Database Indexes

```sql
-- Primary queries optimized:

-- 1. Find due reminders for processing
CREATE INDEX idx_reminders_status_due_at ON reminders(status, due_at);
-- Query: WHERE status = 'pending' AND due_at <= NOW()

-- 2. List reminders for a task
CREATE INDEX idx_reminders_task_id ON reminders(task_id);
-- Query: WHERE task_id = ?

-- 3. List reminders for a user
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
-- Query: WHERE user_id = ?

-- 4. Composite index for user's pending reminders
CREATE INDEX idx_reminders_user_status_due ON reminders(user_id, status, due_at);
-- Query: WHERE user_id = ? AND status = 'pending' ORDER BY due_at
```

### C. Error Codes Reference

| Status Code | Error Scenario | Example |
|-------------|----------------|---------|
| 400 Bad Request | Invalid due_at (in past) | "Due datetime must be in the future" |
| 400 Bad Request | Reminder limit exceeded | "Task already has maximum of 10 reminders" |
| 400 Bad Request | Invalid recurrence type | "Recurrence must be: none, daily, or weekly" |
| 400 Bad Request | Invalid status transition | "Cannot transition from completed to pending" |
| 401 Unauthorized | Missing/invalid token | "Could not validate credentials" |
| 403 Forbidden | Not task owner | "Not authorized to create reminders for this task" |
| 404 Not Found | Task doesn't exist | "Task not found" |
| 404 Not Found | Reminder doesn't exist | "Reminder not found" |
| 500 Internal Server Error | Database error | "An error occurred processing your request" |

---

**End of Document**