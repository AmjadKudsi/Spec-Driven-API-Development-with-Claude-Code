# Drift Scenario 2: Wrong Pattern

**Date:** May 21, 2026  
**Scenario:** Claude used direct database access instead of the repository pattern.

---

## Initial Prompt

"""
Create an endpoint to fetch tags by ID.
"""

---

## What Claude Did (DRIFT)

```python
@router.get("/tags/{tag_id}")
def get_tag(tag_id: UUID, db: Session):
    return db.query(Tag).filter(Tag.id == tag_id).first()
```

**Problem:**
- Direct database access was placed inside the API route.
- Violated the Repository Pattern rule in `CLAUDE.md`.
- Mixed API logic with database logic.

---

## Recovery Prompt

"""
Follow the Repository Pattern section in CLAUDE.md.

Database queries must stay inside repository classes. Refactor this endpoint to use `TagRepository` instead of direct SQLAlchemy queries inside the route.
"""

---

## What Claude Did (FIXED)

```python
@router.get("/tags/{tag_id}")
def get_tag(tag_id: UUID, repository: TagRepository):
    return repository.get_by_id(tag_id)
```

**Result:** ✅ CORRECT

---

## What Worked

1. Referenced the exact architectural rule from `CLAUDE.md`.
2. Clearly identified the violation and desired pattern.

---

## Iterations Required

**Total:** 1 ✅
