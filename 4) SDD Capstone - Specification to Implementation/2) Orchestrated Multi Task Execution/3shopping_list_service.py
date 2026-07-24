from typing import List, Dict
from sqlalchemy.orm import Session
from src.recipebox.models import ShoppingList, ShoppingListItem, MealPlan, MealPlanItem, RecipeIngredient, Ingredient
from src.recipebox.repositories.shopping_list_repository import ShoppingListRepository


class UnitConverter:
    """Handles unit conversions for ingredient aggregation."""
    
    # Conversion factors to base metric units (grams or milliliters)
    CONVERSIONS = {
        # Weight conversions to grams
        'kg': 1000.0,
        'g': 1.0,
        'lb': 453.592,
        'oz': 28.3495,
        
        # Volume conversions to milliliters
        'l': 1000.0,
        'ml': 1.0,
        'cup': 236.588,
        'tbsp': 14.7868,
        'tsp': 4.92892,
        
        # Piece-based (no conversion)
        'piece': 1.0,
        'unit': 1.0,
    }
    
    WEIGHT_UNITS = {'kg', 'g', 'lb', 'oz'}
    VOLUME_UNITS = {'l', 'ml', 'cup', 'tbsp', 'tsp'}
    PIECE_UNITS = {'piece', 'unit'}
    
    @classmethod
    def convert_to_base_unit(cls, amount: float, unit: str) -> tuple[float, str]:
        """Convert amount to base unit (grams for weight, ml for volume)."""
        unit_lower = unit.lower()
        
        if unit_lower in cls.WEIGHT_UNITS:
            base_amount = amount * cls.CONVERSIONS[unit_lower]
            return base_amount, 'g'
        elif unit_lower in cls.VOLUME_UNITS:
            base_amount = amount * cls.CONVERSIONS[unit_lower]
            return base_amount, 'ml'
        elif unit_lower in cls.PIECE_UNITS:
            return amount, unit_lower
        else:
            # Unknown unit, keep as-is
            return amount, unit_lower
    
    @classmethod
    def can_aggregate(cls, unit1: str, unit2: str) -> bool:
        """Check if two units can be aggregated together."""
        unit1_lower = unit1.lower()
        unit2_lower = unit2.lower()
        
        # Same unit type can aggregate
        if (unit1_lower in cls.WEIGHT_UNITS and unit2_lower in cls.WEIGHT_UNITS):
            return True
        if (unit1_lower in cls.VOLUME_UNITS and unit2_lower in cls.VOLUME_UNITS):
            return True
        if (unit1_lower in cls.PIECE_UNITS and unit2_lower in cls.PIECE_UNITS):
            return True
        
        return False


