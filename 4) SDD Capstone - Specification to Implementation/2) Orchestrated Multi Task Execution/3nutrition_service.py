from typing import Dict
from sqlalchemy.orm import Session
from src.recipebox.models import Recipe, RecipeIngredient, MealPlan, MealPlanItem


class NutritionService:
    def __init__(self, db: Session):
        self.db = db
    
    def calculate_recipe_nutrition(self, recipe_id: int, servings: int) -> Dict[str, float]:
        """
        Calculate nutrition for a recipe scaled to specified servings.
        
        Returns:
            Dict with calories, protein, carbs, fat per serving
        """
        # Get recipe from database, raise ValueError if not found
        recipe = self.db.query(Recipe).filter(Recipe.id == recipe_id).first()
        if not recipe:
            raise ValueError("Recipe not found")

        # Get all recipe_ingredients for this recipe
        recipe_ingredients = self.db.query(RecipeIngredient).filter(
            RecipeIngredient.recipe_id == recipe_id
        ).all()

        # Initialize totals (calories, protein, carbs, fat) to 0.0
        total_calories = 0.0
        total_protein = 0.0
        total_carbs = 0.0
        total_fat = 0.0

        # Loop through recipe_ingredients: add (ingredient.*_per_unit * recipe_ing.amount) to totals
        for recipe_ing in recipe_ingredients:
            ingredient = recipe_ing.ingredient
            amount = float(recipe_ing.amount)

            # Use hasattr for optional nutrition fields
            if hasattr(ingredient, 'calories_per_unit') and ingredient.calories_per_unit:
                total_calories += ingredient.calories_per_unit * amount
            if hasattr(ingredient, 'protein_per_unit') and ingredient.protein_per_unit:
                total_protein += ingredient.protein_per_unit * amount
            if hasattr(ingredient, 'carbs_per_unit') and ingredient.carbs_per_unit:
                total_carbs += ingredient.carbs_per_unit * amount
            if hasattr(ingredient, 'fat_per_unit') and ingredient.fat_per_unit:
                total_fat += ingredient.fat_per_unit * amount

        # Scale to requested servings: servings_factor = servings / recipe.servings
        servings_factor = servings / recipe.servings

        # Return dict with totals * servings_factor, rounded to 2 decimals (and 'servings': servings)
        return {
            'calories': round(total_calories * servings_factor, 2),
            'protein': round(total_protein * servings_factor, 2),
            'carbs': round(total_carbs * servings_factor, 2),
            'fat': round(total_fat * servings_factor, 2),
            'servings': servings
        }
    
    def calculate_meal_plan_nutrition(self, meal_plan_id: int) -> Dict[str, float]:
        """Calculate total nutrition for all meals in a meal plan."""
        # Get meal plan from database, raise ValueError if not found
        meal_plan = self.db.query(MealPlan).filter(MealPlan.id == meal_plan_id).first()
        if not meal_plan:
            raise ValueError("Meal plan not found")

        # Get all meal_items for this meal plan
        meal_items = self.db.query(MealPlanItem).filter(
            MealPlanItem.meal_plan_id == meal_plan_id
        ).all()

        # Initialize totals (calories, protein, carbs, fat) to 0.0
        total_calories = 0.0
        total_protein = 0.0
        total_carbs = 0.0
        total_fat = 0.0

        # Loop through meal_items:
        # - Call calculate_recipe_nutrition for each item's recipe and servings
        # - Add nutrition values to totals
        for meal_item in meal_items:
            recipe_nutrition = self.calculate_recipe_nutrition(
                meal_item.recipe_id,
                meal_item.servings
            )
            total_calories += recipe_nutrition['calories']
            total_protein += recipe_nutrition['protein']
            total_carbs += recipe_nutrition['carbs']
            total_fat += recipe_nutrition['fat']

        # Return dict with totals and meal_count
        return {
            'calories': round(total_calories, 2),
            'protein': round(total_protein, 2),
            'carbs': round(total_carbs, 2),
            'fat': round(total_fat, 2),
            'meal_count': len(meal_items)
        }