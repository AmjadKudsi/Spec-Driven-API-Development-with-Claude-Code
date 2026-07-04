# Feature Specification: Task Tags

## Description
Allow users to add labels or categories to tasks for better organization. Users can create tags and assign multiple tags to any task.

## Database Requirements

### Tags Table
- `id` (Integer, Primary Key)
- `name` (String, Unique)

### Task_Tags Junction Table
- `task_id` (Integer, Foreign Key to tasks)
- `tag_id` (Integer, Foreign Key to tags)

## File Locations

- **Model**: `src/models/tag.py`
- **Repository**: `src/repositories/tag_repository.py`
- **Service**: `src/services/tag_service.py`
- **Endpoints**: `src/api/endpoints/tags.py`

## API Endpoints

### Add Tag to Task
- **Method**: POST
- **Path**: `/api/tasks/{task_id}/tags`
- **Body**: `{"name": "tag_name"}`
- **Response**: `{"id": 1, "name": "tag_name"}`

### Get Task Tags
- **Method**: GET
- **Path**: `/api/tasks/{task_id}/tags`
- **Response**: `[{"id": 1, "name": "urgent"}, {"id": 2, "name": "work"}]`

### Remove Tag from Task
- **Method**: DELETE
- **Path**: `/api/tasks/{task_id}/tags/{tag_id}`
- **Response**: `{"message": "Tag removed successfully"}`

## Business Rules
- Tag names must be unique across the system
- A task can have multiple tags
- The same tag can be applied to multiple tasks
- Deleting a tag removes it from all tasks