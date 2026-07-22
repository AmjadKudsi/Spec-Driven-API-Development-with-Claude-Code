from datetime import date
from src.recipebox.models.meal_plan import MealPlan


def test_meal_plan_fields(db_session):
    """Test MealPlan model has correct fields."""
    meal_plan = MealPlan(
        user_id="user123",
        week_start_date=date(2026, 7, 21)
    )
    db_session.add(meal_plan)
    db_session.commit()

    assert meal_plan.id is not None
    assert meal_plan.user_id == "user123"
    assert meal_plan.week_start_date == date(2026, 7, 21)
    assert meal_plan.created_at is not None
    assert meal_plan.updated_at is not None


def test_meal_plan_str_repr():
    """Test MealPlan string representation."""
    meal_plan = MealPlan(
        user_id="user456",
        week_start_date=date(2026, 7, 28)
    )
    repr_string = repr(meal_plan)

    assert "user456" in repr_string
    assert "2026-07-28" in repr_string