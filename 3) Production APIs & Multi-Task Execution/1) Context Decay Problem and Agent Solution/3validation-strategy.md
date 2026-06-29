# Validation Strategy for Orchestrated Execution

When you use orchestrated execution with multiple tasks, you need a clear plan for checking quality. This strategy gives you three validation levels that catch errors early while keeping work moving forward.

## Level 1: Task Completion (Per task, 3 minutes)

After each agent completes a task:

**Agent Self-Validates:**
- Tests pass for modified code
- Code coverage maintained or improved
- Type hints complete and valid

**You Validate:**
- Review agent completion report
- Spot check key changes in modified files
- Approve or provide adjustments

**Why This Matters:**
Catching issues immediately prevents cascading errors and keeps subsequent tasks on solid foundation.

## Level 2: Phase Checkpoint (Every 4-5 tasks, 10-15 minutes)

After a phase completes (e.g., T001-T005 foundation):

**Automated Checks:**
```bash
pytest -v
pytest --cov=. --cov-report=term-missing
```

**You Validate:**
- Integration between completed tasks works correctly
- Code follows architectural patterns and standards
- Feature progress aligns with acceptance criteria

**Git Tag:**
`phase-1-foundation` or `checkpoint-t001-t005`

**Why This Matters:**
Validating integration between phases prevents compounding issues and ensures the feature architecture remains sound.

## Level 3: Feature Complete (End of feature, 30-45 minutes)

After all tasks are done:

**Full Validation Checklist:**
- All acceptance criteria met and verified
- Security review completed (authentication, authorization, input validation)
- Performance testing done (load times, query efficiency)
- Documentation updated (API docs, README, architectural decisions)

**Why This Matters:**
Final validation ensures production readiness and prevents costly post-deployment issues.

## Validation Time Budget

Example for 10 tasks:
- Level 1: 10 tasks × 3 min = 30 min
- Level 2: 2 phases × 15 min = 30 min
- Level 3: Final review = 45 min
- **Total: 105 min (1 hr 45 min)**

vs Ad-hoc: Unknown, inconsistent

## Benefits

This structured approach gives you:
- **Predictable timing:** Know exactly how long validation will take
- **Thorough coverage:** Nothing falls through the cracks
- **Efficient workflow:** Catch issues early when they're easiest to fix