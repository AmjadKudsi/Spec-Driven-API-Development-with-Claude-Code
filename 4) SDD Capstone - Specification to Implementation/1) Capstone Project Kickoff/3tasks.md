# RecipeBox Implementation Tasks

## Phase 1: Foundation (T001-T006)

### T001: Create User Model and Repository
**Estimate:** 60 min
**Dependencies:** None
**Files:** `app/models/user.py`, `app/repositories/user_repository.py`, `tests/unit/repositories/test_user_repository.py`

**Acceptance Criteria:**
- [ ] User model with fields: id (UUID), email (String 255, unique), password_hash (String 255), name (String 200), created_at (DateTime with timezone)
- [ ] UserRepository with methods: create(), get_by_id(), get_by_email()
- [ ] UserRepository raises NotFoundError when user not found
- [ ] Unit tests for all repository methods with ≥90% coverage
- [ ] Type hints on all functions and class attributes

### T002: Create Recipe Model
**Estimate:** 60 min
**Dependencies:** T001
**Files:** `app/models/recipe.py`, `tests/unit/models/test_recipe_model.py`

**Acceptance Criteria:**
- [ ] Recipe model with all fields per technical-plan.md (id, user_id FK, name, description, instructions, prep_time_minutes, cook_time_minutes, servings, tags ARRAY, timestamps)
- [ ] CheckConstraints: name length 1-200, servings 1-50, times >= 0
- [ ] Relationships: belongs to User, has many RecipeIngredients, referenced by MealPlanItems
- [ ] Index on user_id and name columns
- [ ] Unit tests verify constraints raise IntegrityError when violated
- [ ] ForeignKey with ondelete='CASCADE' for user_id

### T003: Create Ingredient and RecipeIngredient Models
**Estimate:** 75 min
**Dependencies:** T002
**Files:** `app/models/ingredient.py`, `app/models/recipe_ingredient.py`, `tests/unit/models/test_ingredient_models.py`

**Acceptance Criteria:**
- [ ] Ingredient model with category Enum (produce, dairy, meat, seafood, bakery, pantry, spices, frozen, other)
- [ ] Ingredient name unique constraint (case-insensitive), CheckConstraint length 1-200
- [ ] RecipeIngredient model with amount Numeric(10,2), unit Enum (11 units per spec)
- [ ] RecipeIngredient CheckConstraint: amount 0.01-9999.99
- [ ] RecipeIngredient UniqueConstraint on (recipe_id, ingredient_id)
- [ ] Unit tests verify unique constraints and amount boundaries

### T004: Create MealPlan and MealPlanItem Models
**Estimate:** 60 min
**Dependencies:** T002
**Files:** `app/models/meal_plan.py`, `app/models/meal_plan_item.py`, `tests/unit/models/test_meal_plan_models.py`

**Acceptance Criteria:**
- [ ] MealPlan model with user_id FK, week_start_date (Date), created_at
- [ ] MealPlan UniqueConstraint on (user_id, week_start_date)
- [ ] MealPlanItem model with meal_type Enum (breakfast, lunch, dinner, snack)
- [ ] MealPlanItem servings CheckConstraint 1-50
- [ ] Relationships: MealPlan has many items (cascade delete), MealPlanItem references Recipe (RESTRICT)
- [ ] Unit tests verify cascade behavior and constraints

### T005: Create ShoppingList and ShoppingListItem Models
**Estimate:** 60 min
**Dependencies:** T004
**Files:** `app/models/shopping_list.py`, `app/models/shopping_list_item.py`, `tests/unit/models/test_shopping_list_models.py`

**Acceptance Criteria:**
- [ ] ShoppingList model with meal_plan_id FK (unique), generated_at timestamp
- [ ] ShoppingListItem model with total_amount Numeric(10,2), unit Enum, checked Boolean default False
- [ ] ShoppingListItem UniqueConstraint on (shopping_list_id, ingredient_id)
- [ ] Relationships: ShoppingList belongs to MealPlan (1-to-1), has many items (cascade delete)
- [ ] ShoppingListItem references Ingredient (RESTRICT)
- [ ] Unit tests verify 1-to-1 constraint and checked flag

### T006: Alembic Migration and Database Setup
**Estimate:** 45 min
**Dependencies:** T001-T005
**Files:** `alembic/versions/001_initial_schema.py`, `app/database.py`, `app/models/__init__.py`

