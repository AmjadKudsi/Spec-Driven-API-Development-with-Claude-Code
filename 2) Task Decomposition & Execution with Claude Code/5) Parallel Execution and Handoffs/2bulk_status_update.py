# Complete get_parallel_groups() and calculate_critical_path() in task_plan.py.
# use Claude Code to patch only the TODO logic and verify tests.

class BulkValidationService:
    """Orchestrates validation for bulk status updates."""
    
    def __init__(self, status_validator, ownership_validator, task_repository):
        self.status_validator = status_validator
        self.ownership_validator = ownership_validator
        self.task_repository = task_repository
    
    def validate_bulk_update(self, user_id, task_updates):
        """
        Validate a bulk update request.
        task_updates: list of dicts with 'task_id' and 'new_status'
        
        Depends on: T001 (StatusTransitionValidator), T002 (BulkOwnershipValidator)
        """
        task_ids = [update["task_id"] for update in task_updates]

        self.ownership_validator.validate_ownership(user_id, task_ids)

        for update in task_updates:
            task = self.task_repository.get_task(update["task_id"])
            current_status = task["status"]
            new_status = update["new_status"]
            self.status_validator.validate_transition(current_status, new_status)

        return True


class BulkUpdateRepository:
    """Handles atomic database updates for bulk operations."""
    
    def __init__(self, task_repository):
        self.task_repository = task_repository
    
    def update_tasks_atomically(self, task_updates):
        """
        Update multiple tasks in a single transaction.
        Rolls back all changes if any update fails.
        
        Depends on: Existing TaskRepository
        """
        self.task_repository.begin_transaction()

        try:
            for update in task_updates:
                self.task_repository.update_task(update["task_id"], {"status": update["new_status"]})

            self.task_repository.commit_transaction()
            return True

        except Exception as e:
            self.task_repository.rollback_transaction()
            raise e


class BulkUpdateService:
    """Main service for coordinating bulk status updates."""
    
    def __init__(self, validation_service, update_repository):
        self.validation_service = validation_service
        self.update_repository = update_repository
    
    def execute_bulk_update(self, user_id, task_updates):
        """
        Execute a bulk status update with validation.
        Returns True on success, raises exception on failure.
        
        Depends on: T003 (BulkValidationService), T004 (BulkUpdateRepository)
        """
        self.validation_service.validate_bulk_update(user_id, task_updates)

        self.update_repository.update_tasks_atomically(task_updates)

        return True


class BulkUpdateAPI:
    """API endpoint handler for bulk status updates."""
    
    def __init__(self, bulk_update_service):
        self.bulk_update_service = bulk_update_service
    
    def handle_bulk_status_update(self, request):
        """
        Handle POST /api/tasks/bulk-status-update
        Expected request format:
        {
            "user_id": "user123",
            "updates": [
                {"task_id": "task1", "new_status": "in_progress"},
                {"task_id": "task2", "new_status": "done"}
            ]
        }
        
        Depends on: T005 (BulkUpdateService)
        """
        try:
            user_id = request["user_id"]
            task_updates = request["updates"]

            # Validate request has 2-50 tasks
            if len(task_updates) < 2 or len(task_updates) > 50:
                return {
                    "status": 400,
                    "error": "Bulk update must contain 2-50 tasks"
                }

            self.bulk_update_service.execute_bulk_update(user_id, task_updates)

            return {
                "status": 200,
                "message": f"Successfully updated {len(task_updates)} tasks"
            }
            
        except ValueError as e:
            return {
                "status": 400,
                "error": str(e)
            }
        except Exception as e:
            return {
                "status": 500,
                "error": f"Internal error: {str(e)}"
            }


# These components are already complete (T001 and T002)
# They were built first because they have no dependencies and can run in parallel

class StatusTransitionValidator:
    """Validates if a task can transition from one status to another."""
    
    def __init__(self):
        self.valid_transitions = {
            "todo": ["in_progress"],
            "in_progress": ["done", "todo"],
            "done": ["in_progress"]
        }
    
    def validate_transition(self, current_status, new_status):
        """Check if transition from current_status to new_status is valid."""
        if current_status not in self.valid_transitions:
            raise ValueError(f"Invalid current status: {current_status}")
        
        if new_status not in self.valid_transitions[current_status]:
            raise ValueError(
                f"Cannot transition from '{current_status}' to '{new_status}'"
            )
        
        return True


class BulkOwnershipValidator:
    """Validates if a user owns all tasks in a bulk update."""
    
    def __init__(self, task_repository):
        self.task_repository = task_repository
    
    def validate_ownership(self, user_id, task_ids):
        """Check if user owns all specified tasks."""
        for task_id in task_ids:
            task = self.task_repository.get_task(task_id)
            if not task:
                raise ValueError(f"Task {task_id} does not exist")
            if task["user_id"] != user_id:
                raise ValueError(f"User {user_id} does not own task {task_id}")
        
        return True