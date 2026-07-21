# Orchestrate: RecipeBox Implementation

**Purpose:** Orchestrate RecipeBox implementation using specialized agents across 6 phases (T001-T023).

**Total Estimated Time:** ~24h sequential, ~19.5h with parallelization

---

## Required Context

Before starting, ensure these files are available:
- `@CLAUDE.md` - Project constitution (auto-loaded)
- `@specs/recipebox/tasks.md` - Task definitions (T001-T023)
- `@specs/recipebox/technical-plan.md` - Implementation details
- `@specs/recipebox/dependency-graph.md` - Task dependencies
- `@docs/domain-model.md` - Entity specifications

---

## Phase 1: Foundation (T001-T006)

**Duration:** ~6 hours (sequential)
**Critical Path:** All subsequent phases depend on this

### Tasks

**T001: User Model and Repository (60 min)**
```
Delegate to task-executor:
"Execute T001 from @specs/recipebox/tasks.md. Implement User model with UUID PK, email unique constraint, password_hash, name, created_at. Implement UserRepository with create(), get_by_id(), get_by_email(). Write unit tests achieving ≥90% coverage."

Validation:
pytest tests/unit/repositories/test_user_repository.py -v
pytest --cov=app/repositories/user_repository.py --cov-fail-under=90 tests/
```

**T002: Recipe Model (60 min)**
```
Delegate to task-executor:
"Execute T002. Implement Recipe model with all fields per technical-plan.md: id, user_id FK, name, description, instructions, prep_time_minutes, cook_time_minutes, servings, tags ARRAY, timestamps. Add CheckConstraints (servings 1-50, times >=0). Add indexes on user_id and name."

Validation:
pytest tests/unit/models/test_recipe_model.py -v
```

**T003: Ingredient and RecipeIngredient Models (75 min)**
```
Delegate to task-executor:
"Execute T003. Implement Ingredient model with category Enum (9 values). Implement RecipeIngredient model with amount Numeric(10,2), unit Enum (11 values), CheckConstraint amount 0.01-9999.99, UniqueConstraint (recipe_id, ingredient_id)."

Validation:
pytest tests/unit/models/test_ingredient_models.py -v
```

**T004: MealPlan and MealPlanItem Models (60 min)**
```
Delegate to task-executor:
"Execute T004. Implement MealPlan with week_start_date Date, UniqueConstraint (user_id, week_start_date). Implement MealPlanItem with meal_type Enum (4 values), servings CheckConstraint 1-50. Set up cascade relationships."

Validation:
pytest tests/unit/models/test_meal_plan_models.py -v
```

**T005: ShoppingList and ShoppingListItem Models (60 min)**
```
Delegate to task-executor:
"Execute T005. Implement ShoppingList with meal_plan_id unique FK. Implement ShoppingListItem with total_amount Numeric(10,2), unit Enum, checked Boolean default False, UniqueConstraint (shopping_list_id, ingredient_id)."

Validation:
pytest tests/unit/models/test_shopping_list_models.py -v
```

**T006: Alembic Migration and Database Setup (45 min)**
```
Delegate to task-executor:
"Execute T006. Create single Alembic migration creating all 8 tables with indexes, constraints, and relationships. Ensure upgrade() and downgrade() both work."

Validation:
alembic upgrade head
alembic downgrade -1
alembic upgrade head
pytest tests/unit/models/ -v
```

### Checkpoint 1: Foundation Complete

**Validation Criteria:**
- [ ] All 8 models defined with correct types and constraints
- [ ] Alembic migration runs successfully (upgrade and downgrade)
- [ ] All model unit tests pass
- [ ] Coverage ≥90% for models
- [ ] Database schema matches specification

**Checkpoint Commands:**
```bash
alembic upgrade head
pytest tests/unit/models/ -v
pytest --cov=app/models --cov-report=term tests/unit/models/
```

**Expected Output:**
- All tests green
- Migration version at head
- 8 tables created in database

---

## Phase 2: Recipe API (T007-T010)

**Duration:** ~4.5 hours
**Can Run in Parallel with Phase 3**

### Tasks