**Acceptance Criteria:**
- [ ] Single Alembic migration creates all 8 tables in correct order
- [ ] All indexes created: recipes(user_id, name), meal_plans(user_id, week_start_date), etc.
- [ ] Migration includes both upgrade() and downgrade() functions
- [ ] `alembic upgrade head` succeeds without errors
- [ ] `alembic downgrade -1` successfully drops all tables
- [ ] Base.metadata exports all models in __init__.py

## Phase 2: Recipe API (T007-T010) - Can run in parallel with Phase 3

### T007: RecipeRepository and RecipeService
**Estimate:** 75 min
**Dependencies:** T006
**Files:** `app/repositories/recipe_repository.py`, `app/services/recipe_service.py`, `tests/unit/services/test_recipe_service.py`

**Acceptance Criteria:**
- [ ] RecipeRepository methods: create(), get_by_id(), get_all_by_user(), update(), delete(), search()
- [ ] RecipeRepository enforces user authorization (recipes belong to user)
- [ ] RecipeService.scale_recipe_ingredients() implements formula: scaled_amount = round(amount * (new_servings / recipe.servings), 2)
- [ ] RecipeService validates servings range 1-50, raises InvalidServingsError
- [ ] Unit tests mock repository, verify scaling math with Decimal types
- [ ] Test coverage ≥90% for service layer

### T008: Recipe Pydantic Schemas and Dependencies
**Estimate:** 45 min
**Dependencies:** T007
**Files:** `app/schemas/recipe.py`, `app/dependencies.py`

**Acceptance Criteria:**
- [ ] RecipeCreateRequest schema with Field validators: name (1-200 chars), servings (1-50), ingredients list
- [ ] RecipeUpdateRequest schema with all optional fields
- [ ] RecipeResponse schema with nested IngredientResponse list
- [ ] Dependency functions: get_db(), get_recipe_repository(), get_recipe_service()
- [ ] All schemas use UUID type, not string

### T009: Recipe API Endpoints
**Estimate:** 75 min
**Dependencies:** T008
**Files:** `app/routes/recipes.py`, `app/main.py`

**Acceptance Criteria:**
- [ ] POST /recipes (201), GET /recipes/{id} (200), GET /recipes (200 list), PUT /recipes/{id} (200), DELETE /recipes/{id} (204)
- [ ] GET /recipes/{id} accepts optional `servings` query param for scaling
- [ ] Exception handlers translate RecipeNotFoundError → 404, ValidationError → 422
- [ ] All routes use Depends() for service injection
- [ ] Router included in main.py FastAPI app
- [ ] OpenAPI docs generated with correct status codes

### T010: Recipe API Integration Tests
**Estimate:** 60 min
**Dependencies:** T009
**Files:** `tests/integration/test_recipe_routes.py`, `tests/conftest.py`

**Acceptance Criteria:**
- [ ] Test fixtures: test_db, test_user, test_user_token in conftest.py
- [ ] Test create recipe returns 201 with correct response body
- [ ] Test get recipe with scaling returns correctly scaled ingredient amounts
- [ ] Test update recipe modifies fields and returns 200
- [ ] Test delete recipe returns 204 and resource no longer exists
- [ ] Test authorization: user cannot access other user's recipes (403)

## Phase 3: Meal Planning (T011-T014) - Can run in parallel with Phase 2

### T011: MealPlanRepository and MealPlanService
**Estimate:** 75 min
**Dependencies:** T006
**Files:** `app/repositories/meal_plan_repository.py`, `app/services/meal_plan_service.py`, `tests/unit/services/test_meal_plan_service.py`

**Acceptance Criteria:**
- [ ] MealPlanRepository methods: create(), get_by_id(), get_by_user_week(), get_all_by_user(), delete()
- [ ] MealPlanItemRepository methods: create(), get_by_meal_plan(), update(), delete()
- [ ] MealPlanService validates: week_start_date is Monday, within next 30 days, no duplicate user+week
- [ ] MealPlanService.add_meal_to_plan() validates date within meal plan's week (start to start+6 days)
- [ ] Unit tests verify date validation raises ValidationError with clear messages
- [ ] Test coverage ≥90%

### T012: MealPlan Pydantic Schemas
**Estimate:** 45 min
**Dependencies:** T011
**Files:** `app/schemas/meal_plan.py`

**Acceptance Criteria:**
- [ ] MealPlanCreateRequest with week_start_date (Date type)
- [ ] MealPlanResponse with nested list of MealPlanItemResponse
- [ ] MealPlanItemCreateRequest with recipe_id, date, meal_type enum, servings (1-50)
- [ ] Custom validator ensures week_start_date is Monday
- [ ] MealType enum matches model (breakfast, lunch, dinner, snack)

