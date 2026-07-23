from datetime import datetime
from sqlalchemy import Column, String, Integer, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from src.recipebox.database import Base


class MealPlan(Base):
    __tablename__ = "meal_plans"

    # TODO: Add columns for id, user_id (FK), name, week_start_date
    # TODO: Add created_at and updated_at timestamp columns

    # TODO: Add relationship to User (back_populates="meal_plans")
    # TODO: Add relationship to MealPlanItem (back_populates="meal_plan", cascade="all, delete-orphan")
    # TODO: Add relationship to ShoppingList (back_populates="meal_plan", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<MealPlan(id={self.id}, name='{self.name}', week_start={self.week_start_date})>"