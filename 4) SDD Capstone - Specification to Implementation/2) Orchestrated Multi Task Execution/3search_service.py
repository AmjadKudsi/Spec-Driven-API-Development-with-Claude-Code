from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_
from src.recipebox.models import Recipe


class SearchService:
    def __init__(self, db: Session):
        self.db = db
    
    def search_recipes(
        self,
        query: str,
        user_id: int,
        max_prep_time: Optional[int] = None,
        max_cook_time: Optional[int] = None,
        min_servings: Optional[int] = None,
        max_servings: Optional[int] = None
    ) -> List[Recipe]:
        """
        Search recipes by name and description with optional filters.
        
        Args:
            query: Search query string
            user_id: User ID (recipes must belong to this user)
            max_prep_time: Maximum prep time in minutes
            max_cook_time: Maximum cook time in minutes
            min_servings: Minimum servings
            max_servings: Maximum servings
        """
        # Start with base query filtering recipes by user_id
        query_builder = self.db.query(Recipe).filter(Recipe.created_by == user_id)

        # If query is provided, add search filter on name and description
        if query:
            search_pattern = f"%{query}%"
            query_builder = query_builder.filter(
                or_(
                    Recipe.name.ilike(search_pattern),
                    Recipe.description.ilike(search_pattern)
                )
            )

        # Apply time filters if provided
        if max_prep_time is not None:
            query_builder = query_builder.filter(Recipe.prep_time <= max_prep_time)

        if max_cook_time is not None:
            query_builder = query_builder.filter(Recipe.cook_time <= max_cook_time)

        # Apply serving filters if provided
        if min_servings is not None:
            query_builder = query_builder.filter(Recipe.servings >= min_servings)

        if max_servings is not None:
            query_builder = query_builder.filter(Recipe.servings <= max_servings)

        # Order results by relevance (name matches first, then by name alphabetically)
        if query:
            # Name matches prioritized over description matches
            name_pattern = f"%{query}%"
            query_builder = query_builder.order_by(
                Recipe.name.ilike(name_pattern).desc(),
                Recipe.name.asc()
            )
        else:
            query_builder = query_builder.order_by(Recipe.name.asc())

        # Return all matching recipes
        return query_builder.all()