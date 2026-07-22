import pytest
from sqlalchemy.exc import IntegrityError
from src.recipebox.models.ingredient import Ingredient


def test_ingredient_fields(db_session):
    """Test Ingredient model has correct fields."""
    ingredient = Ingredient(
        name="Tomato",
        category="Vegetables",
        description="Fresh red tomato"
    )
    db_session.add(ingredient)
    db_session.commit()

    assert ingredient.id is not None
    assert ingredient.name == "Tomato"
    assert ingredient.category == "Vegetables"
    assert ingredient.description == "Fresh red tomato"


def test_ingredient_unique_name(db_session):
    """Test Ingredient name must be unique."""
    ingredient1 = Ingredient(name="Salt", category="Seasoning")
    db_session.add(ingredient1)
    db_session.commit()

    ingredient2 = Ingredient(name="Salt", category="Other")
    db_session.add(ingredient2)

    with pytest.raises(IntegrityError):
        db_session.commit()


def test_ingredient_str_repr():
    """Test Ingredient string representation."""
    ingredient = Ingredient(name="Pepper", category="Spices")
    repr_string = repr(ingredient)

    assert "Pepper" in repr_string
    assert "Spices" in repr_string