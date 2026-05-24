# Project Constitution: TaskMaster API

## Tech Stack

**Framework:** FastAPI 0.104+  
**Language:** Python 3.11+  
**Database:** PostgreSQL 15+  
**ORM:** SQLAlchemy 2.0+  
**Testing:** pytest, pytest-asyncio

---

## Architectural Principles

### Repository Pattern

Business logic separated from data access:

- Controllers handle HTTP.
- Services handle business logic and integrations.
- Repositories handle database operations.
- API routes must not contain direct database query logic.
- Repositories may call services only after database state has been committed when the service depends on committed data.

### Dependency Injection

All services should be injected through constructors or FastAPI's `Depends()`.

```python
def __init__(self, db: Session = Depends(get_db)):
    self.db = db
```

When a repository needs an integration service, inject it instead of creating hidden global dependencies.

```python
def __init__(
    self,
    db: Session,
    event_publisher: TaskEventPublisher,
) -> None:
    self.db = db
    self.event_publisher = event_publisher
```

---

## Code Standards

### Type Hints Required

All functions and methods must have type hints.

```python
def create_task(self, title: str, owner_id: UUID) -> Task:
    ...
```

### Docstrings Required

Google-style docstrings are required for all public classes and public methods.

```python
def create_task(self, title: str, owner_id: UUID) -> Task:
    """Create a new task.

    Args:
        title: Task title.
        owner_id: UUID of task owner.

    Returns:
        Created Task object.
    """
```

### Naming Conventions

- Classes: `PascalCase`
- Functions and methods: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Private methods: `_leading_underscore`

---

## Database Conventions

### Table Names

Use lowercase plural table names:

- `tasks`
- `users`
- `comments`

### Column Names

Use lowercase snake_case column names:

- `created_at`
- `owner_id`
- `is_active`

### Primary Keys

Primary keys must be named `id` and use UUID type.

```python
id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
```

### Timestamps

All models should include timestamps.

```python
created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
updated_at: Mapped[datetime] = mapped_column(default=datetime.utcnow, onupdate=datetime.utcnow)
```

---

## Event Publishing

Task changes must publish events so other systems can react to task activity.

Events are used for:

- Notifications
- Activity logging
- Analytics
- Webhook triggers

### Event Publisher Service

Use a `TaskEventPublisher` service for task events.

The service must live in:

```text
src/services/task_event_publisher.py
```

The service class must be named:

```python
TaskEventPublisher
```

### Required Event Types

Task events must use these exact event names:

- `task.created`
- `task.updated`
- `task.deleted`

Do not invent alternate names such as `task_create`, `task.updated_event`, or `task.removed`.

### Required Event Payload Fields

Every task event must include:

- `event_type`
- `task_id`
- `user_id`
- `timestamp`
- `changes`

Example payload:

```python
{
    "event_type": "task.updated",
    "task_id": str(task_id),
    "user_id": str(user_id),
    "timestamp": datetime.utcnow().isoformat(),
    "changes": {
        "title": {
            "old": "Old title",
            "new": "New title",
        }
    },
}
```

### Transactional Integrity Rule

Publish task events only after the database commit succeeds.

Correct order:

```python
self.db.add(task)
self.db.commit()
self.db.refresh(task)

self.event_publisher.publish_task_created(
    task_id=task.id,
    user_id=task.owner_id,
    changes={"created": True},
)
```

Incorrect order:

```python
self.event_publisher.publish_task_created(...)
self.db.commit()
```

### Repository Integration Rules

When task repositories create, update, or delete tasks:

- Publish `task.created` after successful create commit.
- Publish `task.updated` after successful update commit.
- Publish `task.deleted` after successful delete commit.
- Include the task ID and user ID in every event.
- Include changed fields in the `changes` object.
- Do not publish events if the database operation fails.
- Do not publish events before `commit()`.

### Error Handling

Event publishing failures must be handled clearly.

- Database commits must not be rolled back because event publishing failed after commit.
- Event publishing errors should be logged.
- If the project has no real message queue yet, the publisher may use structured logging or an in-memory placeholder, but the interface must remain ready for a real queue later.

Example:

```python
try:
    self.event_publisher.publish_task_updated(
        task_id=task.id,
        user_id=task.owner_id,
        changes=changes,
    )
except Exception as exc:
    logger.exception("Failed to publish task.updated event", exc_info=exc)
```

### Publisher Method Names

Use these method names:

```python
publish_task_created(...)
publish_task_updated(...)
publish_task_deleted(...)
```

Each method must create a payload with the required fields and send it through a shared internal helper.

---

## SDD Workflow

1. **Analyze:** Review existing code and architecture.
2. **Spec:** Define interfaces, validation rules, and error handling.
3. **Generate:** Provide the spec to Claude.
4. **Verify:** Test generated code against the spec.
5. **Refine:** Iterate if needed.
