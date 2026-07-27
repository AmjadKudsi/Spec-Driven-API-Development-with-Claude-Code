# RecipeBox — 5-Minute Demo Outline

## 1. Context (30 sec)
- Problem: Building APIs manually is time-consuming and error-prone
- Solution: RecipeBox API built using Spec-Driven Development orchestration
- Demonstrate end-to-end workflow from PRD to production-ready code

## 2. Spec and scoring (45 sec)
- Start with PRD: recipe management, meal planning, shopping list generation
- Domain model: Recipe, Ingredient, MealPlan, ShoppingList entities
- Spec scoring validates implementation completeness (target: ≥85)
- Ensures all requirements translated to working endpoints before delegation

## 3. Orchestration (1 min)
- Show tasks.md: 23 tasks across 6 phases (Foundation → Polish)
- Pick one task: "Implement POST /recipes endpoint"
- Three-step workflow: Delegate to agent → Validate output → Commit to codebase
- Human validates, agent executes—keeps quality high while saving time

## 4. One route + shopping list (1.5 min)
- Demo POST /recipes: create recipe with ingredients
- Create meal plan referencing multiple recipes
- Generate shopping list from meal plan
- Show aggregation logic: combines quantities (e.g., "2 cups flour + 1 cup flour = 3 cups flour")
- End-to-end feature working from single orchestration pass

## 5. Metrics and quality (1 min)
- Time efficiency: 5.75 hours SDD vs 17.25 hours manual—66.7% time savings
- 23 tasks, 345 minutes total (includes agent execution, validation, checkpoints)
- Quality pipeline: test-enhancer ensures coverage, doc-updater maintains documentation
- Agent-generated tests validate business logic without manual test writing

## 6. Wrap (15 sec)
- Spec-first approach ensures completeness before coding
- Orchestration workflow maintains quality with human validation
- Automated quality pipeline handles tests and documentation
- Result: 11.5 hours saved with production-ready code