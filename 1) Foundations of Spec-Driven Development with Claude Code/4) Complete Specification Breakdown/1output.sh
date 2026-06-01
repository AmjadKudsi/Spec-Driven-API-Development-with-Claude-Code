# use Claude Code to read three completed TaskMaster specs and fill scavenger-hunt.md with factual answers from those specs.
=========================================
📖 Task 1: Spec Scavenger Hunt
=========================================

✅ Scavenger hunt completed!

📊 Your responses:

# Spec Scavenger Hunt

**Student**: Amjad Kudsi
**Date**: 2026-06-01

---

## Instructions

Read the three specifications in the `specs/` directory:
- `specs/user-model-v1.0.md`
- `specs/auth-api-v1.0.md`
- `specs/task-api-v1.0.md`

Answer the questions below by finding information in the specifications. This exercise helps you understand what complete specifications contain before you start evaluating them.

---

## Specification 1: User Model

**Q1: What is the purpose of this model?**
Authenticated user with secure credential storage.

**Q2: What fields are required for creating a user?**
- email: string (unique, lowercase)
- username: string (unique, 3-50 chars)
- password: string (minimum 8 characters, stored as bcrypt hash)

**Q3: How are passwords stored?**
Passwords are hashed using bcrypt with 12 rounds and stored as password_hash.

**Q4: What constraint exists on email and username?**
Both email and username must be unique with case-insensitive uniqueness.

**Q5: Find the set_password() method and describe what it does.**
Hashes and stores the password using bcrypt with 12 rounds.

---

## Specification 2: Authentication API

**Q1: What are the three main endpoints in this API?**
- POST /api/auth/register - Create new user account
- POST /api/auth/login - Authenticate and receive JWT token
- GET /api/auth/me - Get current user info (requires authentication)

**Q2: What information is required to register a new user?**
- email
- username
- password

**Q3: What does the login endpoint return on success?**
A JSON object containing: access_token (JWT token string), token_type ("Bearer"), and expires_in (900 seconds).

**Q4: How long do JWT tokens remain valid?**
15 minutes (900 seconds).

**Q5: What error status code is returned for invalid credentials?**
Not specified in the spec.

---

## Specification 3: Task API

**Q1: What endpoint creates a new task?**
POST /api/tasks

**Q2: What fields are required to create a task?**
The spec shows title, description, priority, and due_date in the example but doesn't explicitly specify which are required vs optional.

**Q3: What status does a new task start with?**
"pending"

**Q4: What query parameters does the GET /api/tasks endpoint accept?**
- status: Filter by status
- priority: Filter by priority
- skip: Pagination offset (default 0)
- limit: Max results (default 50, max 100)

**Q5: What authorization rule applies to all task endpoints?**
All endpoints require authentication and users can only access their own tasks.

---

## Reflection

**What did you notice about these specifications?**
The specifications are concise and follow a consistent structure with clear sections for purpose, fields/endpoints, behavior, and constraints. They include concrete examples with actual request/response JSON, making the expected data format explicit. Each spec focuses on one component (model or API) and provides technical details like data types, validation rules, and security requirements.

**What questions would you have if these specs were missing?**
- What error status codes should be returned for different failure scenarios (invalid credentials, duplicate users, unauthorized access)?
- Which task fields are truly required versus optional when creating a task?
- What exact password hashing algorithm and cost factor should be used?
- What should the JWT token expiration time be?
- Should usernames and emails be case-sensitive or case-insensitive for uniqueness checks?

**How do these specs help with implementation?**
These specs eliminate guesswork by providing exact data types, validation rules, and expected behaviors upfront, allowing developers to write correct code on the first attempt. They serve as a contract between frontend and backend teams, ensuring both sides agree on API structure before any coding begins. The concrete examples make it easy to write tests and validate that the implementation matches requirements.
=========================================
✅ Task 1 Complete!
=========================================

Compare your answers with the specifications to verify accuracy.
Proceed to Task 2 when ready!