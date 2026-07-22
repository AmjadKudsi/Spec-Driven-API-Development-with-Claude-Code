from decimal import Decimal
from src.recipebox.models.recipe import Recipe
from src.recipebox.models.recipe_ingredient import RecipeIngredient
from src.recipebox.models.ingredient import Ingredient


def test_recipe_fields(db_session):
    """Test Recipe model has correct fields."""
    recipe = Recipe(
        name="Test Recipe",
        description="Test description",
        prep_time=10,
        cook_time=20,
        servings=4,
        created_by="test_user"
    )
    db_session.add(recipe)
    db_session.commit()

    assert recipe.id is not None
    assert recipe.name == "Test Recipe"
    assert recipe.description == "Test description"
    assert recipe.prep_time == 10
    assert recipe.cook_time == 20
    assert recipe.servings == 4
    assert recipe.created_by == "test_user"
    assert recipe.created_at is not None
    assert recipe.updated_at is not None


def test_recipe_ingredients_relationship(db_session):
    """Test Recipe has relationship with RecipeIngredients."""
    recipe = Recipe(name="Pasta", servings=2, created_by="test_user")
    ingredient = Ingredient(name="Flour", category="Baking")
    db_session.add(recipe)
    db_session.add(ingredient)
    db_session.commit()

    recipe_ingredient = RecipeIngredient(
        recipe_id=recipe.id,
        ingredient_id=ingredient.id,
        amount=Decimal("2.50"),
        unit="cups"
    )
    db_session.add(recipe_ingredient)
    db_session.commit()

    db_session.refresh(recipe)
    assert len(recipe.recipe_ingredients) == 1
    assert recipe.recipe_ingredients[0].amount == Decimal("2.50")
    assert recipe.recipe_ingredients[0].unit == "cups"


def test_recipe_cascade_delete(db_session):
    """Test deleting Recipe cascades to RecipeIngredients."""
    recipe = Recipe(name="Cake", servings=8, created_by="test_user")
    ingredient = Ingredient(name="Sugar", category="Baking")
    db_session.add(recipe)
    db_session.add(ingredient)
    db_session.commit()

    recipe_ingredient = RecipeIngredient(
        recipe_id=recipe.id,
        ingredient_id=ingredient.id,
        amount=Decimal("1.00"),
        unit="cup"
    )
    db_session.add(recipe_ingredient)
    db_session.commit()

    db_session.delete(recipe)
    db_session.commit()

    remaining = db_session.query(RecipeIngredient).count()
    assert remaining == 0


def test_recipe_str_repr():
    """Test Recipe string representation."""
    recipe = Recipe(name="Test Recipe", servings=4, created_by="test_user")
    repr_string = repr(recipe)

    assert "Test Recipe" in repr_string
    assert "4" in repr_string