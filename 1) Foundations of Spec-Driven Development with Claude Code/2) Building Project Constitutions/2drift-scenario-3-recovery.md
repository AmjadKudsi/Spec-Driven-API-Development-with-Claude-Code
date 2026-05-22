# Drift Scenario 3: Missing Standards

**Date:** May 21, 2026  
**Scenario:** Claude generated code without type hints and docstrings.

---

## Initial Prompt

"""
Create a utility function for formatting task titles.
"""

---

## What Claude Did (DRIFT)

```python
def format_title(title):
    return title.strip().title()
```

**Problem:**
- Missing type hints.
- Missing Google-style docstring.
- Violated the Code Standards section in `CLAUDE.md`.

---

## Recovery Prompt

"""
Review the Code Standards section in CLAUDE.md.

All functions must include:
- Type hints
- Google-style docstrings

Update the function to fully comply with the constitution.
"""

---

## What Claude Did (FIXED)

```python
def format_title(title: str) -> str:
    """Format a task title consistently.

    Args:
        title: Raw task title.

    Returns:
        Cleaned and title-cased task title.
    """

    return title.strip().title()
```

**Result:** ✅ CORRECT

---

## What Worked

1. Referenced the exact standards section from `CLAUDE.md`.
2. Listed the missing requirements explicitly.

---

## Iterations Required

**Total:** 1 ✅
