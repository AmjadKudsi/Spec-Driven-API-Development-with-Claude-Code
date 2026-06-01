# This task is about finding missing implementation details before writing specs or code.

# Missing Information Analysis

**Student**: Amjad Kudsi
**Date**: 2026-06-01
**Project**: TaskMaster API

---

## Instructions

You're in a planning meeting for TaskMaster. The product manager has described three new features. For each feature, identify at least **3 critical questions** you need answered before you can implement it.

Think about:
- Database schema (how to store data?)
- API endpoints (what HTTP methods and paths?)
- Validation rules (what constraints?)

---

## Feature 1: Task Tags

### Requirements Given
Users should be able to add tags to their tasks for organization. Tags would help categorize tasks by project, client, or topic. Multiple tags can be added to a single task.

### Critical Questions I Would Ask

**1. [Database Schema]: How should tags be stored and what is the relationship model?**
Should tags be in a separate `tags` table with a many-to-many relationship (task_tags junction table), or as an array field on the Task model? Are tags globally shared across all users (so "urgent" created by User A can be reused by User B), or user-specific? What's the primary key if tags are shared?

**2. [Validation Rules]: What are the constraints on tags?**
Maximum number of tags per task? Tag name length limits (e.g., 1-50 chars)? Allowed characters (alphanumeric only, spaces, hyphens)? Are tag names case-sensitive ("Urgent" vs "urgent")? Can duplicate tags exist on the same task?

**3. [API Endpoints]: What operations should be supported and how?**
How to add tags: PUT /api/tasks/{id} with full tag list, or POST /api/tasks/{id}/tags for individual additions? How to remove: DELETE /api/tasks/{id}/tags/{tag_name}? Should there be GET /api/tags for autocomplete? Can tasks be filtered by tags: GET /api/tasks?tags=urgent,work?

### Why These Questions Matter
Without these answers, we risk building a tag system with the wrong data model (requiring expensive migrations later), poor query performance (can't filter by tags efficiently), inconsistent validation (some tags with spaces, others without), or an API design that requires multiple requests for simple operations. The implementation could be fundamentally incompatible with future requirements.

---

## Feature 2: Task Assignment

### Requirements Given
Task owners should be able to assign their tasks to other users. The assigned user would be able to view and update the task. The task owner can reassign to a different user or remove assignment.

### Critical Questions I Would Ask

**1. [Database Schema]: How should assignment be modeled?**
Add a single `assigned_to_id` UUID foreign key to the Task model, or create a separate `task_assignments` table? Can a task be assigned to multiple users simultaneously, or only one at a time? Should `owner_id` and `assigned_to_id` remain distinct, or can ownership transfer?

**2. [Permissions & Authorization]: What exactly can an assigned user do?**
Can assigned user update status, priority, title, description? Can they delete the task or only the owner? Can they add comments, tags, or reassign to others? Can assigned user unassign themselves? Does owner retain all permissions after assignment? The current API spec says "users can only access their own tasks" - how does this change?

**3. [API Endpoints]: How should assignment be managed through the API?**
New endpoint POST /api/tasks/{id}/assign with `{"user_id": "uuid"}`, or PUT /api/tasks/{id} with `{"assigned_to": "uuid"}`? How to unassign: POST /api/tasks/{id}/unassign or PUT with null? Should GET /api/tasks return both owned AND assigned tasks - need filter like `?filter=assigned` vs `?filter=owned`?

### Why These Questions Matter
Assignment fundamentally changes the authorization model of the entire application. Without clear specifications, we could create security vulnerabilities (wrong users accessing tasks), data integrity issues (assignments to non-existent users), or an API that doesn't support actual workflows. We might need to redesign the entire authentication/authorization layer, and the current "users only access own tasks" rule becomes obsolete.

---

## Feature 3: Task History

### Requirements Given
Track all changes made to tasks so users can see the history of updates. This helps with auditing and understanding how tasks evolved over time.

### Critical Questions I Would Ask

**1. [Database Schema]: What data should be tracked and how should it be stored?**
Create a `task_history` table with columns: task_id, field_name, old_value, new_value, changed_by, changed_at? Track every field change (title, description, status, priority, due_date, tags, assignment) or only specific fields? Store as JSON, text, or typed columns? Complete snapshots or just diffs? Does deleting a task cascade delete its history or preserve it?

**2. [API Endpoints]: How should history be accessed and in what format?**
New endpoint GET /api/tasks/{id}/history? Response format: array of `[{field, old_value, new_value, timestamp, changed_by}]`? Should changes be grouped by transaction (one PUT changing multiple fields = one entry or multiple)? Pagination needed with `?limit=50&offset=0`? Filter by field type: `?field=status`?

**3. [Authorization & Implementation]: Who can view history and how is it captured?**
Can only task owner view history, or assigned users too? If reassigned, can new assignee see history from before? Should history be recorded in model's update method, API layer, database triggers, or ORM events? What if logging fails - should the update also fail (transactional) or just log error? Retention period (delete entries older than 1 year)?

### Why These Questions Matter
History data can grow very large and affect storage costs and performance. Without clear specifications on what to track, how to store it, and who can access it, we could build a system that's too slow to query, exposes sensitive data, misses important changes, or runs out of storage. Inconsistent capture mechanisms could result in some changes being tracked while others aren't, making the audit trail unreliable.

---

## Summary

**Total Critical Questions:** 9

**Most Common Missing Information:**
The requirements consistently lack technical implementation details:
1. **Database Schema Design** - No clarity on table structure, relationships, foreign keys, or data types
2. **Authorization & Permissions** - Unclear who can perform what operations, especially for shared resources
3. **API Endpoint Design** - Missing HTTP methods, URL patterns, request/response formats, query parameters
4. **Validation Rules & Constraints** - No specified limits, allowed values, or edge case handling
5. **Data Format & Representation** - How complex types (arrays, nulls, enums) should be stored and displayed

### Key Learning
User stories describe **what users want to do** ("add tags to tasks"), but specifications must define **how the system implements it** (database schema, API design, validation). The gap is significant: a 2-sentence user story can require answering 20+ technical questions before implementation. Vague verbs like "track," "assign," and "add" hide enormous complexity that developers must uncover through detailed questions.

### Next Steps
Before writing code, I would: (1) Schedule a requirements clarification session with the product manager to get answers to all critical questions, (2) Create detailed technical specifications with database ERD diagrams, API endpoint specs with examples, and authorization matrices, (3) Review specs with the team to validate feasibility, (4) Write failing tests that encode expected behavior, then implement to make them pass.