# RecipeBox Task Dependencies

## Visual Dependency Graph

```
Phase 1: Foundation (Sequential - 6h)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
T001 → T002 → T003 (Ingredient models)
              T004 (MealPlan models)
              T005 (ShoppingList models)
         ↓
       T006 (Alembic migration)
         ↓
    ┌────┴────┐
    ↓         ↓

Phase 2: Recipe API          Phase 3: Meal Planning
(Parallel - 4.5h each)       (Parallel - 4.5h each)
━━━━━━━━━━━━━━━━━━━━         ━━━━━━━━━━━━━━━━━━━━━━
T007 (Repo + Service)        T011 (Repo + Service)
  ↓                            ↓
T008 (Schemas)               T012 (Schemas)
  ↓                            ↓
T009 (API Routes)            T013 (API Routes)
  ↓                            ↓
T010 (Tests)                 T014 (Tests)
  ↓                            ↓
  └──────┬─────────────────────┘
         ↓
    CHECKPOINT 1
         ↓
Phase 4: Shopping Lists (Sequential - 3.75h)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
T015 (6-step aggregation) → T016 (API) → T017 (E2E tests)
         ↓
    CHECKPOINT 2
         ↓
         ├──────────────────┐
         ↓                  ↓
Phase 5a: Search         Phase 5b: Nutrition
(Parallel - 1h)          (Parallel - 2h)
━━━━━━━━━━━━━━━━         ━━━━━━━━━━━━━━━━━━━
T018 (Search)            T019 (Service + Worker)
                           ↓
                         T020 (API)
         ↓                  ↓
         └──────┬───────────┘
                ↓
           CHECKPOINT 3
                ↓
Phase 6: Quality & Docs (Sequential - 3.25h)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
T021 (95% coverage) → T022 (Security) → T023 (Docs)
                                          ↓
                                     COMPLETE
```

## Critical Path

**Longest Path:** T001 → T002 → T003/T004/T005 → T006 → T007 → T008 → T009 → T010 → T015 → T016 → T017 → T019 → T020 → T021 → T022 → T023

**Critical Path Duration:** ~19 hours wall time

## Parallel Execution Tracks

### Track A: Recipe API (after T006)
- **Tasks:** T007 → T008 → T009 → T010
- **Duration:** 4.5 hours
- **Blocker for:** T015 (Shopping Lists needs Recipe API)

### Track B: Meal Planning (after T006)
- **Tasks:** T011 → T012 → T013 → T014
- **Duration:** 4.5 hours
- **Blocker for:** T015 (Shopping Lists needs Meal Planning)

### Track C: Search (after T010)
- **Tasks:** T018
- **Duration:** 1 hour
- **Independent:** Can run anytime after Recipe API

### Track D: Nutrition (after T010)
- **Tasks:** T019 → T020
- **Duration:** 2 hours
- **Independent:** Can run anytime after Recipe API

## Merge Points

1. **Merge Point 1 (T015):** Requires both T010 AND T014 complete
   - Shopping Lists depend on Recipe + MealPlan implementations

2. **Merge Point 2 (T021):** Requires T017, T018, T020 complete
   - Test enhancement needs all features implemented

## Checkpoints

- **Checkpoint 1 (After T010 & T014):** Validate Recipe and MealPlan APIs working, auth enforced, ≥90% coverage
- **Checkpoint 2 (After T017):** Validate shopping list aggregation algorithm, unit conversion, E2E workflow
- **Checkpoint 3 (After T020):** Validate search and nutrition features, Redis caching, background worker

## Time Estimates

### Sequential Execution (No Parallelization)
```
Phase 1: 6.0h
Phase 2: 4.5h
Phase 3: 4.5h
Phase 4: 3.75h
Phase 5: 3.0h
Phase 6: 3.25h
────────────
Total: ~24h
```

### Parallel Execution (Optimal)
```
Phase 1: 6.0h (sequential)
Phase 2+3: 4.5h (parallel)
Phase 4: 3.75h (sequential after merge)
Phase 5: 2.0h (parallel tracks)
Phase 6: 3.25h (sequential)
────────────
Total: ~19.5h wall time
```

**Time Savings:** ~4.5 hours (19% reduction)

## Execution Strategy

1. **Phase 1 Foundation:** Single developer, sequential (6h)
2. **Phase 2+3 Parallel:** Two developers or two agents in parallel (4.5h wall time)
3. **Phase 4 Merge:** Single developer, critical path (3.75h)
4. **Phase 5 Parallel:** Multiple agents can tackle search and nutrition (2h wall time)
5. **Phase 6 Quality:** Single developer, final polish (3.25h)