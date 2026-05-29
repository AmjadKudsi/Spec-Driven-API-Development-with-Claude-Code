# Use Claude Code to analyze TaskMaster’s existing codebase and generate a complete PRD for Task Reminders that matches real project patterns, not guessed code
# The PRD should focus on the why/what, while referencing real models, auth, API, and repository conventions, similar to how the Task Comments PRD references TaskMaster integration points.

# Task 2: Generate Architecture-Aware PRD with Claude

## Learning Objective
Practice AI-assisted PRD generation by having Claude analyze TaskMaster's codebase and generate architecture-aware requirements documentation.

## Detailed Workflow

### 1. Analyze Existing Code
Before prompting, ensure you understand how reminders will fit into the current system. Review:
- **Models:** `src/models/` (How do Task, User, and Comment relate?)
- **API Patterns:** `src/api/tasks.py` (How are endpoints structured?)
- **Conventions:** `CLAUDE.md` (What are the style and architecture rules?)
- **Authentication:** `src/services/auth.py` (How is `get_current_user` implemented?)

### 2. Prompt Claude Code
Use a prompt that forces Claude to look at the code before writing. 

**Recommended Prompt Structure:**
```text
Generate PRD for Task Reminders following docs/prds/task-comments-v1.0.md structure.

CONTEXT:
- Analyze TaskMaster codebase (models/, api/, repositories/)
- Reference existing patterns (Task model, authentication, repository pattern)
- Follow conventions from CLAUDE.md

REQUIREMENTS:
[Paste informal requirements from task description]

STRUCTURE:
- Problem Statement (user need, pain point)
- Users and Personas
- Functional Requirements
- User Stories (Given/When/Then)
- Constraints (technical, business, performance)
- Success Metrics (measurable goals)
- Out of Scope
- Open Questions → Decisions
- Integration with TaskMaster (exact code references)
- Testing Strategy
- Timeline
```

### 3. Review and Refine
Review the generated `docs/prds/task-reminders-v1.0.md` against these criteria:
- **Technical Accuracy:** Does it reference real file paths and model names?
- **Pattern Matching:** Does it follow the Repository pattern used in the project?
- **Feasibility:** Are the constraints realistic for the existing FastAPI/Postgres stack?
- **Completeness:** Are success metrics measurable (e.g., specific % targets)?

**If Claude invents non-existent patterns or skips constraints, provide feedback and ask for a revision.**

### 4. Document Your Process
Fill out the `prd-generation-log.md` to track your prompts, Claude's analysis, and the refinements you made.

## Success Criteria
✅ PRD references real TaskMaster code (not invented patterns)  
✅ Problem statement identifies a clear user need  
✅ Success metrics are specific and measurable  
✅ Integration points specify correct models, APIs, and repositories  
✅ Open questions are resolved and documented as decisions  
✅ Log shows at least one round of critical review and refinement

## Feature: Task Reminders
**Informal Requirements:**
"We need a reminder system for tasks. Users should be able to set a reminder with a due date/time and optional description. The system should support recurring reminders (none, daily, weekly). Custom intervals are out of scope for v1.0. When a reminder is due, the user should receive a notification. Users can mark reminders as complete or delete them. Multiple reminders per task should be supported."

## Time Estimate
60 minutes