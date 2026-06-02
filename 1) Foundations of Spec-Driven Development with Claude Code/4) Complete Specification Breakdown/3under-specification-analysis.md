# review a flawed data model spec before implementation

# Under-Specification Analysis: User Profile Model

**Student**: Amjad Kudsi
**Date**: 2026-06-02
**Specification Analyzed**: user-profile-model-flawed.md

---

## Instructions

You're about to implement this User Profile model. Review the specification and identify **implementation gaps** — information you need but don't have.

For each gap:
1. Explain what's missing or ambiguous
2. Show how different AI tools might implement it differently
3. Specify what details should be added

**Look for gaps in**:
- Validation rules (patterns, lengths, formats)
- Storage specifications (database schema, types, indexes)
- Field requirements (required/optional, NULL handling)

**Find at least 3 major gaps** in these categories.

---

## Gap #1: Field Validation Rules - No Length or Format Constraints

**Category**: Validation
**Impact**: High

### What AI Would Have to Guess
The spec lists field types (`string`, `text`) but provides no length limits, character patterns, or format requirements. For `display_name`, should it allow spaces, special characters, or emojis? For `avatar_url`, what makes a valid URL? For `bio`, what's the maximum length for a text field? For `location`, any format restrictions?

### How Implementations Would Differ
One AI might implement `display_name` as `VARCHAR(50)` allowing only alphanumeric + underscore, another might use `VARCHAR(255)` allowing spaces and special characters, while a third might use `TEXT` unlimited with emoji support. This leads to incompatible databases where "john_doe", "John Doe", and "john🚀" might be accepted by different systems but rejected by others.

### Required Detail
```
Validation Rules:
- display_name: 3-50 chars, alphanumeric + underscore only, pattern ^[a-zA-Z0-9_]{3,50}$
- avatar_url: Valid HTTPS URL, max 2048 chars, pattern ^https://.*\.(jpg|png|gif|webp)$
- bio: Optional, max 500 chars, plain text
- location: Optional, max 100 chars, plain text
```

---

## Gap #2: Required vs Optional Fields & NULL Handling

**Category**: Requirements
**Impact**: High

### What AI Would Have to Guess
The spec states "Display name required" but doesn't specify other fields. Can `avatar_url`, `bio`, and `location` be NULL? Empty strings? What happens when optional fields are omitted? Is `created_at` auto-generated or client-provided? Should empty strings be converted to NULL or stored as-is?

### How Implementations Would Differ
One AI might default all unspecified fields to NULL and accept empty strings, another might reject empty strings requiring explicit NULL or values, while a third might use empty string `""` as default. Example: Request `{"user_id": "123", "display_name": "john"}` could store `bio` as NULL (AI A), require bio field present (AI B), or default to `""` (AI C).

### Required Detail
```
Field Requirements:
- user_id: Required, must be valid UUID, foreign key to users.id
- display_name: Required, non-empty after trim, unique (case-insensitive)
- avatar_url: Optional, defaults to NULL
- bio: Optional, defaults to NULL, empty string stored as NULL
- location: Optional, defaults to NULL, empty string stored as NULL
- created_at: Auto-generated (NOT NULL, DEFAULT NOW())
```

---

## Gap #3: Database Schema Specifications

**Category**: Storage
**Impact**: High

### What AI Would Have to Guess
No specific SQL data types, column sizes, indexes, or foreign key cascade behavior defined. How is display_name uniqueness enforced (case-sensitive index)? Should there be indexes for performance? Is `updated_at` needed for tracking modifications? What happens to profile when user is deleted?

### How Implementations Would Differ
One AI might create `display_name VARCHAR(255) UNIQUE` with case-sensitive uniqueness, another might use `VARCHAR(50) NOT NULL` with case-insensitive index `LOWER(display_name)`, affecting both storage and query behavior. Foreign key cascade could be CASCADE (auto-delete profile) or RESTRICT (prevent user deletion). Different indexes mean different query performance.

### Required Detail
```sql
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY,
  display_name VARCHAR(50) NOT NULL,
  avatar_url VARCHAR(2048),
  bio VARCHAR(500),
  location VARCHAR(100),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_display_name_unique
  ON user_profiles(LOWER(display_name));
CREATE INDEX idx_created_at
  ON user_profiles(created_at DESC);
```

---

## Summary

**Total Gaps Found**: 3

**Most Critical Gaps**:
1. **Field Validation Rules** - Without length/format specs, different AI tools generate incompatible validation logic, causing production failures when systems interact
2. **Required vs Optional Fields** - Ambiguous NULL handling leads to inconsistent data storage where some systems store NULL, others store empty strings, breaking queries and integrations
3. **Database Schema Details** - Missing schema specifications result in incompatible table structures, different performance characteristics, and different cascade behaviors

### Key Learning
Complete data model specifications must include: (1) exact validation rules with lengths and patterns, (2) explicit required/optional designation with NULL handling, and (3) detailed database schema with types, constraints, and indexes. Without these, AI tools make different assumptions leading to incompatible implementations.

### Why These Gaps Matter
AI code generation tools follow specifications literally but fill gaps with different assumptions. Missing validation details create security risks (unbounded inputs) and interoperability failures. Ambiguous NULL handling causes data consistency issues. Incomplete schema specs result in databases that can't be migrated or integrated. These gaps prevent consistent, production-ready code generation across different AI tools and runs.