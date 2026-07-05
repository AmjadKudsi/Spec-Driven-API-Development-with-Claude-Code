"""Reminder repository for data access operations"""

from datetime import datetime
from uuid import UUID
from sqlalchemy.orm import Session
from ..models.reminder import Reminder


class ReminderRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_reminder(self, task_id: UUID, due_date: datetime, description: str) -> Reminder:
        """Create a new reminder"""
        reminder = Reminder(
            task_id=task_id,
            due_date=due_date,
            description=description
        )
        self.db.add(reminder)
        self.db.commit()
        self.db.refresh(reminder)
        return reminder

    def get_reminder_by_id(self, reminder_id: UUID) -> Reminder | None:
        """Find a reminder by its ID"""
        return self.db.query(Reminder).filter(Reminder.id == reminder_id).first()

    def get_task_reminders(self, task_id: UUID) -> list[Reminder]:
        """Get all reminders for a task"""
        return self.db.query(Reminder).filter(Reminder.task_id == task_id).order_by(Reminder.due_date).all()

    def delete_reminder(self, reminder_id: UUID) -> None:
        """Delete a reminder"""
        reminder = self.db.query(Reminder).filter(Reminder.id == reminder_id).first()
        if reminder:
            self.db.delete(reminder)
            self.db.commit()
