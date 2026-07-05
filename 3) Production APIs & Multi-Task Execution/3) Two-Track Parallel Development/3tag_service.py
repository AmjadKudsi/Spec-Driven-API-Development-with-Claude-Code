"""Tag service for business logic"""

from uuid import UUID
from sqlalchemy.exc import IntegrityError
from ..repositories.tag_repository import TagRepository
from ..models.tag import Tag


class TagService:
    def __init__(self, tag_repository: TagRepository):
        self.tag_repository = tag_repository

    def create_or_get_tag(self, name: str) -> Tag:
        """Create tag if it doesn't exist, otherwise return existing tag"""
        # Strip whitespace and convert to lowercase for uniqueness
        normalized_name = name.strip().lower()

        if not normalized_name:
            raise ValueError("Tag name cannot be empty")

        # Check if tag already exists
        existing_tag = self.tag_repository.get_tag_by_name(normalized_name)
        if existing_tag:
            return existing_tag

        # Create new tag
        try:
            return self.tag_repository.create_tag(normalized_name)
        except IntegrityError:
            # Handle race condition where tag was created between check and insert
            return self.tag_repository.get_tag_by_name(normalized_name)

    def assign_tag_to_task(self, task_id: UUID, tag_name: str) -> Tag:
        """Add tag to task (create tag if needed)"""
        # Get or create the tag
        tag = self.create_or_get_tag(tag_name)

        # Add the tag to the task
        try:
            self.tag_repository.add_tag_to_task(task_id, tag.id)
        except IntegrityError:
            # Tag already assigned to task, ignore
            pass

        return tag

    def remove_tag_from_task(self, task_id: UUID, tag_id: UUID) -> None:
        """Remove tag from task"""
        self.tag_repository.remove_tag_from_task(task_id, tag_id)

    def get_tags_for_task(self, task_id: UUID) -> list[Tag]:
        """Get all tags for a task"""
        return self.tag_repository.get_task_tags(task_id)
