# Project Constitution: TaskMaster API

**Version:** TaskMaster API v1.1  
**Purpose:** Define project-specific rules that Claude Code must follow when generating or modifying TaskMaster code.

---

## Tech Stack

- Python 3.11+
- FastAPI
- PostgreSQL
- SQLAlchemy ORM
- pytest
- Black formatter

---

## Architectural Principles

### Repository Pattern

- All database access must go through repository classes.
- API route handlers must not contain direct SQLAlchemy queries.
- Repository classes belong in `src/repositories/`.
- Repository classes should be named using PascalCase, such as `TaskRepository`.
- Repository methods should use snake_case, such as `get_by_id`.

### Dependency Injection

- Database sessions must be provided through dependency injection.
- Route handlers should receive repositories or database sessions through FastAPI dependencies.
- Do not create database sessions manually inside route functions.

### API-first Design

- Define request parameters, response shape, and error behavior before implementation.
- Keep API route logic thin.
- Put database operations in repositories.
- Put validation and formatting logic in clearly named helper functions when needed.

---

## Code Standards

- All Python functions and methods must include type hints.
- Public classes and methods must include Google-style docstrings.
- Use Black-compatible formatting.
- Use snake_case for functions, methods, and variables.
- Use PascalCase for classes.
- Return `None` when a single requested record is not found unless the API layer needs to raise an HTTP error.
- Use clear error handling for invalid input or missing records.
- Avoid duplicating existing code. Extend existing modules when possible.

---

## Pagination Standard

All paginated API endpoints must use the same pagination contract.

### Query Parameters

- Use `page` and `per_page` query parameters.
- Do not use `skip` and `limit` for public API pagination.
- Pagination is 1-indexed.
- Default `page` is `1`.
- Default `per_page` is `20`.
- Minimum `page` is `1`.
- Minimum `per_page` is `1`.
- Maximum `per_page` is `100`.

### FastAPI Parameter Pattern

Use this pattern for paginated endpoints:

```python
page: int = Query(1, ge=1)
per_page: int = Query(20, ge=1, le=100)
```

### Offset Calculation

Repositories may convert page-based pagination to offset internally:

```python
offset = (page - 1) * per_page
```

### Response Shape

Paginated responses must include:

- `items`
- `page`
- `per_page`
- `total`
- `total_pages`

### Example Request

```http
GET /api/tasks/search?q=meeting&page=1&per_page=20
```

### Example Response

```json
{
  "items": [],
  "page": 1,
  "per_page": 20,
  "total": 0,
  "total_pages": 0
}
```

### Pagination Rules for New Endpoints

When creating a new endpoint that returns multiple records:

- Use `page` and `per_page`.
- Return the standard response shape.
- Include total record count.
- Calculate `total_pages` using ceiling division.
- Do not mix `page/per_page` with `skip/limit` in the public API.
- Keep pagination behavior documented in the route or response schema.

---

## SDD Workflow Rules

### 1. Specification

- Define expected behavior before implementation.
- Specify request parameters, response structure, and edge cases.

### 2. Technical Planning

- Identify affected files.
- Identify required repository, model, route, and test changes.

### 3. Task Breakdown

- Break work into small implementation steps.
- Avoid changing unrelated files.

### 4. Implementation

- Follow this constitution.
- Follow existing project patterns.
- Prefer extending existing code over recreating code.

### 5. Validation

- Verify generated code against this constitution.
- Check type hints, docstrings, repository usage, and pagination rules.
- Document any rule violations.
