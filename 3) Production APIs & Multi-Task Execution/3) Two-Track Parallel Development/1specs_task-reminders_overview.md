# Feature Specification: Task Reminders

## Description
Allow users to set due date reminders for tasks. Each reminder includes a due date and an optional description to help users remember what needs to be done.

## Database Requirements

### Reminders Table
- `id` (Integer, Primary Key)
- `task_id` (Integer, Foreign Key to tasks)
- `due_date` (DateTime)
- `description` (String)

## File Locations

- **Model**: `src/models/reminder.py`
- **Repository**: `src/repositories/reminder_repository.py`
- **Service**: `src/services/reminder_service.py`
- **Endpoints**: `src/api/endpoints/reminders.py`

## API Endpoints

### Add Reminder to Task
- **Method**: POST
- **Path**: `/api/tasks/{task_id}/reminders`
- **Body**: `{"due_date": "2024-12-31T10:00:00", "description": "Finish report"}`
- **Response**: `{"id": 1, "task_id": 101, "due_date": "2024-12-31T10:00:00", "description": "Finish report"}`

### Get Task Reminders
- **Method**: GET
- **Path**: `/api/tasks/{task_id}/reminders`
- **Response**: `[{"id": 1, "due_date": "2024-12-31T10:00:00", "description": "Finish report"}]`

### Delete Reminder
- **Method**: DELETE
- **Path**: `/api/tasks/{task_id}/reminders/{reminder_id}`
- **Response**: `{"message": "Reminder deleted successfully"}`

## Business Rules
- A task can have multiple reminders
- Due dates must be in the future
- Description is optional but recommended
- Reminders are automatically removed when a task is deleted