from sqlalchemy import Column, String, Integer, Text
from sqlalchemy.orm import relationship
from src.recipebox.database import Base


class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True)
    category = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)

    recipe_ingredients = relationship(
        "RecipeIngredient",
        back_populates="ingredient"
    )

    def __repr__(self):
        return f"<Ingredient(id={self.id}, name={self.name}, category={self.category})>"