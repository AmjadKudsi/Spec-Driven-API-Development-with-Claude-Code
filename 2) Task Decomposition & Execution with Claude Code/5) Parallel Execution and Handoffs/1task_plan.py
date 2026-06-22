class Task:
    def __init__(self, task_id, name, dependencies, estimated_hours):
        self.task_id = task_id
        self.name = name
        self.dependencies = dependencies  # List of task IDs this task depends on
        self.estimated_hours = estimated_hours
    
    def __repr__(self):
        return f"Task({self.task_id}, {self.name}, deps={self.dependencies}, hours={self.estimated_hours})"


class TaskPlan:
    def __init__(self):
        self.tasks = {}
    
    def get_parallel_groups(self):
        """
        Returns a list of task groups that can run in parallel.
        Each group is a list of task IDs that can execute simultaneously.
        """
        completed = set()
        parallel_groups = []
        
        while len(completed) < len(self.tasks):
            ready_tasks = []
            
            for task_id, task in self.tasks.items():
                if task_id not in completed:
                    if self._has_dependencies_met(task, completed):
                        ready_tasks.append(task_id)
            
            if ready_tasks:
                parallel_groups.append(ready_tasks)
                completed.update(ready_tasks)
            else:
                break
        
        return parallel_groups
    
    def calculate_critical_path(self):
        """
        Calculates the minimum calendar time to complete all tasks,
        using earliest-start scheduling.
        
        Key principle: A task starts as soon as ALL its dependencies finish,
        not when an entire "wave" completes.
        """
        finish_times = {}
        scheduled = set()

        while len(scheduled) < len(self.tasks):
            for task_id, task in self.tasks.items():
                if task_id not in scheduled:
                    if all(dep in finish_times for dep in task.dependencies):
                        start_time = max([finish_times[dep] for dep in task.dependencies], default=0)
                        finish_times[task_id] = start_time + task.estimated_hours
                        scheduled.add(task_id)

        return max(finish_times.values()) if finish_times else 0
    
    def add_task(self, task_id, name, dependencies, estimated_hours):
        """Add a task to the plan."""
        task = Task(task_id, name, dependencies, estimated_hours)
        self.tasks[task_id] = task
    
    def _has_dependencies_met(self, task, completed_tasks):
        """Helper method to check if all dependencies of a task are completed."""
        return all(dep_id in completed_tasks for dep_id in task.dependencies)