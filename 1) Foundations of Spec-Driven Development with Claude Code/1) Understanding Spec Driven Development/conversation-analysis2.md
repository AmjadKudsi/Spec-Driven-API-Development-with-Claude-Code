# You're reviewing three Slack conversations from the TaskMaster team about upcoming features. Each conversation shows different communication patterns.
# Identify which conversations reveal a need for formal specification before coding begins.
# For each conversation, decide if a formal spec is needed and explain your reasoning.

# Conversation Analysis: When to Write Specs

---

## Instructions

Read three Slack conversations. For each, decide if a formal spec is needed before coding, and explain why using the patterns from Lesson 1.

---

## Conversation 1: Button Styling Update

### Slack Thread

**Designer (Emma):** Hey team, we're updating all primary action buttons to the new brand blue (#3B82F6) per the redesign guidelines.

**Frontend Dev (Alex):** Got it! Any other changes besides color?

**Designer:** Nope, just the blue for primary buttons. Border radius stays 8px, padding unchanged.

**Frontend Dev:** Perfect. I'll update the button component CSS. Should have it on staging in 30 minutes.

**Designer:** Thanks! I'll review on staging.

[30 minutes later]

**Frontend Dev:** Deployed to staging. Check button-redesign branch.

**Designer:** Looks great! Approved for production.

**PM (Sarah):** Deployed to prod. Thanks team! ✅

### Your Analysis

**Needs spec before coding?**
- [ ] Yes
- [x] No

**Why? (2-3 sentences)**

A formal spec is not needed because the change is small, visual, and clearly defined. The team agreed on the exact color, confirmed no other styling changes were needed, and validated the result on staging before release.

**Key patterns I noticed:**
- Clear scope with one specific change
- Low ambiguity and fast feedback loop

---

## Conversation 2: Task Filtering Enhancement

### Slack Thread

**PM (Sarah):** We need better task filtering. Users want to filter by multiple criteria at once.

**Backend Dev (Marcus):** What filters specifically?

**PM:** Like... date ranges, multiple statuses, multiple priorities.

**Backend Dev:** Ok so GET /api/tasks with multiple query params?

**Frontend Dev (Lisa):** How do multiple values work? Like status=pending&status=completed?

**Backend Dev:** Or comma-separated? status=pending,completed?

**PM:** Whatever is standard.

**Frontend Dev:** What if someone picks all three statuses? Just return everything?

**PM:** I guess? Or maybe that's an edge case.

**Backend Dev:** Should we AND or OR the filters?

**Frontend Dev:** What does that mean?

**Backend Dev:** Like if they filter status=pending AND priority=1, do we need tasks that are BOTH, or tasks that match EITHER condition?

**PM:** Both I think. If you set multiple filters they should narrow results.

**Frontend Dev:** What about date ranges? Exact format?

**Backend Dev:** ISO 8601 for dates?

**PM:** Sure, sounds good.

**Backend Dev:** What if start_date > end_date?

**PM:** Return error I guess.

**Frontend Dev:** What error? What status code?

**Backend Dev:** 400? 422?

**PM:** Not sure, what's standard?

**Frontend Dev:** What about pagination? Default page size?

**Backend Dev:** 50 items? 100?

**PM:** Whatever performs well.

[Thread continues with more questions...]

### Your Analysis

**Needs spec before coding?**
- [x] Yes
- [ ] No

**Why? (2-3 sentences)**

A formal spec is needed because the team has not agreed on request format, filter logic, validation rules, or pagination behavior. Without a written contract, the frontend and backend could easily implement different assumptions and create integration failures.

**Key patterns I noticed:**
- Multiple unresolved API contract questions
- Vague answers like "whatever is standard"
- Edge cases and validation behavior are undefined

---

## Conversation 3: Email Notification System

### Slack Thread

**PM (Sarah):** We need email notifications when tasks are assigned or updated.

**Backend Dev (Marcus):** What triggers emails?

**PM:** Task assignment and status changes.

**Backend Dev:** Send immediately or batch them?

**PM:** What do you think?

**Backend Dev:** Immediate might be too many emails.

**Frontend Dev (Lisa):** Can users control what notifications they get?

**PM:** Yeah, good idea. Notification preferences.

**Backend Dev:** So we need a preferences UI and API?

**Frontend Dev:** What's the default? All on or all off?

**PM:** Probably all on to start.

**Backend Dev:** What email service? SendGrid? AWS SES?

**PM:** We have SendGrid account.

**Backend Dev:** What's the "from" address?

**PM:** notifications@taskmaster.com I guess?

**Backend Dev:** Do we need email templates?

**PM:** Yes, they should look professional.

**Frontend Dev:** Who designs templates?

**Designer (Emma):** I can do that but need spec first. What data goes in email?

**Backend Dev:** What if email fails to send?

**PM:** Retry I suppose.

**Backend Dev:** How many times? With what backoff?

**Frontend Dev:** What if user's email bounces?

**PM:** Mark their account somehow?

**Backend Dev:** Disable notifications for that user?

**Frontend Dev:** Or disable whole account?

**PM:** I don't know, let me check with legal.

[Thread continues with more questions...]

### Your Analysis

**Needs spec before coding?**
- [x] Yes
- [ ] No

**Why? (2-3 sentences)**

A formal spec is needed because this feature affects backend behavior, frontend preferences, email templates, third-party services, retries, and possible legal concerns. The team is still deciding core requirements, so coding now would likely produce mismatched behavior and rework.

**Key patterns I noticed:**
- Cross-functional feature with backend, frontend, design, and legal impact
- Core business rules are still undecided
- Failure handling and user preferences are undefined

---

## Summary

**My decisions:**
- Conversation 1: NO spec needed
- Conversation 2: YES spec needed
- Conversation 3: YES spec needed

**When specs ARE needed, I saw these patterns:**
1. Many unresolved questions about behavior, data formats, or edge cases
2. Multiple teams or systems depending on the same shared contract
3. Vague decisions that could lead developers to make different assumptions

**When specs can be SKIPPED, I saw these patterns:**
1. The change is small and low risk
2. The expected behavior is already clear and agreed on
3. The work can be quickly verified before release

**Key takeaway:** Specs are needed when a conversation shows ambiguity, shared contracts, or important edge cases that must be resolved before implementation. They can be skipped for small, clear changes where everyone already agrees on the exact behavior and the risk of integration failure is low.