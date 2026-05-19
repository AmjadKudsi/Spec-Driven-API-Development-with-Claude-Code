#
#

# Ambiguity Analysis: TaskMaster Features

**Student**: [Your Name]  
**Date**: 2026-05-19

---

## Instructions

Read each feature requirement. Identify 2-3 vague terms that would cause different developers to make different assumptions.

For each ambiguous term:
- Quote the exact phrase
- Explain what's unclear
- Show how different developers might interpret it differently
- Suggest specific language that removes the ambiguity

---

## Feature 1: Task Tags

### Requirements Given

"Users can add tags to their tasks for organization. Tags help categorize tasks by project, client, or topic."

### Ambiguous Terms Found

**1. "add tags"**
- **What's unclear:** It does not specify how many tags a task can have, whether users create new tags, or whether tags come from a predefined list.
- **Why it matters:** One developer might allow unlimited custom tags, while another might only allow selecting from existing tags.
- **Needs specification:** Users can add up to 10 custom tags per task. Tags are created by typing a new tag name or selecting an existing tag.

**2. "their tasks"**
- **What's unclear:** It does not define whether users can tag only tasks they created, tasks assigned to them, or tasks they can view.
- **Why it matters:** One developer might allow tagging any visible task, while another might restrict tagging to task owners only.
- **Needs specification:** Users can add, edit, or remove tags only on tasks they own or tasks assigned to them.

**3. "project, client, or topic"**
- **What's unclear:** It is unclear whether these are examples of free text tags or required tag categories.
- **Why it matters:** One developer might build one generic tag field, while another might build separate fields for project, client, and topic.
- **Needs specification:** Tags are free text labels. Project, client, and topic are examples only and are not separate required fields.

---

## Feature 2: Task Priority

### Requirements Given

"Tasks should have priority levels so users can indicate which tasks are most important."

### Ambiguous Terms Found

**1. "priority levels"**
- **What's unclear:** It does not define the number, names, or order of priority levels.
- **Why it matters:** One developer might use Low, Medium, High, while another might use numbers 1 through 5.
- **Needs specification:** Tasks support exactly three priority levels: Low, Medium, and High.

**2. "most important"**
- **What's unclear:** It does not explain how importance should affect sorting, filtering, display, or notifications.
- **Why it matters:** One developer might only store the priority value, while another might automatically sort high priority tasks first.
- **Needs specification:** Priority is used for display and filtering only. It does not automatically change due dates, notifications, or task order unless the user sorts by priority.

**3. "Tasks should have"**
- **What's unclear:** It does not specify whether priority is required or optional, or what default value should be used.
- **Why it matters:** One developer might require users to choose a priority, while another might allow tasks with no priority.
- **Needs specification:** Every task must have a priority. New tasks default to Medium unless the user selects another value.

---

## Feature 3: Task Search

### Requirements Given

"Users need to be able to search for tasks to quickly find what they're looking for."

### Ambiguous Terms Found

**1. "search for tasks"**
- **What's unclear:** It does not specify which task fields are searchable.
- **Why it matters:** One developer might search only task titles, while another might search titles, descriptions, tags, and comments.
- **Needs specification:** Search matches task title, description, and tags. Comments are not included in search results.

**2. "quickly find"**
- **What's unclear:** It does not define performance expectations or when results should appear.
- **Why it matters:** One developer might search only after pressing Enter, while another might implement live search after each keystroke.
- **Needs specification:** Search runs when the user presses Enter or clicks Search. Results must return within 500 milliseconds for workspaces with up to 10,000 tasks.

**3. "what they're looking for"**
- **What's unclear:** It does not define matching behavior, such as exact match, partial match, case sensitivity, or typo handling.
- **Why it matters:** One developer might require exact matches, while another might support partial and case-insensitive matching.
- **Needs specification:** Search is case-insensitive and supports partial matches on searchable fields. Typo correction is not required.

---

## Summary

**Total Ambiguous Terms Found:** 9

**Most Common Types of Ambiguity:**
The most common ambiguity involved limits, ownership rules, default values, searchable fields, matching behavior, and whether examples were requirements or just suggestions.

### Key Learning
Requirements can sound clear in normal conversation but still leave important implementation details undefined. A requirement is specific enough when two developers would make the same decisions about data fields, limits, validation, defaults, and user behavior.

### Pattern for Clarification
When requirements are vague, ask what exact values are allowed, who can perform the action, what limits apply, what defaults are used, what edge cases exist, and how the system should behave when input is invalid.