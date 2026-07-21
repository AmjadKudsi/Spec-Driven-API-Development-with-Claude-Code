# RecipeBox Project Constitution

## Tech Stack

- **Python 3.11+** - Modern Python with improved type hints and performance
- **FastAPI 0.100+** - Async support and automatic OpenAPI generation
- **PostgreSQL 15+** - Reliable relational database for recipe data
- **SQLAlchemy 2.0** - Modern ORM with improved async support
- **Redis 7+** - Background job queue for nutrition API calls (simpler than Celery)
- **pytest** - Testing framework with ≥90% coverage requirement

## Architectural Principles

### Repository Pattern
All database access MUST go through repository classes. No raw `session.query()` or `session.execute()` calls in routes or services.

**Rules:**
- One repository per entity (e.g., `RecipeRepository`, `MealPlanRepository`)
- Repositories return domain objects (SQLAlchemy models) or raise domain-specific exceptions
- Repository methods: `create()`, `get_by_id()`, `get_all()`, `update()`, `delete()`, plus domain-specific queries
- Repositories receive SQLAlchemy session via dependency injection

**Example:**
```python
class RecipeRepository:
    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, recipe_id: UUID, user_id: UUID) -> Recipe:
        recipe = self.session.query(Recipe).filter(
            Recipe.id == recipe_id,
            Recipe.user_id == user_id
        ).first()
        if not recipe:
            raise RecipeNotFoundError(f"Recipe {recipe_id} not found")
        return recipe
```

### Service Layer
All business logic lives in service classes. Services orchestrate repositories and enforce domain rules.

**Rules:**
- Services receive repositories via constructor injection
- Services validate business constraints (e.g., serving ranges 1-50, date validation)
- Services implement domain algorithms (e.g., serving scaling, shopping list aggregation)
- Services raise domain exceptions (not HTTP exceptions)
- Routes translate service exceptions to HTTP responses

**Example:**
```python
class RecipeService:
    def __init__(self, recipe_repo: RecipeRepository):
        self.recipe_repo = recipe_repo

    def scale_recipe(self, recipe_id: UUID, user_id: UUID, new_servings: int) -> Recipe:
        if not 1 <= new_servings <= 50:
            raise InvalidServingsError("Servings must be between 1 and 50")
        recipe = self.recipe_repo.get_by_id(recipe_id, user_id)
        factor = new_servings / recipe.servings
        # Scale ingredients...
        return recipe
```

### Background Jobs
External API calls (e.g., USDA nutrition API) MUST be asynchronous using Redis queue.

**Rules:**
- Use Redis as job queue (simpler than Celery for learning)
- Worker polls queue, calls external API, caches result in Redis
- Cache TTL: 7 days for nutrition data
- Sync/mocked implementation acceptable for local development
- Jobs: `fetch_nutrition(ingredient_id)`, `aggregate_meal_plan_nutrition(meal_plan_id)`

**Flow:**
1. API endpoint enqueues job: `redis.rpush('nutrition_queue', json.dumps({'ingredient_id': id}))`
2. Worker pops job: `job = redis.blpop('nutrition_queue')`
3. Worker calls USDA API and caches: `redis.setex(f'nutrition:{id}', 604800, json.dumps(data))`

### API-First Design
OpenAPI specification drives API contracts. Define schemas before implementation.

**Rules:**
- Use Pydantic models for all request/response bodies
- FastAPI auto-generates OpenAPI spec from type hints
- Document all endpoints with descriptions, status codes, error responses
- Validation happens at API boundary (Pydantic), business rules in service layer

**Example:**
```python
class RecipeCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    servings: int = Field(..., ge=1, le=50)
    ingredients: list[RecipeIngredientInput]

@router.post("/recipes", response_model=RecipeResponse, status_code=201)
def create_recipe(request: RecipeCreateRequest, service: RecipeService = Depends()):
    return service.create_recipe(request)
```

## Code Standards

### Type Hints
MANDATORY for all function signatures, class attributes, and variables where type is not obvious.

