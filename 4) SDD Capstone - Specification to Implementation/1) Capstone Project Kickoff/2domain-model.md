# RecipeBox Domain Model

## Entity Definitions

### User
**Purpose:** Represents an authenticated user who owns recipes and meal plans.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `email` (VARCHAR(255), UNIQUE, NOT NULL) — User email address
- `password_hash` (VARCHAR(255), NOT NULL) — Bcrypt hashed password
- `name` (VARCHAR(100), NOT NULL) — User display name
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Account creation timestamp
- `updated_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Last update timestamp

**Constraints:**
- `email` must match email regex pattern: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- `name` length: 1-100 characters
- `password_hash` must be bcrypt format (60 characters)

**Relationships:**
- Has many `Recipe` (one-to-many via `user_id`)
- Has many `MealPlan` (one-to-many via `user_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on `email`

---

### Recipe
**Purpose:** Stores recipe metadata, instructions, and timing information.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `user_id` (UUID, FK to User, NOT NULL) — Owner of the recipe
- `name` (VARCHAR(200), NOT NULL) — Recipe title
- `description` (TEXT, NULLABLE) — Optional recipe description
- `instructions` (TEXT, NOT NULL) — Step-by-step cooking instructions
- `prep_time_minutes` (INTEGER, NOT NULL) — Preparation time in minutes
- `cook_time_minutes` (INTEGER, NOT NULL) — Cooking time in minutes
- `servings` (INTEGER, NOT NULL, DEFAULT 4) — Number of servings
- `tags` (VARCHAR(255)[], NULLABLE) — Array of searchable tags
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Creation timestamp
- `updated_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Last update timestamp

**Constraints:**
- `name` length: 1-200 characters
- `servings` range: 1-50
- `prep_time_minutes` range: 0-1440 (24 hours)
- `cook_time_minutes` range: 0-1440 (24 hours)
- Each tag in `tags` array: 1-50 characters
- Maximum 10 tags per recipe

**Relationships:**
- Belongs to `User` (many-to-one via `user_id`)
- Has many `RecipeIngredient` (one-to-many via `recipe_id`)
- Has many `MealPlanItem` (one-to-many via `recipe_id`)

**Indexes:**
- PRIMARY KEY on `id`
- INDEX on `user_id` (for user's recipe queries)
- INDEX on `name` (for search queries)
- GIN INDEX on `tags` (for tag-based searches)

---

### Ingredient
**Purpose:** Master list of unique ingredients with categorization for shopping list grouping.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `name` (VARCHAR(200), UNIQUE, NOT NULL) — Ingredient name (normalized, lowercase)
- `category` (ENUM, NOT NULL) — Shopping category
  - Categories: `produce`, `dairy`, `meat`, `seafood`, `bakery`, `pantry`, `spices`, `frozen`, `beverages`, `other`
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Creation timestamp

**Constraints:**
- `name` length: 1-200 characters
- `name` must be unique (case-insensitive)
- `name` must be trimmed and normalized
- `category` must be one of the defined enum values

**Relationships:**
- Has many `RecipeIngredient` (one-to-many via `ingredient_id`)
- Has many `ShoppingListItem` (one-to-many via `ingredient_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on `name`
- INDEX on `category` (for grouped queries)

---

### RecipeIngredient
**Purpose:** Join table linking recipes to ingredients with specific amounts and units.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `recipe_id` (UUID, FK to Recipe, NOT NULL, ON DELETE CASCADE) — Associated recipe
- `ingredient_id` (UUID, FK to Ingredient, NOT NULL) — Associated ingredient
- `amount` (DECIMAL(10,2), NOT NULL) — Quantity of ingredient
- `unit` (ENUM, NOT NULL) — Measurement unit
  - Units: `cup`, `tablespoon`, `teaspoon`, `ounce`, `pound`, `gram`, `kilogram`, `milliliter`, `liter`, `piece`, `pinch`, `dash`
- `display_order` (INTEGER, NOT NULL, DEFAULT 0) — Order in ingredient list

