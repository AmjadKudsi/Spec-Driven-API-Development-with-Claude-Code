# Orchestrate: {FEATURE_NAME}

Implement {FEATURE_NAME} using specialized agents with strategic checkpoints.

## Context Setup

Load these at start of orchestration:

```
@specs/{feature}/specification.md
@specs/{feature}/tasks.md
@CLAUDE.md
```

## Orchestration Workflow

### Phase 1: {PHASE_NAME} (Tasks T001-T00X)

For each task in phase:

**Step 1: Delegate to Agent**
```
Task(task-executor): "Execute T00X from @specs/{feature}/tasks.md. Context: @specs/{feature}/specification.md @CLAUDE.md"
```

**Step 2: Receive Agent Report**

Agent returns completion report:
- Files modified
- Tests passing
- Type checking clean
- Acceptance criteria met

**Step 3: Human Review (3 minutes)**

Quick validation:
- [ ] Tests pass locally
- [ ] Changes match task description
- [ ] No obvious issues in code
- [ ] Ready to commit

**Step 4: Track Progress**

Mark task completed in tasks.md:
```markdown
- [x] T00X: Task description
```

**Step 5: Commit**
```bash
git add .
git commit -m "feat({feature}): {task description}"
```

### Phase Checkpoint (After T00X)

Stop for deeper validation (10-15 minutes):

**Automated Checks:**
```bash
pytest tests/ -v --cov=src --cov-report=term-missing
mypy src/ --strict
pytest tests/ -k integration
```

**Integration Validation:**
- [ ] All phase tasks integrate correctly
- [ ] No regressions in existing functionality
- [ ] Coverage ≥90% for new code
- [ ] API contracts maintained

**Git Tag:**
```bash
git tag {feature}-phase1
git push origin {feature}-phase1
```

### Phase 2: {NEXT_PHASE} (Tasks T00Y-T00Z)

[Repeat workflow above]

### Final Validation (Feature Complete)

**Acceptance Criteria:**
- [ ] All tasks completed and committed
- [ ] All acceptance criteria from specification met
- [ ] Feature works end-to-end

**Security Review:**
- [ ] Input validation in place
- [ ] Authorization checks correct
- [ ] No sensitive data exposed

**Performance Check:**
- [ ] No N+1 queries
- [ ] Response times acceptable
- [ ] Database indexes adequate

**Documentation:**
- [ ] openapi.yaml updated
- [ ] README updated if needed
- [ ] Code comments for complex logic

**Git Tag:**
```bash
git tag {feature}-complete
git push origin {feature}-complete
```

## Important Principles

1. **One task at a time** - Complete, review, and commit before moving to next
2. **Trust but verify** - Agents execute, humans validate at checkpoints
3. **Fail fast** - Stop at phase checkpoints if quality issues emerge
4. **Atomic commits** - Each task gets its own commit for easy rollback
5. **Context efficiency** - Load context once, reuse across all task agents

## Time Budget Estimate

```
Total Time = (Tasks × 20min) + (Phases × 12min) + (Final × 15min)

Example (3 tasks, 1 phase):
  = (3 × 20) + (1 × 12) + 15
  = 60 + 12 + 15
  = 87 minutes (~1.5 hours)
```

**Per Task:** ~20 min (agent 15min + review 3min + commit 2min)
**Per Phase Checkpoint:** ~12 min (validation + integration testing)
**Final Validation:** ~15 min (security, performance, docs)