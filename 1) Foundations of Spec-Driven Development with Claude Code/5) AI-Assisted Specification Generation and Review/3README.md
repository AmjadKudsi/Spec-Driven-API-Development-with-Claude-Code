# Use Claude Code to compare specification-agent-1.md and specification-agent-2.md, then document at least 5 divergences in divergence-analysis.md
# make Claude create specification-unified.md, evaluate it, and ensure score is 85/100 or higher with Consistency 19-20/20.

# Bulk Status Update Feature Specification

## Purpose
Consolidate two AI-generated specifications into unified spec using TaskMaster conventions.

## Workflow
1. ✅ Review specification-agent-1.md (detailed prompt)
2. ✅ Review specification-agent-2.md (simple prompt)
3. ⏸ Compare and document divergences → divergence-analysis.md
4. ⏸ Consolidate into unified spec → specification-unified.md
5. ⏸ Evaluate unified spec → evaluation-report.md

## Feature: Bulk Status Update

Allow users to update the status of multiple tasks simultaneously:
- Update 2-50 tasks in a single request
- Only task owner can bulk update their tasks
- All tasks must belong to the same user
- All-or-nothing validation: if one task fails, none update
- Allowed transitions: pending→in_progress, in_progress→completed, any→cancelled

## Files
- `specification-agent-1.md` — First spec (detailed prompt, provided)
- `specification-agent-2.md` — Second spec (simple prompt, provided)
- `divergence-analysis.md` — Your comparison and decisions (YOUR WORK)
- `specification-unified.md` — Consolidated spec (YOUR WORK)
- `evaluation-report.md` — Quality assessment (Claude generates)

## Success Criteria
- Divergence analysis identifies ≥5 differences
- Each difference has rationale referencing TaskMaster conventions
- Unified spec scores ≥85/100
- Consistency dimension scores 19-20/20