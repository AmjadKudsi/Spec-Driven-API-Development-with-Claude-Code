# TaskMaster API

A production-ready task management API built with FastAPI.

## Features

- **Task Management**: Create, read, update, and delete tasks with full CRUD operations

## Setup Instructions

### Prerequisites
- Python 3.9+
- PostgreSQL 15+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourorg/taskmaster-api.git
cd taskmaster-api
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run migrations:
```bash
alembic upgrade head
```

4. Start the server:
```bash
uvicorn src.main:app --reload
```

5. Access API documentation:
- OpenAPI: http://localhost:8000/docs

## API Usage Examples

### Register a New User

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "johndoe",
    "password": "SecurePass123"
  }'
```

### Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123"
  }'
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer"
}
```

### Create a Task

```bash
curl -X POST http://localhost:8000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Complete project documentation",
    "description": "Write comprehensive API documentation"
  }'
```

### List Tasks

```bash
curl -X GET http://localhost:8000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update Task Status

```bash
curl -X PUT http://localhost:8000/api/tasks/{task_id} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "status": "in_progress"
  }'
```

### Delete a Task

```bash
curl -X DELETE http://localhost:8000/api/tasks/{task_id} \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Testing

Run the test suite:
```bash
pytest tests/ -v
```

Run with coverage:
```bash
pytest --cov=src tests/
```

## License

MIT License