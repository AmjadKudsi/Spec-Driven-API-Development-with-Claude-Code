
╭─── Claude Code v2.0.42 ────────────────────────────────────────────────────────────────────────────────╮
│                                    │ Tips for getting started                                          │
│            Welcome back!           │ Run /init to create a CLAUDE.md file with instructions for Claude │
│                                    │ ───────────────────────────────────────────────────────────────── │
│               ▐▛███▜▌              │ Recent activity                                                   │
│              ▝▜█████▛▘             │ No recent activity                                                │
│                ▘▘ ▝▝               │                                                                   │
│                                    │                                                                   │
│   Sonnet 4.5 · API Usage Billing   │                                                                   │
│        /usercode/FILESYSTEM        │                                                                   │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────╯

> Read docs/prds/task-comments-v1.0.md and specs/task-comments/specification.md. Compare them across 
content, audience, lifecycle, detail level, integration context, and long-term value. Do not edit 
files yet. Give me a concise summary first. 

● I'll read both files and compare them for you.

● Read(docs/prds/task-comments-v1.0.md)
  ⎿  Read 274 lines

● Read(specs/task-comments/specification.md)
  ⎿  Read 655 lines

● Comparison Summary: PRD vs Specification

  Content:
  - PRD (task-comments-v1.0.md): Focuses on the "why" - problem statement, user personas, success
  metrics, user research (62% use Slack, 15-20 min/day context switching), business constraints, and
  scope decisions
  - Specification (specification.md): Focuses on the "how" - exact API contracts, HTTP status codes,
  data models with field types, validation logic, error handling, code examples, and implementation
  details

  Audience:
  - PRD: Product managers, stakeholders, business teams - communicates value, ROI, and user impact
  - Specification: Developers, QA engineers - provides technical blueprint for implementation and
  testing

  Lifecycle:
  - PRD: Created first (2024-01-10, Status: Approved) - drives decision-making and secures buy-in
  - Specification: Created after PRD approval (2024-01-12, explicitly references "Source PRD") -
  consumed during active development

  Detail Level:
  - PRD: High-level requirements with acceptance criteria ("users can add comments", "p95 <200ms") and
   business constraints ("no rich text in v1.0")
  - Specification: Granular technical details (exact JSON schemas, SQLAlchemy model code, Pydantic
  validators, 5000-char limits, CASCADE delete behavior, index definitions)

  Integration Context:
  - PRD: Names patterns to follow ("repository pattern per CLAUDE.md", "FastAPI/PostgreSQL stack")
  - Specification: Shows exact code to write (relationship("Comment", back_populates="task"), specific
   validator functions, Alembic migration script)

  Long-term Value:
  - PRD: Enduring reference for the feature's rationale, success criteria, and future iterations (v2.0
   considerations listed)
  - Specification: Implementation guide that serves as technical documentation; can become stale if
  code diverges, but valuable for maintenance and onboarding

  Key Relationship: The PRD is the "contract" defining what to build and why; the specification is the
   "blueprint" showing exactly how to build it. They're complementary: PRD → approval/planning,
  Specification → implementation/testing.

> Now fill prd-vs-spec-analysis.md using the existing template. Keep it concise and focused on the 
basic goals of the exercise. 

● I'll read the template file first to see its structure.

● Read(prd-vs-spec-analysis.md)
  ⎿  Error reading file

● Let me search for the template file in the filesystem.

● Search(pattern: "**/prd-vs-spec-analysis.md")
  ⎿  Found 1 file (ctrl+o to expand)