**T007: RecipeRepository and RecipeService (75 min)**
```
Delegate to task-executor:
"Execute T007. Implement RecipeRepository with CRUD methods enforcing user authorization. Implement RecipeService with scale_recipe_ingredients() using formula: scaled_amount = round(amount * (new_servings / recipe.servings), 2). Validate servings 1-50."

Validation:
pytest tests/unit/services/test_recipe_service.py -v
pytest --cov=app/services/recipe_service.py --cov-fail-under=90 tests/
```

**T008: Recipe Pydantic Schemas and Dependencies (45 min)**
```
Delegate to task-executor:
"Execute T008. Create RecipeCreateRequest, RecipeUpdateRequest, RecipeResponse schemas. Implement dependency functions: get_db(), get_recipe_repository(), get_recipe_service()."

Validation:
pytest tests/unit/schemas/ -v -k recipe
```

**T009: Recipe API Endpoints (75 min)**
```
Delegate to task-executor:
"Execute T009. Implement 5 recipe endpoints: POST /recipes (201), GET /recipes/{id} with optional servings param (200), GET /recipes (200), PUT /recipes/{id} (200), DELETE /recipes/{id} (204). Add exception handlers for RecipeNotFoundError → 404, ValidationError → 422."

Validation:
pytest tests/integration/test_recipe_routes.py -v
```

**T010: Recipe API Integration Tests (60 min)**
```
Delegate to task-executor:
"Execute T010. Write integration tests for all 5 recipe endpoints. Test scaling, authorization (403 for other user's recipes), error cases (404, 422). Use TestClient with test database."

Validation:
pytest tests/integration/test_recipe_routes.py -v
pytest --cov=app/routes/recipes.py --cov-fail-under=90 tests/integration/
```

### Checkpoint 2A: Recipe API Complete

