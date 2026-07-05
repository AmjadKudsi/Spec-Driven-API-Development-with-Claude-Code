"""Reminder service for business logic"""

from datetime import datetime, timezone
from uuid import UUID
from ..repositories.reminder_repository import ReminderRepository
from ..models.reminder import Reminder


class ReminderService:
    def __init__(self, reminder_repository: ReminderRepository):
        self.reminder_repository = reminder_repository

    def create_reminder(self, task_id: UUID, due_date: datetime, description: str) -> Reminder:
        """Create reminder with validation that due_date is in the future"""
        # Get current time in UTC with timezone awareness
        now = datetime.now(timezone.utc)

        # Ensure due_date is timezone-aware for comparison
        if due_date.tzinfo is None:
            # If naive datetime, assume UTC
            due_date = due_date.replace(tzinfo=timezone.utc)

        # Validate due_date is in the future
        if due_date <= now:
            raise ValueError("Due date must be in the future")

        # Create the reminder
        return self.reminder_repository.create_reminder(task_id, due_date, description)

    def get_task_reminders(self, task_id: UUID) -> list[Reminder]:
        """Get all reminders for a task"""
        return self.reminder_repository.get_task_reminders(task_id)

    def delete_reminder(self, reminder_id: UUID) -> None:
        """Delete a reminder"""
        self.reminder_repository.delete_reminder(reminder_id)
