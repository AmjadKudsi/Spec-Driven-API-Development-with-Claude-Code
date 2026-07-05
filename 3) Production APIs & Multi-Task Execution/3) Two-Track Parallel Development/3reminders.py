"""Reminder endpoints"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from ...database import get_db
from ...models.user import User
from ...models.task import Task
from ...schemas.reminder import ReminderCreate, ReminderResponse
from ...services.auth import get_current_user
from ...repositories.reminder_repository import ReminderRepository
from ...services.reminder_service import ReminderService

router = APIRouter(prefix="/api/tasks", tags=["Reminders"])


@router.post("/{task_id}/reminders", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
def create_reminder(
    task_id: UUID,
    reminder_data: ReminderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a reminder for a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    reminder_repository = ReminderRepository(db)
    reminder_service = ReminderService(reminder_repository)

    # Create reminder with validation
    try:
        reminder = reminder_service.create_reminder(
            task_id,
            reminder_data.due_date,
            reminder_data.description
        )
        return reminder
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/{task_id}/reminders", response_model=list[ReminderResponse])
def get_task_reminders(
    task_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all reminders for a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    reminder_repository = ReminderRepository(db)
    reminder_service = ReminderService(reminder_repository)

    # Get reminders for task
    reminders = reminder_service.get_task_reminders(task_id)
    return reminders


@router.delete("/{task_id}/reminders/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_reminder(
    task_id: UUID,
    reminder_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a reminder from a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    reminder_repository = ReminderRepository(db)
    reminder_service = ReminderService(reminder_repository)

    # Delete reminder
    reminder_service.delete_reminder(reminder_id)
    return None