**Constraints:**
- `amount` range: 0.01-9999.99
- UNIQUE constraint on (`recipe_id`, `ingredient_id`) — no duplicate ingredients per recipe
- `display_order` range: 0-999

**Relationships:**
- Belongs to `Recipe` (many-to-one via `recipe_id`)
- Belongs to `Ingredient` (many-to-one via `ingredient_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on (`recipe_id`, `ingredient_id`)
- INDEX on `recipe_id` (for recipe ingredient queries)
- INDEX on `ingredient_id` (for ingredient usage queries)

---

### MealPlan
**Purpose:** Container for a week-long meal plan used to organize recipes and generate shopping lists.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `user_id` (UUID, FK to User, NOT NULL) — Owner of the meal plan
- `name` (VARCHAR(200), NOT NULL) — Meal plan title
- `week_start_date` (DATE, NOT NULL) — Starting Monday of the week
- `notes` (TEXT, NULLABLE) — Optional meal plan notes
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Creation timestamp
- `updated_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Last update timestamp

**Constraints:**
- `name` length: 1-200 characters
- `week_start_date` must be a Monday (ISO weekday = 1)
- `week_start_date` must be within 30 days in the past or 90 days in the future from current date
- UNIQUE constraint on (`user_id`, `week_start_date`) — one meal plan per user per week

**Relationships:**
- Belongs to `User` (many-to-one via `user_id`)
- Has many `MealPlanItem` (one-to-many via `meal_plan_id`)
- Has one `ShoppingList` (one-to-one via `meal_plan_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on (`user_id`, `week_start_date`)
- INDEX on `user_id` (for user's meal plan queries)
- INDEX on `week_start_date` (for date range queries)

---

### MealPlanItem
**Purpose:** Associates a recipe with a specific day and meal type within a meal plan.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `meal_plan_id` (UUID, FK to MealPlan, NOT NULL, ON DELETE CASCADE) — Parent meal plan
- `recipe_id` (UUID, FK to Recipe, NOT NULL) — Scheduled recipe
- `meal_date` (DATE, NOT NULL) — Date of the meal (within meal plan week)
- `meal_type` (ENUM, NOT NULL) — Type of meal
  - Types: `breakfast`, `lunch`, `dinner`, `snack`
- `servings` (INTEGER, NOT NULL) — Number of servings for this meal (may differ from recipe default)
- `notes` (TEXT, NULLABLE) — Optional meal-specific notes

**Constraints:**
- `servings` range: 1-50
- `meal_date` must be within the meal plan week (>= week_start_date AND < week_start_date + 7 days)
- UNIQUE constraint on (`meal_plan_id`, `meal_date`, `meal_type`) — one recipe per meal slot

**Relationships:**
- Belongs to `MealPlan` (many-to-one via `meal_plan_id`)
- Belongs to `Recipe` (many-to-one via `recipe_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on (`meal_plan_id`, `meal_date`, `meal_type`)
- INDEX on `meal_plan_id` (for meal plan queries)
- INDEX on `recipe_id` (for recipe usage tracking)

---

### ShoppingList
**Purpose:** Generated shopping list container linked to a meal plan.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `meal_plan_id` (UUID, FK to MealPlan, UNIQUE, NOT NULL, ON DELETE CASCADE) — Associated meal plan
- `generated_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Generation timestamp
- `updated_at` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) — Last update timestamp

**Constraints:**
- UNIQUE constraint on `meal_plan_id` — one shopping list per meal plan

**Relationships:**
- Belongs to `MealPlan` (one-to-one via `meal_plan_id`)
- Has many `ShoppingListItem` (one-to-many via `shopping_list_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on `meal_plan_id`

---

### ShoppingListItem
**Purpose:** Aggregated ingredient quantities for a shopping list, grouped by ingredient and category.

**Fields:**
- `id` (UUID, PK) — Primary key, auto-generated
- `shopping_list_id` (UUID, FK to ShoppingList, NOT NULL, ON DELETE CASCADE) — Parent shopping list
- `ingredient_id` (UUID, FK to Ingredient, NOT NULL) — Ingredient to purchase
- `total_amount` (DECIMAL(10,2), NOT NULL) — Aggregated quantity
- `unit` (ENUM, NOT NULL) — Standardized measurement unit (same enum as RecipeIngredient)
- `checked` (BOOLEAN, NOT NULL, DEFAULT FALSE) — Whether item has been purchased
- `display_order` (INTEGER, NOT NULL, DEFAULT 0) — Order within category

**Constraints:**
- `total_amount` range: 0.01-99999.99
- UNIQUE constraint on (`shopping_list_id`, `ingredient_id`) — one entry per ingredient per list
- `display_order` range: 0-999

**Relationships:**
- Belongs to `ShoppingList` (many-to-one via `shopping_list_id`)
- Belongs to `Ingredient` (many-to-one via `ingredient_id`)

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE INDEX on (`shopping_list_id`, `ingredient_id`)
- INDEX on `shopping_list_id` (for shopping list queries)
- INDEX on `ingredient_id` (for ingredient tracking)

---

## Relationships Diagram

```
User
 |
 +--< Recipe (user_id)
 |     |
 |     +--< RecipeIngredient (recipe_id)
 |     |     |
 |     |     +--> Ingredient (ingredient_id)
 |     |
 |     +--< MealPlanItem (recipe_id)
 |
 +--< MealPlan (user_id)
       |
       +--< MealPlanItem (meal_plan_id)
       |
       +--1 ShoppingList (meal_plan_id)
             |
             +--< ShoppingListItem (shopping_list_id)
                   |
                   +--> Ingredient (ingredient_id)

Legend:
  +--<  one-to-many relationship
  +--1  one-to-one relationship
  +-->  many-to-one reference
```

---

## Key Business Logic

### Serving Scaling Formula

When a recipe is added to a meal plan with different servings than the recipe default, ingredient amounts must be scaled proportionally:

```
scaled_amount = original_amount × (target_servings / recipe_servings)
```

**Example:**
- Recipe: 4 servings, 2 cups flour
- Meal Plan Item: 6 servings
- Scaled Amount: 2 × (6 / 4) = 3 cups flour

**Rounding Rules:**
- Round to 2 decimal places
- For amounts < 0.25: round to nearest 0.05
- For amounts >= 0.25: round to nearest 0.25

---

### Shopping List Aggregation Algorithm (6 Steps)

When generating a shopping list from a meal plan:

**Step 1: Extract all meal plan items**
- Query all `MealPlanItem` records for the given `meal_plan_id`
- Include associated `Recipe` and `RecipeIngredient` data

**Step 2: Scale ingredient amounts**
- For each `RecipeIngredient`, apply serving scaling formula:
  - `scaled_amount = recipe_ingredient.amount × (meal_plan_item.servings / recipe.servings)`

**Step 3: Normalize units**
- Convert all ingredient amounts to standardized base units using unit conversion rules
- Group by base unit families (volume, weight, count)

**Step 4: Aggregate by ingredient**
- Group scaled amounts by `ingredient_id`
- Sum amounts with same standardized unit
- Result: one entry per ingredient with total amount in standardized unit

**Step 5: Convert to display units**
- Convert aggregated amounts back to user-friendly display units
- Prefer common units: cups over milliliters, pounds over grams (for amounts > 1 lb)

**Step 6: Sort by category and create items**
- Group by `ingredient.category`
- Sort categories: produce, dairy, meat, seafood, bakery, pantry, spices, frozen, beverages, other
- Within category, sort alphabetically by ingredient name
- Assign `display_order` sequentially
- Create `ShoppingListItem` records with `checked = false`

---

### Unit Conversion Rules

**Volume Conversions (base unit: milliliter):**
- 1 teaspoon = 5 ml
- 1 tablespoon = 15 ml
- 1 cup = 240 ml
- 1 liter = 1000 ml

**Weight Conversions (base unit: gram):**
- 1 ounce = 28.35 g
- 1 pound = 453.59 g
- 1 kilogram = 1000 g

**Count Units:**
- `piece`, `pinch`, `dash` — no conversion, aggregate by count only

**Conversion Logic:**
- Only aggregate ingredients with compatible unit families (volume-to-volume, weight-to-weight)
- Count units cannot be converted to volume or weight
- If multiple unit families exist for same ingredient, keep separate entries

**Example:**
- Recipe A: 2 cups milk
- Recipe B: 500 ml milk
- Conversion: 2 cups = 480 ml
- Aggregated: 480 ml + 500 ml = 980 ml
- Display: 4.08 cups (or "approximately 4 cups")

---

### Nutrition Calculation

**Data Source:**
- USDA FoodData Central API
- Cache nutrition data per ingredient to minimize API calls

**Calculation Method:**
1. Fetch nutrition data for each ingredient (per 100g standard)
2. Convert recipe ingredient amounts to grams using density table or API data
3. Scale nutrition values: `nutrient_value × (ingredient_amount_g / 100)`
4. Sum all ingredient nutrition values for total recipe nutrition
5. Divide by recipe servings for per-serving nutrition

**Cached Fields (per ingredient):**
- `calories` (kcal per 100g)
- `protein_g` (grams per 100g)
- `carbohydrates_g` (grams per 100g)
- `fat_g` (grams per 100g)
- `fiber_g` (grams per 100g)
- `sodium_mg` (milligrams per 100g)

**Display Format:**
- Show per-serving values on recipe detail
- Round to 1 decimal place for macros
- Show total and per-serving for meal plan items

---

## Database Indexes Summary

**User:**
- PRIMARY KEY: `id`
- UNIQUE: `email`

**Recipe:**
- PRIMARY KEY: `id`
- INDEX: `user_id`
- INDEX: `name`
- GIN INDEX: `tags`

**Ingredient:**
- PRIMARY KEY: `id`
- UNIQUE: `name`
- INDEX: `category`

**RecipeIngredient:**
- PRIMARY KEY: `id`
- UNIQUE: (`recipe_id`, `ingredient_id`)
- INDEX: `recipe_id`
- INDEX: `ingredient_id`

**MealPlan:**
- PRIMARY KEY: `id`
- UNIQUE: (`user_id`, `week_start_date`)
- INDEX: `user_id`
- INDEX: `week_start_date`

**MealPlanItem:**
- PRIMARY KEY: `id`
- UNIQUE: (`meal_plan_id`, `meal_date`, `meal_type`)
- INDEX: `meal_plan_id`
- INDEX: `recipe_id`

**ShoppingList:**
- PRIMARY KEY: `id`
- UNIQUE: `meal_plan_id`

**ShoppingListItem:**
- PRIMARY KEY: `id`
- UNIQUE: (`shopping_list_id`, `ingredient_id`)
- INDEX: `shopping_list_id`
- INDEX: `ingredient_id`

---

## Entity Cardinality Summary

| Relationship | Cardinality | Delete Behavior |
| --- | --- | --- |
| User → Recipe | 1:N | CASCADE (delete user's recipes) |
| User → MealPlan | 1:N | CASCADE (delete user's meal plans) |
| Recipe → RecipeIngredient | 1:N | CASCADE (delete recipe ingredients) |
| Recipe → MealPlanItem | 1:N | RESTRICT (prevent deletion if in meal plan) |
| Ingredient → RecipeIngredient | 1:N | RESTRICT (prevent deletion if in use) |
| Ingredient → ShoppingListItem | 1:N | RESTRICT (prevent deletion if in use) |
| MealPlan → MealPlanItem | 1:N | CASCADE (delete meal plan items) |
| MealPlan → ShoppingList | 1:1 | CASCADE (delete shopping list) |
| ShoppingList → ShoppingListItem | 1:N | CASCADE (delete shopping list items) |
