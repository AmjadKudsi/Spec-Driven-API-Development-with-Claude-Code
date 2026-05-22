# Drift Scenario 1: Ignoring Existing Code

**Date:** May 21, 2026  
**Scenario:** Claude recreated an existing repository file instead of extending it.

---

## Initial Prompt

"""
Update the task repository to add a search_by_title method.
"""

---

## What Claude Did (DRIFT)

```python
class TaskRepository:
    def create_task(self, title):
        pass
```

**Problem:**
- Claude recreated the repository instead of modifying the existing file.
- Violated the Architectural Principles section in `CLAUDE.md`.
- Ignored existing project structure and patterns.

---

## Recovery Prompt

"""
Review CLAUDE.md and the existing repository files before making changes.

Do not recreate the repository class. Extend the existing TaskRepository by adding only the new `search_by_title` method while preserving current project structure and repository pattern rules.
"""

---

## What Claude Did (FIXED)

```python
def search_by_title(self, title: str) -> List[Task]:
    """Search tasks by title."""

    return (
        self.db.query(Task)
        .filter(Task.title.ilike(f"%{title}%"))
        .all()
    )
```

**Result:** ✅ CORRECT

---

## What Worked

1. Explicitly referenced `CLAUDE.md`.
2. Told Claude to extend existing code instead of recreating it.

---

## Iterations Required

**Total:** 1 ✅