class ShoppingListService:
    def __init__(self, db: Session):
        self.db = db
        self.repository = ShoppingListRepository(db)
    
    def generate_shopping_list(self, meal_plan_id: int, user_id: int) -> ShoppingList:
        """
        Generate shopping list from meal plan with ingredient aggregation.
        
        Algorithm:
        1. Get all MealPlanItems for the meal plan
        2. For each item, get Recipe and scale RecipeIngredients by servings
        3. Group ingredients by ingredient_id
        4. Convert amounts to common units and aggregate
        5. Create ShoppingList with aggregated items
        """
        # Verify meal plan exists and belongs to user
        meal_plan = self.db.query(MealPlan).filter(
            MealPlan.id == meal_plan_id,
            MealPlan.user_id == user_id
        ).first()
        
        if not meal_plan:
            raise ValueError("Meal plan not found")
        
        # Get all meal plan items with their recipes
        meal_items = self.db.query(MealPlanItem).filter(
            MealPlanItem.meal_plan_id == meal_plan_id
        ).all()
        
        if not meal_items:
            raise ValueError("Meal plan has no meals")
        
        # Initialize ingredient_aggregation dictionary to track ingredients
        # Key: ingredient_id, Value: dict with 'ingredient' and 'amounts' list
        ingredient_aggregation: Dict[int, Dict] = {}

        # Loop through each meal_item
        for meal_item in meal_items:
            # Get the recipe and calculate servings_factor
            recipe = meal_item.recipe
            servings_factor = meal_item.servings / recipe.servings

            # Get all recipe_ingredients for this recipe
            recipe_ingredients = self.db.query(RecipeIngredient).filter(
                RecipeIngredient.recipe_id == recipe.id
            ).all()

            # For each recipe_ingredient
            for recipe_ing in recipe_ingredients:
                # Calculate scaled_amount
                scaled_amount = float(recipe_ing.amount) * servings_factor

                # Add to ingredient_aggregation dict (create entry if not exists)
                if recipe_ing.ingredient_id not in ingredient_aggregation:
                    ingredient_aggregation[recipe_ing.ingredient_id] = {
                        'ingredient': recipe_ing.ingredient,
                        'amounts': []
                    }

                # Append amount and unit to amounts list
                ingredient_aggregation[recipe_ing.ingredient_id]['amounts'].append({
                    'amount': scaled_amount,
                    'unit': recipe_ing.unit
                })
        
        # Create shopping list
        shopping_list = ShoppingList(
            meal_plan_id=meal_plan_id,
            user_id=user_id
        )
        self.db.add(shopping_list)
        self.db.flush()
        
        # Create shopping list items with aggregated amounts
        for ingredient_id, data in ingredient_aggregation.items():
            ingredient = data['ingredient']
            amounts = data['amounts']
            
            # Aggregate amounts with unit conversion
            aggregated = self._aggregate_amounts(amounts)
            
            for agg_amount, agg_unit in aggregated:
                item = ShoppingListItem(
                    shopping_list_id=shopping_list.id,
                    ingredient_id=ingredient_id,
                    amount=agg_amount,
                    unit=agg_unit,
                    purchased=False
                )
                self.db.add(item)
        
        self.db.commit()
        self.db.refresh(shopping_list)
        return shopping_list
    
    def _aggregate_amounts(self, amounts: List[Dict]) -> List[tuple[float, str]]:
        """
        Aggregate amounts with unit conversion.
        Returns list of (amount, unit) tuples - one per unit type.
        """
        # Group by unit type (weight, volume, pieces)
        weight_amounts = []
        volume_amounts = []
        piece_amounts = []
        incompatible = []

        # Loop through amounts and categorize each by unit type
        for item in amounts:
            amount = item['amount']
            unit = item['unit']
            unit_lower = unit.lower()

            # Convert to base unit and categorize
            if unit_lower in UnitConverter.WEIGHT_UNITS:
                base_amount, base_unit = UnitConverter.convert_to_base_unit(amount, unit)
                weight_amounts.append(base_amount)
            elif unit_lower in UnitConverter.VOLUME_UNITS:
                base_amount, base_unit = UnitConverter.convert_to_base_unit(amount, unit)
                volume_amounts.append(base_amount)
            elif unit_lower in UnitConverter.PIECE_UNITS:
                piece_amounts.append(amount)
            else:
                incompatible.append((amount, unit))

        result = []

        # Aggregate weight amounts
        if weight_amounts:
            total_grams = sum(weight_amounts)
            if total_grams >= 1000:
                result.append((round(total_grams / 1000, 2), 'kg'))
            else:
                result.append((round(total_grams, 2), 'g'))

        # Aggregate volume amounts
        if volume_amounts:
            total_ml = sum(volume_amounts)
            if total_ml >= 1000:
                result.append((round(total_ml / 1000, 2), 'l'))
            else:
                result.append((round(total_ml, 2), 'ml'))

        # Aggregate piece amounts
        if piece_amounts:
            total_pieces = sum(piece_amounts)
            result.append((round(total_pieces, 2), 'piece'))

        # Keep incompatible units separate
        for amount, unit in incompatible:
            result.append((amount, unit))
        
        return result if result else [(0, 'piece')]
    
    def mark_purchased(self, item_id: int, user_id: int) -> ShoppingListItem:
        """Mark a shopping list item as purchased."""
        item = self.db.query(ShoppingListItem).join(ShoppingList).filter(
            ShoppingListItem.id == item_id,
            ShoppingList.user_id == user_id
        ).first()
        
        if not item:
            raise ValueError("Shopping list item not found")
        
        item.purchased = True
        self.db.commit()
        self.db.refresh(item)
        return item