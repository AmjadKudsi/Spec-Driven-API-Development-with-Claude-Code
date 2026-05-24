"""Task repository for database operations on tasks."""

import logging
from typing import Any, Dict, Optional
from uuid import UUID

from sqlalchemy.orm import Session

from ..models.task import Task
from ..services.task_event_publisher import TaskEventPublisher


logger = logging.getLogger(__name__)


class TaskRepository:
    """Repository for task database operations.

    This repository handles all database operations for tasks and publishes
    events after successful commits. Events are published for create, update,
    and delete operations to support notifications, logging, and analytics.
    """

    def __init__(
        self,
        db: Session,
        event_publisher: TaskEventPublisher,
    ) -> None:
        """Initialize the TaskRepository.

        Args:
            db: SQLAlchemy database session.
            event_publisher: Service for publishing task events.
        """
        self.db = db
        self.event_publisher = event_publisher

    def create_task(
        self,
        title: str,
        owner_id: UUID,
        description: Optional[str] = None,
        status: str = "pending",
    ) -> Task:
        """Create a new task.

        Creates a task in the database and publishes a task.created event
        after successful commit.

        Args:
            title: Task title (1-200 characters).
            owner_id: UUID of the user who owns the task.
            description: Optional task description.
            status: Initial status of the task (default: "pending").

        Returns:
            Created Task object.

        Raises:
            ValueError: If title is invalid or exceeds 200 characters.
            Exception: If database operation fails.
        """
        if not title or len(title) > 200:
            raise ValueError("Title must be between 1 and 200 characters")

        task = Task(
            title=title,
            owner_id=owner_id,
            description=description,
            status=status,
        )

        self.db.add(task)
        self.db.commit()
        self.db.refresh(task)

        # Publish event after successful commit
        try:
            self.event_publisher.publish_task_created(
                task_id=task.id,
                user_id=task.owner_id,
                changes={
                    "title": task.title,
                    "description": task.description,
                    "status": task.status,
                },
            )
        except Exception as exc:
            logger.exception(
                "Failed to publish task.created event",
                exc_info=exc,
                extra={"task_id": str(task.id)},
            )

        return task

    def update_task(
        self,
        task_id: UUID,
        user_id: UUID,
        updates: Dict[str, Any],
    ) -> Task:
        """Update an existing task.

        Updates a task in the database and publishes a task.updated event
        after successful commit with the changed fields.

        Args:
            task_id: UUID of the task to update.
            user_id: UUID of the user performing the update.
            updates: Dictionary of fields to update with new values.

        Returns:
            Updated Task object.

        Raises:
            ValueError: If task not found or updates are invalid.
            Exception: If database operation fails.
        """
        task = self.db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise ValueError(f"Task with id {task_id} not found")

        # Track changes for event
        changes = {}

        for field, new_value in updates.items():
            if hasattr(task, field):
                old_value = getattr(task, field)
                if old_value != new_value:
                    changes[field] = {
                        "old": old_value,
                        "new": new_value,
                    }
                    setattr(task, field, new_value)

        # Only commit if there are actual changes
        if changes:
            self.db.commit()
            self.db.refresh(task)

            # Publish event after successful commit
            try:
                self.event_publisher.publish_task_updated(
                    task_id=task.id,
                    user_id=user_id,
                    changes=changes,
                )
            except Exception as exc:
                logger.exception(
                    "Failed to publish task.updated event",
                    exc_info=exc,
                    extra={"task_id": str(task.id)},
                )

        return task

    def delete_task(
        self,
        task_id: UUID,
        user_id: UUID,
    ) -> None:
        """Delete a task.

        Deletes a task from the database and publishes a task.deleted event
        after successful commit.

        Args:
            task_id: UUID of the task to delete.
            user_id: UUID of the user performing the deletion.

        Raises:
            ValueError: If task not found.
            Exception: If database operation fails.
        """
        task = self.db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise ValueError(f"Task with id {task_id} not found")

        # Capture task details before deletion
        task_data = {
            "title": task.title,
            "status": task.status,
            "owner_id": str(task.owner_id),
        }

        self.db.delete(task)
        self.db.commit()

        # Publish event after successful commit
        try:
            self.event_publisher.publish_task_deleted(
                task_id=task_id,
                user_id=user_id,
                changes={
                    "deleted": True,
                    "task_data": task_data,
                },
            )
        except Exception as exc:
            logger.exception(
                "Failed to publish task.deleted event",
                exc_info=exc,
                extra={"task_id": str(task_id)},
            )

    def get_task_by_id(self, task_id: UUID) -> Optional[Task]:
        """Retrieve a task by its ID.

        Args:
            task_id: UUID of the task to retrieve.

        Returns:
            Task object if found, None otherwise.
        """
        return self.db.query(Task).filter(Task.id == task_id).first()