### T013: Meal Plan API Endpoints
**Estimate:** 75 min
**Dependencies:** T012
**Files:** `app/routes/meal_plans.py`

**Acceptance Criteria:**
- [ ] POST /meal-plans (201), GET /meal-plans/{id} (200), GET /meal-plans (200 list), DELETE /meal-plans/{id} (204)
- [ ] POST /meal-plans/{id}/meals (201 add meal), PUT /meal-plans/{id}/meals/{meal_id} (200 update servings), DELETE /meal-plans/{id}/meals/{meal_id} (204)
- [ ] All 7 endpoints use dependency injection
- [ ] Exception handlers for MealPlanNotFoundError → 404, date validation errors → 422
- [ ] Router registered in main.py

### T014: Meal Plan API Integration Tests
**Estimate:** 60 min
**Dependencies:** T013
**Files:** `tests/integration/test_meal_plan_routes.py`

**Acceptance Criteria:**
- [ ] Test create meal plan with valid Monday date returns 201
- [ ] Test create meal plan with non-Monday date returns 422
- [ ] Test add meal to plan with date outside week range returns 422
- [ ] Test update meal servings modifies and returns 200
- [ ] Test delete meal plan cascades to meal items
- [ ] Test authorization: user cannot modify other user's meal plans

## Phase 4: Shopping Lists (T015-T017) - Sequential after Phases 2 & 3

### T015: ShoppingListService with 6-Step Aggregation
**Estimate:** 90 min
**Dependencies:** T007, T011
**Files:** `app/services/shopping_list_service.py`, `tests/unit/services/test_shopping_list_service.py`

**Acceptance Criteria:**
- [ ] ShoppingListService.generate_shopping_list() implements full 6-step algorithm per technical-plan.md
- [ ] Step 1-2: Collect meal items and scale ingredients by (item.servings / recipe.servings)
- [ ] Step 3-4: Group by (ingredient_id, unit), convert to common unit with priority metric > imperial > piece
- [ ] Step 5-6: Sum amounts (round to 2 decimals), create ShoppingListItems ordered by ingredient.category
- [ ] Unit conversion table implemented: volume (ml), weight (g), piece (no conversion)
- [ ] Unit tests verify: 2 recipes with same ingredient aggregate correctly, incompatible units stay separate
- [ ] Test coverage ≥90% including edge cases (empty meal plan, single recipe, mixed units)

### T016: Shopping List API Endpoints
**Estimate:** 60 min
**Dependencies:** T015
**Files:** `app/routes/shopping_lists.py`, `app/schemas/shopping_list.py`

**Acceptance Criteria:**
- [ ] POST /shopping-lists (201 generate from meal_plan_id), GET /shopping-lists/{id} (200)
- [ ] PATCH /shopping-lists/items/{item_id} (200 toggle checked status), DELETE /shopping-lists/{id} (204)
- [ ] ShoppingListResponse includes items grouped by ingredient category
- [ ] Handles duplicate generation attempt (shopping list already exists for meal plan)
- [ ] Router registered in main.py

### T017: Shopping List Integration and E2E Tests
**Estimate:** 75 min
**Dependencies:** T016
**Files:** `tests/integration/test_shopping_list_routes.py`, `tests/e2e/test_shopping_list_workflow.py`

**Acceptance Criteria:**
- [ ] Integration test: POST /shopping-lists generates list for valid meal plan
- [ ] Integration test: PATCH item checked status updates and returns 200
- [ ] E2E test: Create 2 recipes → create meal plan → add meals → generate shopping list → verify aggregation
- [ ] E2E test verifies specific ingredient totals match expected (e.g., 2 cups + 1 cup = 3 cups flour)
- [ ] Test handles mixed units: 1 cup milk + 500ml milk = 736.6ml milk total
- [ ] Test authorization: user cannot access other user's shopping lists

## Phase 5: Search & Nutrition (T018-T020) - Can run in parallel after Phase 2

### T018: Recipe Search Implementation
**Estimate:** 60 min
**Dependencies:** T009
**Files:** `app/services/search_service.py`, `tests/unit/services/test_search_service.py`

**Acceptance Criteria:**
- [ ] SearchService.search_recipes() queries with ILIKE on name, description, tags
- [ ] Supports optional filters: prep_time_max, cook_time_max
- [ ] Returns recipes ordered by relevance (exact name match first, then partial)
- [ ] GET /recipes/search endpoint with query param `q` (required), time filters (optional)
- [ ] Unit tests verify: search by name, search by tag, filter by prep time
- [ ] Integration test verifies search returns 200 with matching recipes

