# Shared Resources - Coordination Guide

When working in parallel, these files often require coordination because multiple features may modify them.

## Critical Shared Files

### src/main.py (Router Registration)

**Why shared:** Multiple features register API routers in the FastAPI application entry point. When two branches add router imports or `include_router` calls in the same section, Git may create a merge conflict.

**Coordination strategy:**

* Identify new routers before parallel work starts.
* Assign router registration to one integration owner.
* Keep feature branches focused on endpoint files instead of repeatedly editing `src/main.py`.
* Register all feature routers together during a foundation or integration step.
* Run syntax checks after resolving router registration changes.

**Example:**

```python
from src.api.endpoints import tasks, tags, reminders

app.include_router(tasks.router, prefix="/api", tags=["tasks"])
app.include_router(tags.router, prefix="/api", tags=["tags"])
app.include_router(reminders.router, prefix="/api", tags=["reminders"])
```

### tests/conftest.py (Test Fixtures)

**Why shared:** Multiple features may need common fixtures such as users, tasks, authenticated clients, and database sessions.

**Coordination strategy:**

* Put common fixtures in the foundation phase.
* Keep feature-specific fixtures inside feature test files when possible.
* Avoid changing existing fixture behavior without coordination.
* Add new shared fixtures only when multiple features need them.
* Run the full test suite after shared fixture changes.

### Database Migrations

**Why shared:** Multiple features may create or modify database tables. If separate branches generate migrations from the same base revision, migration conflicts can occur.

**Coordination strategy:**

* Create shared foundation migrations before parallel feature work.
* Combine related schema changes when features will be built in parallel.
* Avoid generating competing migration files from the same base revision.
* Apply migrations locally before feature implementation continues.
* Verify expected tables exist before starting dependent work.

## Coordination Protocol

### Before Starting Parallel Work

* List all files each feature expects to modify.
* Identify shared files such as `src/main.py`, `tests/conftest.py`, and migration files.
* Decide which shared changes belong in the foundation phase.
* Assign ownership for any shared integration files.
* Confirm that feature branches use different models, services, repositories, and endpoints.

### During Parallel Work

* Avoid editing shared files unless assigned.
* Communicate any new need for shared-file changes.
* Keep feature-specific code in feature-specific files.
* Document any unexpected shared resource immediately.
* Run focused tests before merging.

### After Merge

* Check for unresolved conflict markers.
* Run Python syntax checks.
* Run integration tests for both merged features.
* Verify all expected routes are registered.
* Update documentation with any new conflict patterns.

## Merge Conflict Resolution Checklist

When you encounter a merge conflict:

* [ ] Run `git status` to identify conflicted files.
* [ ] Open each conflicted file.
* [ ] Understand what each branch changed.
* [ ] Keep all valid compatible changes.
* [ ] Remove all conflict marker lines from code files.
* [ ] Run a marker search to confirm the conflict markers are gone.
* [ ] Run syntax checks.
* [ ] Run relevant tests.
* [ ] Stage the resolved files with `git add`.
* [ ] Commit the merge resolution.
* [ ] Document the conflict and prevention strategy.

## Prevention Strategies

### Foundation Phase

The foundation phase should handle shared setup before parallel work begins. This includes shared migrations, base models, common fixtures, and shared integration structure.

### Auto-Discovery Pattern

An auto-discovery or router registry pattern can reduce conflicts in `src/main.py`. Instead of each feature editing the app entry point directly, feature routers can be collected in one central list or package and registered consistently.

### CI/CD Checks

Add automated checks for:

* Python syntax errors.
* Unresolved conflict marker patterns.
* Missing router registrations.
* Failing integration tests.
* Migration ordering problems.
* Shared fixture regressions.

## Examples from Past Conflicts

### Conflict 1: Tags and Reminders Router Registration

Task Tags and Task Reminders both edited `src/main.py`.

Task Tags added the tags router.

Task Reminders added the reminders router.

The conflict was resolved by importing both routers and registering both routes in the FastAPI app.

Resolved pattern:

```python
from src.api.endpoints import tasks, tags, reminders

app.include_router(tasks.router, prefix="/api", tags=["tasks"])
app.include_router(tags.router, prefix="/api", tags=["tags"])
app.include_router(reminders.router, prefix="/api", tags=["reminders"])
```

Recommendation: future parallel feature work should coordinate router registration in a shared integration step.
