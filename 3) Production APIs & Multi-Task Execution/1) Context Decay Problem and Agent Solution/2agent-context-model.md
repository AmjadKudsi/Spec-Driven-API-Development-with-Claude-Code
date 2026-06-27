# Agent Context Model

## What Agents Automatically Get
✓ **CLAUDE.md** - All three scenarios confirmed agents can read project instructions from CLAUDE.md
✓ **The instruction itself** - All scenarios confirmed agents receive the user instruction
✓ **@ referenced files** - Scenarios 2 and 3 confirmed agents receive files referenced with @ syntax (specs/test.md and src/model.py)

## What Agents Don't Get
✗ **Previous agent outputs** - All three scenarios confirmed agents cannot see outputs from previous agent invocations
✗ **Conversation history** - I CANNOT CONFIRM THIS because the scenarios tested previous agent outputs, not full conversation history.
✗ **Unreferenced files** - I CANNOT CONFIRM THIS (test.md mentions this purpose but scenarios didn't explicitly test accessing unreferenced files)

## Why This Matters

**Benefit:** Fresh context every time
- Each agent starts with a clean slate without accumulated state from previous operations
- Provides a consistent starting point for each task
- Ensures predictable behavior since agents aren't affected by conversation history

**Implication:** Must explicitly pass integration context
- Since agents cannot see previous agent outputs, multi-task workflows require explicit context passing
- Files created or modified by previous agents must be referenced using @ syntax
- Example: If Agent A creates analysis.md, Agent B must receive "@analysis.md" to access that work