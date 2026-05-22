# AI Drift Recovery Patterns Guide

**Author:** Amjad Kudsi  
**Date:** May 21, 2026  
**Based On:** 3 drift scenarios with Claude Code

---

## Pattern 1: Reinforce Existing Structure

**When to use:**  
When Claude recreates files or ignores existing project structure.

**Prompt structure:**
"""
Review CLAUDE.md and inspect the existing files before making changes.

Do not recreate the component. Extend the existing implementation while preserving current architecture and naming conventions.
"""

**Key elements:**
- Reference existing files
- Explicitly say “extend existing code”

**Example:**
"""
Review CLAUDE.md and existing repository files before modifying code.

Do not recreate TaskRepository. Add only the `search_by_title` method while preserving repository pattern rules.
"""

---

## Pattern 2: Re-anchor to Architecture Rules

**When to use:**  
When Claude violates repository pattern, dependency injection, or layering rules.

**Prompt structure:**
"""
Follow the [specific architecture section] in CLAUDE.md.

The current implementation violates the project architecture because [reason].

Refactor the code to follow the required pattern.
"""

**Key elements:**
- Mention exact violated rule
- State correct architecture pattern clearly

**Example:**
"""
Follow the Repository Pattern section in CLAUDE.md.

Database queries must stay inside repository classes. Refactor the endpoint to use TagRepository instead of direct SQLAlchemy queries inside the route.
"""

---

## Pattern 3: Explicit Standards Reminder

**When to use:**  
When Claude forgets formatting, type hints, docstrings, or naming conventions.

**Prompt structure:**
"""
Review the Code Standards section in CLAUDE.md.

Ensure the following requirements are satisfied:
- [Requirement 1]
- [Requirement 2]

Update the implementation to fully comply.
"""

**Key elements:**
- Reference Code Standards directly
- List missing requirements explicitly

**Example:**
"""
Review the Code Standards section in CLAUDE.md.

All functions must include:
- Type hints
- Google-style docstrings

Update the function to fully comply with the constitution.
"""

---

## Key Learnings

1. Claude follows project constitutions much better when prompts reference specific sections directly.
2. Short and explicit recovery prompts work better than vague corrections.
3. Clearly identifying the violated rule usually fixes drift within one iteration.