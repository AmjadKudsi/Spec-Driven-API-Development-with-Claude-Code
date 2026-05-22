"""Tag repository for database operations."""

from typing import Optional, List
from uuid import UUID
from sqlalchemy.orm import Session
from ..models.tag import Tag


class TagRepository:
    """Repository for Tag database operations.

    This class handles all database interactions for Tag entities,
    following the repository pattern and dependency injection principles.
    """

    def __init__(self, db: Session) -> None:
        """Initialize the TagRepository.

        Args:
            db: SQLAlchemy database session.
        """
        self.db = db

    def create(self, name: str, description: Optional[str] = None) -> Tag:
        """Create a new tag.

        Args:
            name: The name of the tag (must be unique).
            description: Optional description of the tag.

        Returns:
            The created Tag instance.

        Raises:
            IntegrityError: If a tag with the same name already exists.
        """
        tag = Tag(name=name, description=description)
        self.db.add(tag)
        self.db.commit()
        self.db.refresh(tag)
        return tag

    def get_by_id(self, tag_id: UUID) -> Optional[Tag]:
        """Retrieve a tag by its ID.

        Args:
            tag_id: The UUID of the tag to retrieve.

        Returns:
            The Tag instance if found, None otherwise.
        """
        return self.db.query(Tag).filter(Tag.id == tag_id).first()

    def list(
        self, skip: int = 0, limit: int = 100, name_filter: Optional[str] = None
    ) -> List[Tag]:
        """List tags with optional filtering and pagination.

        Args:
            skip: Number of records to skip (for pagination).
            limit: Maximum number of records to return.
            name_filter: Optional filter to search tags by name (case-insensitive).

        Returns:
            List of Tag instances.
        """
        query = self.db.query(Tag)

        if name_filter:
            query = query.filter(Tag.name.ilike(f"%{name_filter}%"))

        return query.offset(skip).limit(limit).all()

    def update(
        self,
        tag_id: UUID,
        name: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Optional[Tag]:
        """Update a tag's attributes.

        Args:
            tag_id: The UUID of the tag to update.
            name: Optional new name for the tag.
            description: Optional new description for the tag.

        Returns:
            The updated Tag instance if found, None otherwise.

        Raises:
            IntegrityError: If the new name conflicts with an existing tag.
        """
        tag = self.get_by_id(tag_id)

        if tag is None:
            return None

        if name is not None:
            tag.name = name

        if description is not None:
            tag.description = description

        self.db.commit()
        self.db.refresh(tag)
        return tag

    def delete(self, tag_id: UUID) -> bool:
        """Delete a tag by its ID.

        Args:
            tag_id: The UUID of the tag to delete.

        Returns:
            True if the tag was deleted, False if not found.
        """
        tag = self.get_by_id(tag_id)

        if tag is None:
            return False

        self.db.delete(tag)
        self.db.commit()
        return True