● Read(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Read 146 lines

● Now I'll fill in the template with concise, focused analysis.

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 2 additions and 2 removals
       1    # PRD vs Specification Analysis: Task Comments
       2    
       3 -  **Student**: [Your Name]  
       4 -  **Date**: [Date]  
       3 +  **Student**: Analysis Complete
       4 +  **Date**: 2026-05-28  
       5    **Documents Analyzed:**
       6    - PRD: docs/prds/task-comments-v1.0.md
       7    - Spec: specs/task-comments/specification.md

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 12 additions and 4 removals     
       12    
       13    ### What's in PRD but NOT in Spec
       14    
       15 -  [List specific content from PRD that doesn't appear in Spec]
       15 +  The PRD contains strategic and business context absent from the Spec:
       16    
       17    **Business Context:**
       18 -  - [What business information is in PRD only?]
       18 +  - Problem statement with user pain points (62% use Slack for task discussions, 15-20 
          + min/day lost to context switching)
       19 +  - User personas (Task Owner managing 10-30 tasks, Task Collaborator)
       20 +  - User research data (n=120 survey, 45% difficulty finding historical discussions)
       21 +  - Competitive analysis (Asana, Trello, Jira comparisons)
       22    
       23    **Success Metrics:**
       24 -  - [What metrics are in PRD only?]
       24 +  - Adoption: 80% of teams use comments within first week
       25 +  - Usage: Average 3 comments per task, 50% of users add ≥1 comment weekly
       26 +  - Quality: <5% spam reports, <2% quick deletions
       27 +  - Performance targets tied to business goals
       28    
       29    **Out of Scope:**
       30 -  - [What exclusions are documented in PRD?]
       30 +  - Explicit v1.0 exclusions with rationale (no rich text, attachments, threading, 
          + @mentions, editing)
       31 +  - Future roadmap considerations for v2.0
       32 +  - Timeline and effort estimates (1.5 weeks total)
       33    
       34    ---
       35    

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 14 additions and 4 removals     
       35    
       36    ### What's in Spec but NOT in PRD
       37    
       38 -  [List specific content from Spec that doesn't appear in PRD]
       38 +  The Spec contains implementation-level technical details:
       39    
       40    **API Details:**
       41 -  - [What exact API information is in Spec only?]
       41 +  - Complete HTTP request/response examples with exact JSON schemas
       42 +  - Specific status codes (201 Created, 204 No Content) and error response formats
       43 +  - Full endpoint definitions (`POST /api/tasks/{task_id}/comments`, `DELETE 
          + /api/comments/{comment_id}`)
       44 +  - Authorization check ordering (JWT → resource exists → permissions)
       45    
       46    **Validation Rules:**
       47 -  - [What specific validation rules are in Spec only?]
       47 +  - Precise content trimming logic (strip whitespace, then check empty)
       48 +  - Exact character limits (5000 chars) with validation ordering
       49 +  - Specific error messages ("Content cannot be empty", "Content must not exceed 5000 
          + characters")
       50 +  - Edge case handling (concurrent creation, deleted tasks, empty lists)
       51    
       52    **Implementation Patterns:**
       53 -  - [What implementation guidance is in Spec only?]
       53 +  - Complete SQLAlchemy model code with field types, foreign keys, CASCADE behavior
       54 +  - Pydantic schema definitions with validators
       55 +  - Repository method signatures (`create()`, `get_by_id()`, `delete()`)
       56 +  - Alembic migration script (up/down) with index definitions
       57 +  - Complete test suite requirements (12 specific test names, 95%/90% coverage targets)
       58    
       59    ---
       60    

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 10 additions and 2 removals     
       62    
       63    ### Who Reads the PRD and Why
       64    
       65 -  [For each audience, explain what they need and why]
       65 +  - **Product Managers**: Need to understand user problems and validate feature solves 
          + them (62% using Slack = clear pain point)
       66 +  - **Engineering Managers**: Need effort estimates (1.5 weeks) and scope clarity to 
          + plan sprints
       67 +  - **Stakeholders/Executives**: Need success metrics (80% adoption target) to approve 
          + resource allocation
       68 +  - **Designers**: Need user personas and pain points to design appropriate UX
       69 +  - **Future Teams**: Need to understand original rationale when considering v2.0 
          + features (why no threading in v1.0?)
       70    
       71    ---
       72    
       73    ### Who Reads the Spec and Why
       74    
       75 -  [For each audience, explain what they need and why]
       75 +  - **Backend Developers**: Need exact API contracts and data models to implement 
          + endpoints
       76 +  - **Frontend Developers**: Need request/response schemas to build UI and API calls
       77 +  - **QA Engineers**: Need validation rules and edge cases to write test plans (12 
          + specific test scenarios listed)
       78 +  - **DevOps**: Need migration scripts to deploy database changes safely
       79 +  - **Code Reviewers**: Need implementation patterns to verify code follows repository 
          + pattern and auth standards
       80    
       81    ---
       82    

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 16 additions and 3 removals      
        84    
        85    ### Why PRD Lives Permanently
        86    
        87 -  [Explain reasons for PRD persistence]
        87 +  - **Historical Context**: 6 months later, teams need to understand WHY decisions were
           +  made (why no @mentions? Because notifications system didn't exist)
        88 +  - **Future Planning**: When planning v2.0, need to reference original success metrics
           +  and user research to measure impact
        89 +  - **Onboarding**: New team members learn product strategy and rationale, not just 
           + implementation details
        90 +  - **Scope Justification**: When stakeholders ask "why didn't we include X?", PRD 
           + documents the conscious decision
        91    
        92    ---
        93    
        94    ### Why Spec Gets Archived After Implementation
        95    
        96 -  [Explain reasons for spec archival]
        96 +  - **Code is Truth**: Once implemented, the actual codebase becomes the source of 
           + truth, not the spec
        97 +  - **Divergence Risk**: Specs become outdated as code evolves (bug fixes, refactoring)
           +  without doc updates
        98 +  - **Maintenance Burden**: Keeping specs in sync with code requires double work for 
           + every change
        99 +  - **Better Alternatives**: API documentation (OpenAPI/Swagger), code comments, and 
           + type definitions serve as living documentation
       100    
       101    ---
       102    
       103    ### What Happens If Requirements Change
       104    
       105 -  [Walk through the process of handling a requirement change 6 months later]
       105 +  **Scenario**: 6 months later, product decides to add comment editing feature.
       106    
       107 +  1. **Reference PRD**: Check original Out of Scope section - editing was excluded to 
           + "simplify audit trail"
       108 +  2. **Update PRD**: Add new user story, update success metrics, document why editing 
           + is now needed
       109 +  3. **Create New Spec**: Write new spec for editing feature (API endpoint, edit 
           + history model, 5-min window constraint)
       110 +  4. **Implementation**: Follow new spec, code review against patterns
       111 +  5. **Archive Updated Spec**: After deployment, spec archived; code and tests become 
           + reference
       112 +  6. **PRD Remains**: Original PRD + amendment preserves full decision history
       113 +  
       114    ---
       115    
       116    ## Part 4: Detail Level Comparison

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 20 additions and 4 removals  
       118    ### PRD Specificity
       119    
       120    **What PRD Specifies:**
       121 -  [List types of information in PRD]
       121 +  - User goals and acceptance criteria ("comment shows my name and timestamp")
       122 +  - Performance targets (p95 <200ms, <100ms)
       123 +  - Business constraints (no rich text, plain text only)
       124 +  - High-level features (add, view, delete comments)
       125 +  - Access control principles (only users with task access)
       126    
       127    **What PRD Doesn't Specify:**
       128 -  [List types of information NOT in PRD]
       128 +  - HTTP methods or status codes
       129 +  - Database schema or field types
       130 +  - Exact validation logic or error messages
       131 +  - Code structure or implementation patterns
       132 +  - Specific test cases or coverage percentages
       133    
       134    ---
       135    
       136    ### Spec Specificity
       137    
       138    **What Spec Specifies:**
       139 -  [List types of information in Spec]
       139 +  - Exact HTTP endpoints (`POST /api/tasks/{task_id}/comments`)
       140 +  - Database columns with types (`content: TEXT, nullable=False`)
       141 +  - Validation sequences (trim → check empty → check length)
       142 +  - Precise error responses (`{"detail": "Content cannot be empty"}`)
       143 +  - Implementation code (SQLAlchemy models, Pydantic validators, migration scripts)
       144    
       145    **What Spec Doesn't Specify:**
       146 -  [List types of information NOT in Spec]
       146 +  - Why the feature exists or user pain points
       147 +  - Business success criteria or adoption targets
       148 +  - Competitive landscape or market research
       149 +  - Future feature roadmap or v2.0 considerations
       150 +  - Effort estimates or project timeline
       151    
       152    ---
       153    

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 15 additions and 2 removals      
       155    
       156    ### How PRD References Existing Code
       157    
       158 -  [Analyze how PRD talks about TaskMaster integration]
       158 +  **High-Level References:**
       159 +  - Names patterns to follow: "repository pattern per CLAUDE.md", "FastAPI/PostgreSQL 
           + stack"
       160 +  - References existing models: "extends Task model (src/models/task.py)", "References 
           + User model"
       161 +  - Identifies integration points: "JWT authentication", "TaskMaster authentication"
       162 +  - States constraints: "Must integrate with existing Task model", "Must use 
           + get_current_user"
       163    
       164 +  **Approach**: PRD establishes integration requirements without dictating 
           + implementation details.
       165 +  
       166    ---
       167    
       168    ### How Spec References Existing Code
       169    
       170 -  [Analyze how Spec talks about TaskMaster integration]
       170 +  **Concrete Implementation:**
       171 +  - Shows exact code to add: `comments = relationship("Comment", back_populates="task",
           +  cascade="all, delete-orphan")`
       172 +  - Imports specific functions: `from src.services.auth import get_current_user`
       173 +  - Follows existing patterns: "Follow `src/repositories/task_repository.py` as 
           + example"
       174 +  - Provides method signatures: `create(task_id, user_id, content) -> Comment`
       175 +  - Shows dependency injection: `def __init__(self, db: Session = Depends(get_db))`
       176    
       177 +  **Approach**: Spec shows exactly how to integrate with existing code, providing 
           + copy-paste examples.
       178 +  
       179    ---
       180    
       181    ## Part 6: Key Question Answer

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 15 additions and 6 removals      
       182    
       183    ### "If I Only Kept ONE Document Forever, Which Should It Be?"
       184    
       185 -  **Answer:** [PRD or Spec?]
       185 +  **Answer:** PRD
       186    
       187    **Reasoning:**
       188 -  [Explain your choice with specific reasons]
       188 +  1. **Code Replaces Spec**: The actual implementation (API endpoints, models, tests) 
           + becomes the living documentation
       189 +  2. **Context is Irreplaceable**: User research, decision rationale, and business 
           + context cannot be reconstructed from code
       190 +  3. **Long-term Value**: Teams need to understand WHY (PRD) more than HOW (Spec) as 
           + they evolve the feature
       191 +  4. **Onboarding**: New engineers can read code to understand implementation, but need
           +  PRD to understand purpose
       192    
       193 -  **What We Lose Without [Other Document]:**
       194 -  [What information would be missing?]
       193 +  **What We Lose Without the Spec:**
       194 +  - Initial implementation blueprint (slows first development)
       195 +  - Explicit validation logic and edge cases (discoverable through code review)
       196 +  - Test case names and coverage targets (can derive from requirements)
       197 +  - Migration scripts (can regenerate from model changes)
       198    
       199 -  **What We Lose Without [Your Choice]:**
       200 -  [What IRREPLACEABLE information would be lost?]
       199 +  **What We Lose Without the PRD:**
       200 +  - Why the feature exists (62% using Slack, 15-20 min/day lost)
       201 +  - Original success metrics (how to measure if it worked)
       202 +  - Conscious scope decisions (why no threading? why no editing?)
       203 +  - User research and competitive analysis (IRREPLACEABLE context)
       204    
       205    ---
       206    

● Update(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Updated workspace/unit-3/task-1/prd-vs-spec-analysis.md with 31 additions and 4 removals      
       208    
       209    ### What Makes PRD and Spec Different
       210    
       211 -  [Create comparison table]
       211 +  | Dimension | PRD | Spec |
       212 +  |-----------|-----|------|
       213 +  | **Focus** | WHY and WHAT | HOW |
       214 +  | **Audience** | Product, business, stakeholders | Engineers, QA, DevOps |
       215 +  | **Detail Level** | High-level requirements, constraints | Implementation code, 
           + schemas |
       216 +  | **Lifecycle** | Lives permanently | Archived after deployment |
       217 +  | **Content** | User research, metrics, scope | API contracts, validation, tests |
       218 +  | **Value Over Time** | Increases (historical context) | Decreases (code becomes 
           + truth) |
       219    
       220    ### Why This Distinction Matters
       221    
       222 -  [Explain practical implications]
       222 +  **For Engineering Teams:**
       223 +  - Prevents over-documenting implementation details that will become stale
       224 +  - Clarifies that code review matters more than spec compliance long-term
       225    
       226 +  **For Product Teams:**
       227 +  - Ensures business context survives engineer turnover
       228 +  - Enables data-driven iteration by preserving original metrics
       229 +  
       230 +  **For Organizations:**
       231 +  - Reduces documentation maintenance burden (archive specs, keep PRDs)
       232 +  - Improves cross-functional communication (right doc for right audience)
       233 +  
       234    ### Common Mistakes to Avoid
       235    
       236 -  [List misconceptions about PRD vs Spec]
       236 +  1. **Writing PRDs like Specs**: Including API endpoints, database schemas, or code 
           + examples in PRD (too prescriptive)
       237 +  2. **Writing Specs like PRDs**: Including user research, business justification, or 
           + success metrics in Spec (wrong audience)
       238 +  3. **Maintaining Specs Forever**: Keeping specs updated with code changes wastes 
           + time; code is truth
       239 +  4. **Skipping PRDs**: Going straight to spec loses critical context for future 
           + decisions
       240 +  5. **Using Same Document for Both**: Combined PRD/Spec serves neither audience well
       241    
       242    ### Personal Reflection
       243    
       244 -  [What was most surprising? Most valuable? How will you apply this?]
       244   \ No newline at end of file
       245 +  The most valuable insight is that **different documents serve different lifecycles**.
           +  The Spec is a construction blueprint—critical during building, but once the building 
           + exists, you don't need the blueprint to understand or modify it. The PRD is the 
           + historical record—explaining why the building was needed, who it serves, and what 
           + success looks like.
       246 +  
       247 +  This distinction will help me:
       248 +  - Write PRDs focused on business value and user problems (not implementation)
       249 +  - Write specs as disposable guides for initial implementation
       250 +  - Resist the urge to keep specs in sync with code after deployment
       251 +  - Always preserve the "why" behind decisions for future teams
       252   \ No newline at end of file

● Done! I've filled in workspace/unit-3/task-1/prd-vs-spec-analysis.md with a concise comparison
  across all 7 sections:

  Key findings:
  - PRD = WHY/WHAT (user research, metrics, scope decisions) → lives permanently
  - Spec = HOW (API contracts, code, validation) → archived after deployment

  Most important insight: If you could only keep one document forever, keep the PRD. The code becomes
  the spec's replacement, but user research and decision context (why no threading? why 5000 char
  limit?) is irreplaceable.

  The analysis covers content differences, audiences, lifecycles, detail levels, integration
  approaches, and practical implications—all focused on the core learning objective of understanding
  when and why to write each type of document.

> Show me the completed analysis and check that it satisfies the README success criteria. 

● I'll read the completed analysis and the README to verify it meets the success criteria.

● Read(workspace/unit-3/task-1/prd-vs-spec-analysis.md)
  ⎿  Read 250 lines

● Read(workspace/unit-3/task-1/README.md)
  ⎿  Read 47 lines

● Completed Analysis

  Here's your completed analysis (250 lines):

  ---
  PRD vs Specification Analysis: Task Comments

  Student: Analysis Complete
  Date: 2026-05-28
  Documents Analyzed:
  - PRD: docs/prds/task-comments-v1.0.md
  - Spec: specs/task-comments/specification.md

  ---
  Part 1: Content Comparison

  What's in PRD but NOT in Spec

  The PRD contains strategic and business context absent from the Spec:

  Business Context:
  - Problem statement with user pain points (62% use Slack for task discussions, 15-20 min/day lost to
   context switching)
  - User personas (Task Owner managing 10-30 tasks, Task Collaborator)
  - User research data (n=120 survey, 45% difficulty finding historical discussions)
  - Competitive analysis (Asana, Trello, Jira comparisons)

  Success Metrics:
  - Adoption: 80% of teams use comments within first week
  - Usage: Average 3 comments per task, 50% of users add ≥1 comment weekly
  - Quality: <5% spam reports, <2% quick deletions
  - Performance targets tied to business goals

  Out of Scope:
  - Explicit v1.0 exclusions with rationale (no rich text, attachments, threading, @mentions, editing)
  - Future roadmap considerations for v2.0
  - Timeline and effort estimates (1.5 weeks total)

  What's in Spec but NOT in PRD

  The Spec contains implementation-level technical details:

  API Details:
  - Complete HTTP request/response examples with exact JSON schemas
  - Specific status codes (201 Created, 204 No Content) and error response formats
  - Full endpoint definitions (POST /api/tasks/{task_id}/comments, DELETE /api/comments/{comment_id})
  - Authorization check ordering (JWT → resource exists → permissions)

  Validation Rules:
  - Precise content trimming logic (strip whitespace, then check empty)
  - Exact character limits (5000 chars) with validation ordering
  - Specific error messages ("Content cannot be empty", "Content must not exceed 5000 characters")
  - Edge case handling (concurrent creation, deleted tasks, empty lists)

  Implementation Patterns:
  - Complete SQLAlchemy model code with field types, foreign keys, CASCADE behavior
  - Pydantic schema definitions with validators
  - Repository method signatures (create(), get_by_id(), delete())
  - Alembic migration script (up/down) with index definitions
  - Complete test suite requirements (12 specific test names, 95%/90% coverage targets)

  ---
  ✅ Success Criteria Check

  Let me verify against the README criteria:

  | Criterion                               | Status | Evidence
                                        |
  |-----------------------------------------|--------|------------------------------------------------
  --------------------------------------|
  | Identified specific content differences | ✅      | Part 1 lists concrete examples (62% Slack
  usage, 5000 char limit, SQLAlchemy models) |
  | Analyzed audience needs                 | ✅      | Part 2 identifies 5 PRD audiences + 5 Spec
  audiences with specific needs             |
  | Explained persistence vs archival       | ✅      | Part 3 provides 4 reasons for PRD permanence,
  4 for Spec archival + change scenario  |
  | Compared specificity with examples      | ✅      | Part 4 contrasts "comment shows timestamp" vs
  POST /api/tasks/{task_id}/comments     |
  | Analyzed integration patterns           | ✅      | Part 5 shows PRD names patterns, Spec provides
   copy-paste code                       |
  | Answered key question with reasoning    | ✅      | Part 6 answers "PRD" with 4 reasons +
  irreplaceable context argument                 |
  | Summarized key learnings                | ✅      | Part 7 has comparison table, practical
  implications, 5 common mistakes, reflection   |

  All 7 criteria satisfied! ✅

  ---
  Key Insights from Analysis

  The Core Distinction:
  - PRD = Why it exists (user research, business metrics) → Lives forever
  - Spec = How to build it (code, schemas, validation) → Archived after deployment

  The Building Analogy:
  The Spec is like architectural blueprints—critical during construction but unnecessary once the
  building exists. The PRD is the historical record—why we built it, who uses it, what success looks
  like. Code can replace blueprints, but nothing replaces the "why."

  Critical Answer to "Which to Keep?"
  Keep the PRD. User research (62% using Slack), decision rationale (why no threading?), and success
  metrics (80% adoption) cannot be reconstructed from code. Implementation details can be read from
  the actual codebase.

  The analysis demonstrates clear understanding of document lifecycles, audiences, and the fundamental
   principle: preserve context, not implementation.

──────────────────────────────────────────────────────────────────────────────────────────────────────────
>  
──────────────────────────────────────────────────────────────────────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle)
