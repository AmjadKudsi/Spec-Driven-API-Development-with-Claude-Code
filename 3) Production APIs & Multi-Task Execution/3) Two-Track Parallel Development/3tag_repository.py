"""Tag repository for data access operations"""

from sqlalchemy.orm import Session
from sqlalchemy import delete
from uuid import UUID
from ..models.tag import Tag, task_tags


class TagRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_tag(self, name: str) -> Tag:
        """Create a new tag with the given name"""
        tag = Tag(name=name)
        self.db.add(tag)
        self.db.commit()
        self.db.refresh(tag)
        return tag

    def get_tag_by_name(self, name: str) -> Tag | None:
        """Find a tag by its name (case-insensitive)"""
        return self.db.query(Tag).filter(Tag.name == name.lower()).first()

    def add_tag_to_task(self, task_id: UUID, tag_id: UUID) -> None:
        """Link a tag to a task"""
        stmt = task_tags.insert().values(task_id=task_id, tag_id=tag_id)
        self.db.execute(stmt)
        self.db.commit()

    def remove_tag_from_task(self, task_id: UUID, tag_id: UUID) -> None:
        """Remove tag from task"""
        stmt = delete(task_tags).where(
            task_tags.c.task_id == task_id,
            task_tags.c.tag_id == tag_id
        )
        self.db.execute(stmt)
        self.db.commit()

    def get_task_tags(self, task_id: UUID) -> list[Tag]:
        """Get all tags for a task"""
        return self.db.query(Tag).join(task_tags).filter(
            task_tags.c.task_id == task_id
        ).all()
