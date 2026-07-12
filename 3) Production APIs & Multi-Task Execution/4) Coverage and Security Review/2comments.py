from fastapi import APIRouter, Depends, HTTPException
from uuid import UUID
from typing import List
from ..services.comment_service import CommentService, Comment
from ..services.auth import get_current_user
from ..models.user import User

router = APIRouter()


@router.post("/tasks/{task_id}/comments")
def create_comment(
    task_id: int,
    content: str,
    current_user: User = Depends(get_current_user),
    service: CommentService = Depends()
):
    """Create a comment on a task."""
    # Authorization: Check user owns task
    task = get_task(task_id)
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your task")
    
    try:
        comment = service.create_comment(task_id, content, current_user.id)
        return {"id": str(comment.id), "content": comment.content}
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))


@router.get("/tasks/{task_id}/comments")
def list_comments(
    task_id: int,
    current_user: User = Depends(get_current_user),
    service: CommentService = Depends()
) -> List[dict]:
    """List all comments on a task."""
    # Authorization: Check user owns task
    task = get_task(task_id)
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your task")
    
    comments = service.get_comments_by_task(task_id)
    return [{"id": str(c.id), "content": c.content} for c in comments]


@router.delete("/comments/{comment_id}")
def delete_comment(
    comment_id: UUID,
    current_user: User = Depends(get_current_user),
    service: CommentService = Depends()
):
    """Delete a comment."""
    # Get comment to verify authorization
    comment = service.get_comment(comment_id)
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")

    # Get task to check task ownership
    task = get_task(comment.task_id)

    # Authorization: User must own comment OR own task
    if comment.user_id != current_user.id and task.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this comment")

    try:
        service.delete_comment(comment_id, current_user.id)
        return {"status": "deleted"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


def get_task(task_id: int):
    """Helper to get task (simplified for this example)."""
    # In real code, this would query the database
    class Task:
        def __init__(self):
            self.id = task_id
            self.owner_id = 1  # Simplified
    return Task()