### T019: Nutrition Service and Redis Cache
**Estimate:** 75 min
**Dependencies:** T007
**Files:** `app/services/nutrition_service.py`, `app/workers/nutrition_worker.py`, `tests/unit/services/test_nutrition_service.py`

**Acceptance Criteria:**
- [ ] NutritionService.get_ingredient_nutrition() checks Redis cache first (key: nutrition:ingredient:{id})
- [ ] If not cached, queues job to Redis queue 'nutrition_queue' and raises NutritionNotReadyError
- [ ] NutritionFetchWorker.process_job() calls mock USDA API, caches result with 7-day TTL
- [ ] NutritionService.get_recipe_nutrition() aggregates: sum(ingredient_nutrition * amount) / servings
- [ ] NutritionService.get_meal_plan_nutrition() aggregates all meal items with scaling
- [ ] Mock USDA client returns fake nutrition data (calories, protein, carbs, fat)

### T020: Nutrition API Endpoints
**Estimate:** 45 min
**Dependencies:** T019
**Files:** `app/routes/nutrition.py`, `app/schemas/nutrition.py`

**Acceptance Criteria:**
- [ ] GET /recipes/{id}/nutrition returns per-serving and total nutrition (200)
- [ ] GET /meal-plans/{id}/nutrition returns aggregated week nutrition (200)
- [ ] Returns 202 Accepted if nutrition data not yet cached (with message "Nutrition data being fetched")
- [ ] NutritionResponse schema with calories, protein_g, carbs_g, fat_g
- [ ] Integration test: queue nutrition job, process it, then GET returns 200

## Phase 6: Quality & Documentation (T021-T023) - Sequential after all features

### T021: Test Enhancement to 95% Coverage
**Estimate:** 75 min
**Dependencies:** T010, T014, T017, T020
**Files:** Multiple test files across `tests/unit/`, `tests/integration/`, `tests/e2e/`

**Acceptance Criteria:**
- [ ] Run `pytest --cov=app --cov-report=html` and identify uncovered lines
- [ ] Add tests for error paths: RecipeNotFoundError, InvalidServingsError, ValidationError
- [ ] Add boundary tests: servings=1, servings=50, amount=0.01, amount=9999.99
- [ ] Add edge case tests: empty meal plan, recipe with no ingredients, zero prep time
- [ ] Overall test coverage reaches ≥95%
- [ ] Critical paths (shopping list aggregation, serving scaling, auth) at 100%

### T022: Security and Error Handling Review
**Estimate:** 60 min
**Dependencies:** T021
**Files:** All route files, exception handlers, `app/exceptions.py`

**Acceptance Criteria:**
- [ ] Exception handler audit: all domain exceptions map to correct HTTP status codes
- [ ] No sensitive data in error responses (no stack traces, no database errors exposed)
- [ ] All database errors (SQLAlchemyError) caught and logged, return generic 500
- [ ] Authorization checks present on all endpoints (users can only access own data)
- [ ] No SQL injection vectors (all queries use parameterized statements via SQLAlchemy)
- [ ] Input validation: Pydantic handles all request bodies, query params validated

### T023: Documentation and Deployment Guide
**Estimate:** 60 min
**Dependencies:** T022
**Files:** `README.md`, `docs/API.md`, `docs/DEPLOYMENT.md`

**Acceptance Criteria:**
- [ ] README includes: project description, features list, tech stack, setup instructions, running tests
- [ ] API documentation generated from OpenAPI spec (accessible at /docs)
- [ ] DEPLOYMENT.md covers: environment variables, database migrations, Redis setup, running worker
- [ ] Code examples in README for: creating recipe, creating meal plan, generating shopping list
- [ ] All acceptance criteria from original specification.md verified and documented
- [ ] Architecture decision records (ADR) for: repository pattern, 6-step aggregation algorithm, Redis caching

---

## Summary

**Total Estimates:** ~1,440 minutes (~24 hours)

**Parallel Execution:**
- Phase 1 (Foundation): 6 tasks, ~6 hours (sequential)
- Phases 2 & 3 (Recipe API + Meal Planning): Can run in parallel, ~10 hours total, ~6 hours wall time
- Phase 4 (Shopping Lists): 3 tasks, ~4 hours (sequential after 2 & 3)
- Phase 5 (Search & Nutrition): 3 tasks, ~3 hours (can start after Phase 2)
- Phase 6 (Quality & Docs): 3 tasks, ~3 hours (sequential after all features)

**Critical Path:** Phase 1 → Phase 2 or 3 → Phase 4 → Phase 6 = ~19 hours