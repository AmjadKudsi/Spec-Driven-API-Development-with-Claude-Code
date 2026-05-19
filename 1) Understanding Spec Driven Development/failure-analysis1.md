#You're joining the TaskMaster team. The team has experienced several integration failures in the past month. Your job is to analyze what went wrong and identify what information should have been specified to prevent each failure.
# Complete the analysis template in workspace/unit-1/task-1/failure-analysis.md.

# Integration Failure Analysis

## Instructions

Read each failure case study below. For each failure, list 3-5 specific details that should have been specified to prevent the integration problem.

---

## Failure Case 1: Adding Notification Support

### What Happened

**Developer A (Backend)** implemented comment creation endpoint:
~~~python
@router.post("/api/tasks/{task_id}/comments")
async def create_comment(task_id: UUID, data: CommentCreate, ...):
    comment = Comment(task_id=task_id, ...)
    db.add(comment)
    db.commit()
    
    # Send notification
    await notification_service.send_notification(
        task.owner_id,
        {"type": "new_comment", "comment_id": str(comment.id)}
    )
~~~

**Developer B (Frontend)** implemented notification handler:
~~~javascript
ws.onmessage = (event) => {
  const notification = JSON.parse(event.data);
  
  if (notification.type === "comment_added") {  // Different event name!
    showNotification(notification.data.author, notification.data.preview);
  }
};
~~~

**Result**: Notifications never appeared in UI. Took 2 hours of debugging to find the event name mismatch (`new_comment` vs `comment_added`).

### What Should Have Been Specified?

To prevent this failure, the specification must define:
- The exact notification event name that both backend and frontend must use, such as `comment_added` or `new_comment`.
- The full notification payload structure, including required fields such as `type`, `data`, `comment_id`, `author`, and `preview`.
- Whether notification data should be nested inside a `data` object or sent as top-level fields.
- The expected WebSocket message format, including an example JSON message.
- Required frontend behavior for each notification type, such as showing a toast, updating the task view, or ignoring unknown notification types.

---

## Failure Case 2: Updating Task Status

### What Happened

**Developer A** implemented task update endpoint:
~~~python
@router.put("/api/tasks/{task_id}")
def update_task(task_id: UUID, data: TaskUpdate, ...):
    # Update any field
    if data.status:
        task.status = data.status  # Direct assignment, no validation
    db.commit()
~~~

**Developer B** implemented frontend state machine:
~~~javascript
// Frontend enforces strict transitions
const ALLOWED_TRANSITIONS = {
  'pending': ['in_progress', 'completed'],
  'in_progress': ['completed'],
  'completed': []  // No transitions allowed from completed
};

function updateTaskStatus(taskId, newStatus) {
  if (!ALLOWED_TRANSITIONS[task.status].includes(newStatus)) {
    throw new Error('Invalid status transition');
  }
  api.put(`/tasks/${taskId}`, {status: newStatus});
}
~~~

**Result**: 
- Frontend: User could move task to `in_progress`, then `completed` ✓
- API: User could move task back from `completed` to `pending` via direct API call ✗
- Data inconsistency: Database had completed tasks marked as pending

### What Should Have Been Specified?

To prevent this failure, the specification must define:
- The complete list of valid task statuses, such as `pending`, `in_progress`, and `completed`.
- The allowed status transitions for every status.
- That status transition rules must be enforced by the backend API, not only by the frontend.
- The error response returned when an invalid status transition is attempted, including status code and message.
- Whether completed tasks are final or can be reopened under specific conditions.

---

## Failure Case 3: Implementing Pagination

### What Happened

**Developer A** implemented task listing:
~~~python
@router.get("/api/tasks")
def list_tasks(
    page: int = Query(1, ge=1),  # 1-indexed pagination
    per_page: int = Query(20, ge=1, le=100),
    ...
):
    offset = (page - 1) * per_page
    tasks = query.offset(offset).limit(per_page).all()
    return {"tasks": tasks, "page": page, "total_pages": ceil(total / per_page)}
~~~

**Developer B** implemented frontend:
~~~javascript
// Assumed 0-indexed pagination
function loadTasks(page = 0) {
  fetch(`/api/tasks?page=${page}&per_page=20`)
    .then(res => res.json())
    .then(data => {
      renderTasks(data.tasks);
      renderPagination(data.page, data.total_pages);
    });
}
~~~

**Result**:
- First page load: Requested `page=0`, got `page=1` (worked by accident due to `ge=1` constraint)
- Second page: Requested `page=1`, got same data as first page
- Pagination appeared broken, showing duplicate data

### What Should Have Been Specified?

To prevent this failure, the specification must define:
- Whether pagination is 0-indexed or 1-indexed.
- The default value for `page` and `per_page`.
- The valid minimum and maximum values for pagination parameters.
- The exact response format, including `tasks`, `page`, `per_page`, `total_items`, and `total_pages`.
- How invalid page values should be handled, such as returning a validation error instead of silently changing the value.

---

## Summary

### Common Patterns Across Failures

**What types of information were missing?**

1. Shared contract details between frontend and backend, such as event names, payload structures, and response formats.
2. Business rules that must be enforced consistently, such as valid task status transitions.
3. Parameter rules and conventions, such as whether pagination starts at 0 or 1.

### Key Takeaway

Specifications prevent integration problems by giving every developer the same source of truth. When details are not written down, developers make different assumptions, which can cause mismatched event names, inconsistent validation, and broken API behavior.

### What Makes a Good Specification

Based on these failures, a good specification must:
- ✅ Define exact names, values, and formats that different parts of the system must share.
- ✅ Include request and response examples for API endpoints and WebSocket messages.
- ✅ Specify validation rules and business logic that must be enforced by the backend.
- ✅ Describe how invalid inputs and edge cases should be handled.