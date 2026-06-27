# Test Scenarios

## Scenario 1: Just instruction
Command: Task(context-reporter): "Report your context"

Result:
CLAUDE.md visible: yes - Successfully accessed the project constitution file containing coding standards.
Files via @imports:
- none
Instruction received: Report your context.
Previous agent outputs visible: no - No previous agent outputs were visible.

## Scenario 2: With files
Command: Task(context-reporter): "Report your context. @specs/test.md"

Result:
CLAUDE.md visible: yes - The project constitution with coding standards was visible.
Files via @imports:
- /usercode/FILESYSTEM/specs/test.md
Instruction received: Report your context. @specs/test.md.
Previous agent outputs visible: no - The agent could not see outputs from the previous context-reporter invocation.

## Scenario 3: With integration reference
Command: Task(context-reporter): "Report your context. Use @src/model.py"

Result:
CLAUDE.md visible: yes - The project coding standards were accessible.
Files via @imports:
- /usercode/FILESYSTEM/src/model.py
Instruction received: Report your context. Use @src/model.py.
Previous agent outputs visible: no - The agent could not see outputs from previous context-reporter invocations.