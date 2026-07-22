from decimal import Decimal
from src.recipebox.models.recipe import Recipe
from src.recipebox.models.ingredient import Ingredient
from src.recipebox.models.recipe_ingredient import RecipeIngredient


def test_recipe_ingredient_fields(db_session):
    """Test RecipeIngredient model has correct fields."""
    recipe = Recipe(name="Soup", servings=4, created_by="test_user")
    ingredient = Ingredient(name="Carrot", category="Vegetables")
    db_session.add(recipe)
    db_session.add(ingredient)
    db_session.commit()

    recipe_ingredient = RecipeIngredient(
        recipe_id=recipe.id,
        ingredient_id=ingredient.id,
        amount=Decimal("3.00"),
        unit="pieces"
    )
    db_session.add(recipe_ingredient)
    db_session.commit()

    assert recipe_ingredient.id is not None
    assert recipe_ingredient.recipe_id == recipe.id
    assert recipe_ingredient.ingredient_id == ingredient.id
    assert recipe_ingredient.amount == Decimal("3.00")
    assert recipe_ingredient.unit == "pieces"


def test_recipe_ingredient_relationships(db_session):
    """Test RecipeIngredient relationships work both ways."""
    recipe = Recipe(name="Salad", servings=2, created_by="test_user")
    ingredient = Ingredient(name="Lettuce", category="Vegetables")
    db_session.add(recipe)
    db_session.add(ingredient)
    db_session.commit()

    recipe_ingredient = RecipeIngredient(
        recipe_id=recipe.id,
        ingredient_id=ingredient.id,
        amount=Decimal("1.50"),
        unit="cups"
    )
    db_session.add(recipe_ingredient)
    db_session.commit()

    db_session.refresh(recipe)
    db_session.refresh(ingredient)

    assert recipe.recipe_ingredients[0].ingredient.name == "Lettuce"
    assert ingredient.recipe_ingredients[0].recipe.name == "Salad"


def test_recipe_ingredient_str_repr():
    """Test RecipeIngredient string representation."""
    recipe_ingredient = RecipeIngredient(
        recipe_id=1,
        ingredient_id=2,
        amount=Decimal("2.50"),
        unit="tablespoons"
    )
    repr_string = repr(recipe_ingredient)

    assert "2.50" in repr_string
    assert "tablespoons" in repr_string