**Validation Criteria:**
- [ ] Recipe CRUD endpoints functional (POST, GET, PUT, DELETE)
- [ ] Serving scaling works correctly (test: 4→8 servings doubles amounts)
- [ ] Authorization enforced (user cannot access other user's recipes)
- [ ] Error responses correct (404 for not found, 422 for validation)
- [ ] Integration tests pass with ≥90% coverage

**Checkpoint Commands:**
```bash
pytest tests/integration/test_recipe_routes.py -v
curl -X POST http://localhost:8000/recipes -H "Content-Type: application/json" -d '{"name": "Test Recipe", "servings": 4, ...}'
```

---

## Phase 3: Meal Planning (T011-T014)

**Duration:** ~4.5 hours
**Can Run in Parallel with Phase 2**

### Tasks

**T011: MealPlanRepository and MealPlanService (75 min)**
```
Delegate to task-executor:
"Execute T011. Implement MealPlanRepository and MealPlanItemRepository with CRUD methods. Implement MealPlanService validating: week_start_date is Monday (weekday()==0), within next 30 days, meal item dates within plan's week."

Validation:
pytest tests/unit/services/test_meal_plan_service.py -v -k date
```

**T012: MealPlan Pydantic Schemas (45 min)**
```
Delegate to task-executor:
"Execute T012. Create MealPlanCreateRequest with custom validator ensuring Monday. Create MealPlanResponse with nested MealPlanItemResponse list. Create MealPlanItemCreateRequest with meal_type enum and servings 1-50."

Validation:
pytest tests/unit/schemas/ -v -k meal_plan
```

**T013: Meal Plan API Endpoints (75 min)**
```
Delegate to task-executor:
"Execute T013. Implement 7 meal plan endpoints: plan CRUD (4 endpoints), meal item operations (POST add, PUT update servings, DELETE remove). All with dependency injection."

Validation:
pytest tests/integration/test_meal_plan_routes.py -v
```

**T014: Meal Plan API Integration Tests (60 min)**
```
Delegate to task-executor:
"Execute T014. Write integration tests for all 7 endpoints. Test date validation (reject Tuesday, reject past date, reject >30 days). Test cascade delete. Test authorization."

Validation:
pytest tests/integration/test_meal_plan_routes.py -v
```

### Checkpoint 2B: Meal Planning Complete

**Validation Criteria:**
- [ ] MealPlan CRUD endpoints functional
- [ ] Date validation enforced (Monday check, 30-day window)
- [ ] Meal items can be added/removed from plan
- [ ] Cascade delete works (deleting plan deletes items)
- [ ] Integration tests pass with ≥90% coverage

**Checkpoint Commands:**
```bash
pytest tests/integration/test_meal_plan_routes.py -v
pytest --cov=app/services/meal_plan_service.py tests/
```

---

## Merge Point 1: Recipe + MealPlan Complete

**Validation:** Both Phase 2 and Phase 3 must be complete before proceeding to Phase 4.

**Combined Validation:**
```bash
pytest tests/integration/test_recipe_routes.py tests/integration/test_meal_plan_routes.py -v
pytest --cov=app --cov-report=term-missing tests/unit/ tests/integration/
```

---

## Phase 4: Shopping Lists (T015-T017)

**Duration:** ~3.75 hours (sequential after Phases 2 & 3)

### Tasks

**T015: ShoppingListService with 6-Step Aggregation (90 min)**
```
Delegate to task-executor:
"Execute T015. Implement ShoppingListService.generate_shopping_list() with full 6-step algorithm:
1. COLLECT all MealPlanItems
2. SCALE ingredients by (item.servings / recipe.servings)
3. GROUP by (ingredient_id, unit)
4. CONVERT to common unit (priority: metric > imperial > piece)
5. SUM amounts (round to 2 decimals)
6. CREATE ShoppingListItems ordered by category

Implement unit conversion table: 1 cup = 236.6 ml, 1 lb = 453.6 g, etc."

Validation:
pytest tests/unit/services/test_shopping_list_service.py -v -k aggregation
```

**T016: Shopping List API Endpoints (60 min)**
```
Delegate to task-executor:
"Execute T016. Implement 4 endpoints: POST /shopping-lists (generate), GET /shopping-lists/{id}, PATCH /shopping-lists/items/{item_id} (toggle checked), DELETE /shopping-lists/{id}."

Validation:
pytest tests/integration/test_shopping_list_routes.py -v
```

**T017: Shopping List Integration and E2E Tests (75 min)**
```
Delegate to task-executor:
"Execute T017. Write E2E test: create 2 recipes with shared ingredient (flour) → create meal plan → add both recipes → generate shopping list → assert flour aggregated correctly (e.g., 2 cups + 1 cup = 3 cups)."

Validation:
pytest tests/e2e/test_shopping_list_workflow.py -v
```

### Checkpoint 3: Shopping Lists Complete

**Validation Criteria:**
- [ ] 6-step aggregation algorithm implemented correctly
- [ ] Unit conversion works (test: 1 cup + 236.6 ml = 473.2 ml)
- [ ] Shopping list items ordered by ingredient category
- [ ] E2E workflow works (recipe → meal plan → shopping list)
- [ ] Aggregation verified with concrete example

**Checkpoint Commands:**
```bash
pytest tests/e2e/test_shopping_list_workflow.py -v
pytest tests/unit/services/test_shopping_list_service.py::test_aggregate_same_ingredient -v
```

**Expected Output:**
- E2E test creates 2 recipes, generates shopping list
- Shared ingredient aggregated: 2 cups + 1 cup = 3 cups
- Items grouped by category (produce, dairy, etc.)

**Delegate to recipe-validator:**
```
"Validate shopping list aggregation algorithm. Run tests verifying:
1. Two recipes with same ingredient aggregate amounts correctly
2. Unit conversion follows priority (metric > imperial > piece)
3. Incompatible units (volume + weight) stay separate
Provide validation report with test results."
```

---

## Phase 5: Search & Nutrition (T018-T020)

**Duration:** ~3 hours
**T018 and T019-T020 can run in parallel**

### Tasks

**T018: Recipe Search Implementation (60 min)**
```
Delegate to task-executor:
"Execute T018. Implement SearchService.search_recipes() with ILIKE on name, description, tags. Support optional filters: prep_time_max, cook_time_max. Order by relevance (exact match first). Add GET /recipes/search endpoint."

Validation:
pytest tests/unit/services/test_search_service.py -v
pytest tests/integration/test_recipe_routes.py::test_search -v
```

**T019: Nutrition Service and Redis Cache (75 min)**
```
Delegate to task-executor:
"Execute T019. Implement NutritionService checking Redis cache first (key: nutrition:ingredient:{id}). If not cached, queue job to 'nutrition_queue' and raise NutritionNotReadyError. Implement NutritionFetchWorker calling mock USDA API, caching with 7-day TTL."

Validation:
pytest tests/unit/services/test_nutrition_service.py -v
```

**T020: Nutrition API Endpoints (45 min)**
```
Delegate to task-executor:
"Execute T020. Implement GET /recipes/{id}/nutrition and GET /meal-plans/{id}/nutrition. Return 202 Accepted if data not cached yet. Return 200 with NutritionResponse (calories, protein_g, carbs_g, fat_g) when available."

Validation:
pytest tests/integration/test_nutrition_routes.py -v
```

### Checkpoint 4: Search & Nutrition Complete

**Validation Criteria:**
- [ ] Recipe search returns results matching query
- [ ] Search supports time filters (prep_time_max, cook_time_max)
- [ ] Nutrition data cached in Redis with 7-day TTL
- [ ] Background worker processes nutrition queue
- [ ] Nutrition endpoints return 202 when not ready, 200 when cached

**Checkpoint Commands:**
```bash
pytest tests/unit/services/test_search_service.py tests/unit/services/test_nutrition_service.py -v
redis-cli GET nutrition:ingredient:test-id
redis-cli LLEN nutrition_queue
```

---

## Phase 6: Quality & Documentation (T021-T023)

**Duration:** ~3.25 hours (sequential after all features)

### Tasks

**T021: Test Enhancement to 95% Coverage (75 min)**
```
Delegate to test-enhancer:
"Enhance test coverage from 90% to 95%. Focus on:
1. Error paths (404, 422, 403, 500 responses)
2. Boundary conditions (servings=1, servings=50, amount=0.01, amount=9999.99)
3. Edge cases (empty meal plan, zero prep time, recipe with no ingredients)
4. Critical paths must reach 100%: shopping list aggregation, serving scaling, date validation

Run coverage report, identify gaps, add missing tests."

Validation:
pytest --cov=app --cov-report=html --cov-report=term tests/
# Verify coverage ≥95%
```

**T022: Security and Error Handling Review (60 min)**
```
Delegate to task-executor:
"Execute T022. Review:
1. Exception handlers: all domain exceptions map to correct HTTP status
2. No sensitive data in error responses (no stack traces, no DB errors)
3. Authorization checks on all endpoints (user can only access own data)
4. No SQL injection vectors (verify parameterized queries only)
5. Input validation via Pydantic on all request bodies"

Validation:
grep -r "raise HTTPException" app/routes/
grep -r "session.execute" app/  # Should be empty (use ORM only)
pytest tests/integration/ -v -k "403 or 404 or 422"
```

**T023: Documentation and Deployment Guide (60 min)**
```
Delegate to doc-updater:
"Execute T023. Update:
1. README.md: feature list, setup instructions, API examples (create recipe, meal plan, shopping list)
2. docs/API.md: all 18 endpoints with request/response schemas
3. docs/DEPLOYMENT.md: environment vars, migrations, Redis setup, worker deployment
4. Create ADRs: repository pattern, 6-step aggregation, Redis caching, unit conversion, service layer
Verify OpenAPI docs at /docs are current."

Validation:
Read README.md
Read docs/API.md
Read docs/DEPLOYMENT.md
Read docs/adr/
curl http://localhost:8000/docs
```

### Checkpoint 5: Quality & Documentation Complete

**Validation Criteria:**
- [ ] Test coverage ≥95% overall
- [ ] Critical paths at 100% coverage
- [ ] No security issues (authorization, SQL injection, error exposure)
- [ ] README has setup instructions and 3+ API examples
- [ ] API documentation covers all 18 endpoints
- [ ] Deployment guide complete with environment vars
- [ ] 5 ADRs created (repository, aggregation, caching, conversion, service layer)

**Checkpoint Commands:**
```bash
pytest --cov=app --cov-report=term-missing tests/
grep -c "✓" README.md  # Count completed features
ls docs/adr/*.md | wc -l  # Should be ≥5
curl http://localhost:8000/docs | grep -c "Recipe"
```

---

## Final Checkpoint: Project Complete

### Comprehensive Validation

**1. All Tests Pass:**
```bash
pytest tests/ -v
# Expected: 100+ tests, all passing, 0 failed
```

**2. Coverage Target Met:**
```bash
pytest --cov=app --cov-report=html --cov-report=term tests/
# Expected: ≥95% overall, critical paths 100%
```

**3. API Functional:**
```bash
# Start server
uvicorn app.main:app --reload

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

**4. Database Migrations:**
```bash
alembic current  # Should show head
alembic history  # Should show all migrations
```

**5. Redis & Worker:**
```bash
redis-cli PING  # Should return PONG
redis-cli LLEN nutrition_queue  # Check queue
```

**6. Business Logic Validation:**
```
Delegate to recipe-validator:
"Perform final validation of RecipeBox business logic:
1. Serving scaling formula: 4→8 servings doubles amounts correctly
2. Date validation: Monday check, 0-30 days, within week
3. Shopping list 6-step aggregation: verify with 2-recipe example
4. Unit conversion: 1 cup + 236.6 ml = 473.2 ml
5. Error handling: 404, 422, 403, 500 all return correct responses
Provide comprehensive validation report."
```

### Completion Criteria

**Must Have:**
- ✓ All 23 tasks (T001-T023) complete
- ✓ All tests passing (unit, integration, E2E)
- ✓ Coverage ≥95% overall, critical paths 100%
- ✓ 18 API endpoints functional
- ✓ Shopping list aggregation verified
- ✓ Documentation complete (README, API, deployment, 5 ADRs)
- ✓ No security issues
- ✓ Database migrations applied

**Deliverables:**
1. Working RecipeBox application
2. 95%+ test coverage report
3. Complete API documentation
4. Deployment guide
5. Architecture decision records
6. Final validation report from recipe-validator

---

## Parallel Execution Strategy

**Option 1: Sequential (Single Developer)**
- Execute phases in order: 1 → 2 → 3 → 4 → 5 → 6
- Total time: ~24 hours

**Option 2: Parallel (Two Agents)**
- Phase 1: Sequential (6h)
- **Phases 2 & 3 in parallel** (4.5h wall time):
  - Agent A: T007→T008→T009→T010 (Recipe API)
  - Agent B: T011→T012→T013→T014 (Meal Planning)
- Phase 4: Sequential after merge (3.75h)
- **Phase 5 tracks in parallel** (2h wall time):
  - Agent A: T018 (Search)
  - Agent B: T019→T020 (Nutrition)
- Phase 6: Sequential (3.25h)
- Total time: ~19.5 hours

**Time Savings:** 4.5 hours (19% reduction)

---

## Efficiency Tracking

**Log for Each Task:**
```
Task: T007
Agent: task-executor
Start: 2025-01-15 10:00
End: 2025-01-15 11:15
Duration: 75 min
Validation: pytest passed, coverage 94%
Status: ✓ Complete
```

**Final Report:**
```
RecipeBox Implementation Complete

Total Tasks: 23
Total Time: 19.5 hours (with parallelization)
Tests: 134 passed, 0 failed
Coverage: 96.2% overall
Critical Paths: 100% coverage
Documentation: Complete (README, API, Deployment, 5 ADRs)
Security Issues: 0

Efficiency Gain: 4.5 hours saved vs sequential (19% improvement)

Status: Ready for production deployment
```

---

## Troubleshooting

**If tests fail:**
1. Check pytest output for specific failure
2. Review acceptance criteria in tasks.md
3. Verify dependencies installed (requirements.txt)
4. Check database connection (DATABASE_URL)

**If coverage below target:**
1. Run: `pytest --cov=app --cov-report=html tests/`
2. Open htmlcov/index.html
3. Identify uncovered lines
4. Delegate to test-enhancer

**If validation fails:**
1. Delegate to recipe-validator for business logic review
2. Check specific algorithm implementation
3. Verify test data matches specification

**If parallel execution conflicts:**
1. Ensure Phases 2 & 3 don't modify same files
2. Coordinate merge at Merge Point 1
3. Run combined tests after merge