**Rules:**
- Use Python 3.11+ type hints: `list[str]`, `dict[str, int]`, not `List[str]`, `Dict[str, int]`
- Import from `typing` only for complex types: `Optional`, `Union`, `Protocol`
- Use `UUID` from `uuid` module, not `str`
- Return types required for all functions
- Use `-> None` explicitly for procedures

**Example:**
```python
from uuid import UUID
from decimal import Decimal

def scale_ingredient_amount(
    amount: Decimal,
    original_servings: int,
    new_servings: int
) -> Decimal:
    """Scale ingredient amount based on serving size."""
    factor = Decimal(new_servings) / Decimal(original_servings)
    return round(amount * factor, 2)
```

### Docstrings
Use Google-style docstrings for all public classes, methods, and functions.

**Rules:**
- Required for: all public APIs, repositories, services, complex business logic
- Not required for: simple getters/setters, private methods (unless complex)
- Include: brief description, Args, Returns, Raises

**Example:**
```python
def generate_shopping_list(self, meal_plan_id: UUID, user_id: UUID) -> ShoppingList:
    """Generate aggregated shopping list from meal plan.

    Implements 6-step algorithm: collect meal items, scale ingredients,
    group by ingredient_id, convert units, sum amounts, create shopping list items.

    Args:
        meal_plan_id: ID of the meal plan to generate from
        user_id: ID of user (for authorization check)

    Returns:
        Generated ShoppingList with aggregated items grouped by category

    Raises:
        MealPlanNotFoundError: If meal plan doesn't exist or user unauthorized
        ShoppingListAlreadyExistsError: If shopping list already generated
    """
```

### Error Handling
Services raise domain exceptions. Routes catch and translate to HTTPException.

