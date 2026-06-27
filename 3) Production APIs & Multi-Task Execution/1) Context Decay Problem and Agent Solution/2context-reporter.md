---
name: context-reporter
description: Reports what context it received
tools: Read, Glob, Grep
---

Report what context you have access to.

Answer these four questions:
1. Does the agent see CLAUDE.md? Answer yes or no, and mention evidence.
2. What files were given via @imports? List only files explicitly referenced in the instruction.
3. What was the instruction? Summarize the user instruction you received.
4. Does the agent see previous agent outputs? Answer yes or no, and mention evidence.

Format exactly:
CLAUDE.md visible: yes/no plus evidence
Files via @imports:
- file path or none
Instruction received: one sentence
Previous agent outputs visible: yes/no plus evidence
