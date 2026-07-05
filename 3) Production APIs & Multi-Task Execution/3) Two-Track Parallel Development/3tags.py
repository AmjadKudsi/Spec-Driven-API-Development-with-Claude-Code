"""Tag endpoints"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from ...database import get_db
from ...models.user import User
from ...models.task import Task
from ...schemas.tag import TagCreate, TagResponse
from ...services.auth import get_current_user
from ...repositories.tag_repository import TagRepository
from ...services.tag_service import TagService

router = APIRouter(prefix="/api/tasks", tags=["Tags"])


@router.post("/{task_id}/tags", response_model=TagResponse, status_code=status.HTTP_201_CREATED)
def add_tag_to_task(
    task_id: UUID,
    tag_data: TagCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add a tag to a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    tag_repository = TagRepository(db)
    tag_service = TagService(tag_repository)

    # Assign tag to task
    try:
        tag = tag_service.assign_tag_to_task(task_id, tag_data.name)
        return tag
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/{task_id}/tags", response_model=list[TagResponse])
def get_task_tags(
    task_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all tags for a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    tag_repository = TagRepository(db)
    tag_service = TagService(tag_repository)

    # Get tags for task
    tags = tag_service.get_tags_for_task(task_id)
    return tags


@router.delete("/{task_id}/tags/{tag_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_tag_from_task(
    task_id: UUID,
    tag_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a tag from a task"""
    # Verify task exists and belongs to current user
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    # Create repository and service instances
    tag_repository = TagRepository(db)
    tag_service = TagService(tag_repository)

    # Remove tag from task
    tag_service.remove_tag_from_task(task_id, tag_id)
    return None