**Rules:**
- Domain exceptions: `RecipeNotFoundError`, `InvalidServingsError`, `UnauthorizedAccessError`
- Routes use exception handlers or try/catch to map to HTTP status codes
- 400: validation errors (Pydantic handles automatically)
- 401: authentication required
- 403: authorization failed (accessing other user's data)
- 404: resource not found
- 422: business rule violation
- 500: unexpected errors (logged, never expose internals)

**Example:**
```python
# Domain exception
class RecipeNotFoundError(Exception):
    pass

# Route handler
@router.get("/recipes/{recipe_id}")
def get_recipe(recipe_id: UUID, service: RecipeService = Depends()):
    try:
        return service.get_recipe(recipe_id, current_user.id)
    except RecipeNotFoundError:
        raise HTTPException(status_code=404, detail="Recipe not found")
    except UnauthorizedAccessError:
        raise HTTPException(status_code=403, detail="Access denied")
```

### Formatting
Use automated formatters for consistency.

**Required Tools:**
- `black` - Code formatter (line length: 100)
- `isort` - Import sorter (profile: black)
- `mypy` - Static type checker (strict mode)
- `ruff` - Fast linter (replaces flake8, pylint)

**Pre-commit hook:**
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        args: [--line-length=100]
  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: [--profile=black]
```

## Agent Orchestration Rules

### Task Delegation
Main orchestrator session delegates specialized tasks to focused agents.

**Agent Types:**
- **task-executor**: Implements single feature (repository + service + route + tests)
- **recipe-validator**: Reviews domain logic (serving scaling, shopping list aggregation)
- **test-enhancer**: Improves test coverage to ≥90% after initial implementation
- **doc-updater**: Updates API docs and technical documentation

**Delegation Rules:**
- Main session NEVER writes production code directly
- Main session creates task breakdown, launches agents, reviews outputs
- Each agent receives clear acceptance criteria and context
- Agents report completion with summary; main session validates

**Example Task:**
```
Main: "Launch task-executor to implement Recipe CRUD endpoints"
Agent receives: domain model, API spec, repository pattern requirements
Agent delivers: RecipeRepository, RecipeService, recipe routes, unit tests
Main: Reviews code, checks for repository pattern compliance, runs tests
```

### Checkpoint Strategy
Reviews happen at phase boundaries to catch issues early.

**Checkpoints:**
1. **After scaffolding**: Validate project structure, dependencies, database setup
2. **After each entity implementation**: Review repository/service/route trio for one entity
3. **After complex business logic**: Validate shopping list aggregation, unit conversion
4. **After test enhancement**: Check coverage report meets ≥90% threshold
5. **Before final delivery**: End-to-end integration test, API docs review

**Review Criteria:**
- Repository pattern followed (no raw queries in routes/services)
- Type hints present on all functions
- Domain exceptions raised (not HTTP exceptions in services)
- Tests cover happy path + edge cases
- Documentation matches implementation

### Parallel Workflows
Independent features can be implemented concurrently.

**Parallel Groups:**
- **Group A** (parallel): Recipe CRUD, Ingredient CRUD, User authentication
- **Group B** (after A, parallel): MealPlan CRUD, Recipe search
- **Group C** (after B, sequential): ShoppingList generation, Nutrition tracking
- **Test enhancement**: Can run in parallel with Group C

**Dependencies:**
- ShoppingList requires Recipe + MealPlan + RecipeIngredient (sequential)
- Nutrition requires Ingredient + Recipe (can start after Group A)
- All tests require their respective features (but test enhancement is separate phase)

**Example Parallel Launch:**
```
Main: Launch 3 task-executor agents in parallel:
  Agent 1: Implement RecipeRepository + RecipeService + recipe routes
  Agent 2: Implement IngredientRepository + IngredientService + ingredient routes
  Agent 3: Implement User authentication (JWT, hashing)
Main: Wait for all 3 to complete, then checkpoint review
```

## Development Workflow

**5-Step Process for Each Feature:**

1. **Model Definition**
   - Define SQLAlchemy model with all fields, relationships, indexes
   - Add constraints (unique, check, foreign keys)
   - Create Alembic migration

2. **Repository Implementation**
   - Write repository class with CRUD methods
   - Implement domain-specific queries
   - Write unit tests (mock/in-memory SQLite)

3. **Service Implementation**
   - Write service class with business logic
   - Implement validation and domain algorithms
   - Write unit tests (mock repositories)

4. **API Route Implementation**
   - Define Pydantic request/response schemas
   - Write route handlers with dependency injection
   - Add exception handling (domain → HTTP)
   - Write integration tests (TestClient)

5. **Test Enhancement**
   - Run coverage report: `pytest --cov=app --cov-report=html`
   - Add tests for edge cases until ≥90% coverage
   - Test error paths, boundary conditions

**Example Feature: Recipe CRUD**
```
Step 1: Create models/recipe.py with Recipe, RecipeIngredient models
Step 2: Create repositories/recipe_repository.py + tests/unit/test_recipe_repository.py
Step 3: Create services/recipe_service.py + tests/unit/test_recipe_service.py
Step 4: Create routes/recipes.py + tests/integration/test_recipe_routes.py
Step 5: Run coverage, add missing tests
```

## Testing Requirements

**Coverage Targets:**
- Minimum: **90%** overall coverage
- Goal: **95%** after test-enhancer phase
- Critical paths: **100%** (shopping list aggregation, serving scaling, auth)

**Test Organization:**
```
tests/
  unit/
    repositories/
      test_recipe_repository.py
    services/
      test_recipe_service.py
  integration/
    test_recipe_routes.py
    test_meal_plan_routes.py
  e2e/
    test_shopping_list_workflow.py
```

**Test Categories:**
- **Unit tests**: Test single class with mocked dependencies
- **Integration tests**: Test API endpoints with TestClient and test database
- **E2E tests**: Test complete workflows (create recipe → add to meal plan → generate shopping list)

**Testing Tools:**
- `pytest` - Test runner
- `pytest-cov` - Coverage reporting
- `pytest-asyncio` - Async test support
- `factory_boy` - Test data factories
- `faker` - Fake data generation

**Example Test:**
```python
def test_scale_recipe_doubles_ingredient_amounts(recipe_service, mock_repo):
    # Arrange
    recipe = Recipe(servings=4, ingredients=[
        RecipeIngredient(amount=Decimal("2.00"), unit="cup")
    ])
    mock_repo.get_by_id.return_value = recipe

    # Act
    scaled = recipe_service.scale_recipe(recipe.id, user_id, new_servings=8)

    # Assert
    assert scaled.ingredients[0].amount == Decimal("4.00")
```

## Error Handling Strategy

**Exception Hierarchy:**
```python
# Domain exceptions (raised by services/repositories)
class RecipeBoxError(Exception):
    """Base exception for all domain errors"""

class NotFoundError(RecipeBoxError):
    """Resource not found"""

class RecipeNotFoundError(NotFoundError):
    pass

class ValidationError(RecipeBoxError):
    """Business rule violation"""

class InvalidServingsError(ValidationError):
    pass

class AuthorizationError(RecipeBoxError):
    """User not authorized"""
```

**Error Flow:**
1. **Repository**: Raises `NotFoundError` if entity not found
2. **Service**: Catches repository errors, adds context, raises domain exceptions
3. **Route**: Catches domain exceptions, translates to `HTTPException`

**Exception Mapping:**
```python
# In routes or global exception handler
@app.exception_handler(NotFoundError)
def handle_not_found(request, exc):
    return JSONResponse(status_code=404, content={"detail": str(exc)})

@app.exception_handler(ValidationError)
def handle_validation(request, exc):
    return JSONResponse(status_code=422, content={"detail": str(exc)})

@app.exception_handler(AuthorizationError)
def handle_authorization(request, exc):
    return JSONResponse(status_code=403, content={"detail": str(exc)})
```

**Never Expose:**
- Database errors (SQLAlchemyError) → log and return 500
- Stack traces in production
- Internal implementation details

## Migration Strategy

**Alembic Setup:**
```bash
alembic init migrations
alembic revision --autogenerate -m "Create recipe tables"
alembic upgrade head
```

**Migration Rules:**
- One migration per logical change (e.g., "Add tags column to recipes")
- Always review auto-generated migrations (add missing indexes, constraints)
- Include both `upgrade()` and `downgrade()`
- Test migrations: `alembic upgrade head && alembic downgrade -1`
- Never edit applied migrations (create new migration instead)

**Example Migration:**
```python
def upgrade():
    op.create_table(
        'recipes',
        sa.Column('id', postgresql.UUID(), nullable=False),
        sa.Column('user_id', postgresql.UUID(), nullable=False),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('servings', sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.CheckConstraint('servings >= 1 AND servings <= 50')
    )
    op.create_index('ix_recipes_user_id', 'recipes', ['user_id'])
```

## Caching Strategy

**Redis Caching for Nutrition Data:**

**Cache Keys:**
- `nutrition:ingredient:{ingredient_id}` - Nutrition per ingredient
- `nutrition:recipe:{recipe_id}` - Aggregated recipe nutrition
- `nutrition:meal_plan:{meal_plan_id}` - Aggregated meal plan nutrition

**Cache Configuration:**
- TTL: 7 days (604800 seconds)
- Format: JSON serialized dict
- Eviction: LRU (Redis handles automatically)

**Cache Flow:**
```python
def get_ingredient_nutrition(self, ingredient_id: UUID) -> NutritionData:
    # 1. Check cache
    cache_key = f"nutrition:ingredient:{ingredient_id}"
    cached = redis.get(cache_key)
    if cached:
        return NutritionData(**json.loads(cached))

    # 2. Queue background job if not cached
    redis.rpush('nutrition_queue', json.dumps({'ingredient_id': str(ingredient_id)}))

    # 3. Return placeholder or 202 Accepted
    raise NutritionNotReadyError("Nutrition data being fetched")

# Background worker
def process_nutrition_job(job_data):
    ingredient_id = job_data['ingredient_id']
    nutrition = usda_api.fetch_nutrition(ingredient_id)  # External API call
    cache_key = f"nutrition:ingredient:{ingredient_id}"
    redis.setex(cache_key, 604800, json.dumps(nutrition))
```

**Cache Invalidation:**
- Ingredient nutrition: Never invalidate (immutable data from USDA)
- Recipe nutrition: Invalidate when recipe ingredients change
- Meal plan nutrition: Invalidate when meal plan items change

**Mock for Development:**
```python
class MockNutritionCache:
    """Use in-memory dict when Redis unavailable"""
    def __init__(self):
        self.cache = {}

    def get(self, key):
        return self.cache.get(key)

    def setex(self, key, ttl, value):
        self.cache[key] = value
```