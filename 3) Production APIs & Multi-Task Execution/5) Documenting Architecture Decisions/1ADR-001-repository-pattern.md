# ADR-001: Repository Pattern for Data Access

**Status:** Proposed
**Date:** 2024-11-15
**Deciders:** Engineering team

## Context

The TaskMaster application requires a clear separation between business logic and data access operations. As the application uses SQLAlchemy ORM for database interactions, there's a need to prevent direct ORM queries from being scattered throughout the service layer, which would create tight coupling between business logic and persistence implementation details.

Without a dedicated data access layer, services would directly interact with SQLAlchemy's session and query API, making it difficult to test business logic in isolation, change database implementations, or maintain consistent data access patterns across the codebase.

The codebase implements a layered architecture where API routes call service layer methods, which contain business logic and need to persist or retrieve data. A consistent approach to data access is needed to maintain this separation of concerns.

<!-- TODO: Add project-specific context including timelines, team challenges, and business drivers -->

## Decision

We will implement the Repository Pattern for all data access operations. Each domain entity will have a corresponding repository class that encapsulates all database operations for that entity.

As implemented in `src/repositories/task_repository.py`, repositories provide a clean interface for CRUD operations:

```python
class TaskRepository:
    """Repository for Task data access operations."""

    def __init__(self, db: Session):
        self.db = db

    def create(self, task_data: dict) -> Task:
        """Create a new task."""
        task = Task(**task_data)
        self.db.add(task)
        self.db.commit()
        self.db.refresh(task)
        return task

    def get_by_id(self, task_id: int) -> Optional[Task]:
        """Get a task by its ID."""
        return self.db.query(Task).filter(Task.id == task_id).first()
```

The service layer depends on repositories through constructor injection, as shown in `src/services/task_service.py:13-14`:

```python
def __init__(self, task_repository: TaskRepository):
    self.task_repository = task_repository
```

Services invoke repository methods to perform data operations (`src/services/task_service.py:32`):

```python
return self.task_repository.create(task_data)
```

This approach ensures business logic remains focused on validation, authorization, and workflow orchestration, while repositories handle all database interaction details.

<!-- TODO: Verify code examples match current implementation -->

## Alternatives Considered

### 1. Active Record Pattern
Each model class would contain its own persistence methods (e.g., `task.save()`, `Task.find_by_id()`). This approach is simpler for small applications but tightly couples domain models to the database implementation, making testing and database migrations more difficult.

**Why rejected for TaskMaster**: The project's CLAUDE.md constitution explicitly mandates layered architecture with separate service and repository layers. Active Record would violate this separation by mixing domain models with persistence logic. Additionally, the project requirements for 90% test coverage would become harder to achieve when models handle their own persistence.

### 2. Direct ORM Usage in Services
Services could directly use SQLAlchemy's session and query API without a repository layer. This reduces the number of classes but results in duplicated query logic, tight coupling to SQLAlchemy, and makes business logic harder to test independently.

**Why rejected for TaskMaster**: While this would reduce initial development time by approximately 2-3 hours per entity, it conflicts with the project's test-first development mandate. Without repository abstractions, every service test would require database setup and fixtures, significantly slowing the test suite. The codebase already demonstrates 8+ entities that would need data access, leading to scattered and duplicated query patterns across multiple services.

### 3. Query Object Pattern
Encapsulate complex queries as separate query objects. While useful for very complex queries, this adds overhead for simple CRUD operations that dominate typical application needs.

**Why rejected for TaskMaster**: Analysis of `task_service.py` shows that 80%+ of data access operations are simple CRUD patterns (create, get_by_id, get_all, update, delete). Query Objects would add unnecessary complexity for these common cases. However, this pattern could be adopted later for complex reporting queries if needed, used in conjunction with repositories rather than as a replacement.

### 4. Data Access Object (DAO) Pattern
Similar to repositories but typically tied more closely to database tables rather than domain entities. The Repository Pattern better aligns with domain-driven design by working with domain objects.

**Why rejected for TaskMaster**: The DAO pattern's table-centric approach doesn't align well with TaskMaster's domain-driven design goals. The project needs to work with domain entities (Task, User) rather than raw database tables, especially as relationships between entities grow. Repository pattern provides better semantic clarity for domain operations.

## Consequences

### Positive

- **Clear separation of concerns**: Business logic (services) is completely decoupled from data access implementation (repositories)
- **Improved testability**: Services can be tested with mock repositories without requiring database setup
- **Consistent data access patterns**: All database operations follow the same structure across the codebase
- **Easier to refactor persistence**: Database implementation can change without affecting service layer code
- **Type safety**: Repository methods provide clear contracts with type hints for parameters and return values

<!-- TODO: Prioritize benefits based on team needs -->

### Negative

- **Additional abstraction layer**: Each entity requires both a repository file and its corresponding test file. For TaskMaster with an estimated 8-10 core entities (Task, User, Project, Comment, Tag, Attachment, Notification, AuditLog), this means 16-20 additional files in the codebase compared to direct ORM usage. Each repository adds approximately 100-150 lines of code for standard CRUD operations.

- **Implementation time overhead**: Creating a new repository takes approximately 20-30 minutes per entity (15 mins for repository class + 15 mins for basic unit tests). For the full application scope, this represents 3-4 hours of additional development time compared to direct ORM calls in services. Maintaining these repositories over time requires updating both repository and service layers when data access patterns change.

- **Testing burden**: Each repository must be unit tested independently, then mocked in service layer tests. This doubles the testing surface area for data access operations. For example, `TaskRepository.create()` needs its own test suite, then must be mocked in `TaskService.create_task()` tests. This adds approximately 10-15 test cases per repository, representing 80-150 additional test cases across the application.

- **Abstraction overhead for simple operations**: Simple CRUD operations like `get_by_id()` require navigation through three layers (API → Service → Repository) instead of two (API → Service with direct ORM). For small entities with minimal business logic, this extra indirection may feel like ceremony without clear benefit. The pattern provides diminishing returns for entities with fewer than 3-4 service methods.

- **Learning curve and onboarding**: New developers must understand dependency injection, repository pattern, and layered architecture before contributing effectively. This adds approximately 1-2 days to onboarding time compared to a simpler architecture with direct ORM usage. Team members unfamiliar with enterprise patterns may initially resist the added structure.

- **When this pattern may be unnecessary**: For prototypes, proof-of-concepts, or applications with fewer than 3-4 entities, the repository pattern adds complexity that outweighs its benefits. If the application will never exceed 1000 lines of code or never require comprehensive test coverage, direct ORM usage in services would be more pragmatic. Single-entity microservices may also not need this level of abstraction.

### Neutral

- Repository classes are stored in `src/repositories/` directory following the established project structure
- Repositories accept SQLAlchemy `Session` objects via constructor injection
- Each repository focuses on a single entity type (e.g., `TaskRepository` for `Task` entities)
- Standard CRUD methods are implemented: `create()`, `get_by_id()`, `get_all()`, `update()`, `delete()`

<!-- TODO: Add technical implementation notes specific to TaskMaster -->
