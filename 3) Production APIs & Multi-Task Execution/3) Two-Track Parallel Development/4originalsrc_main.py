# Task: manually resolve the src/main.py conflict by keeping both feature changes.
# Goal: stage and commit the resolved file, then document what you did in the log.

"""
TaskMaster API - Main application entry point
"""
from fastapi import FastAPI
<<<<<<< HEAD
from src.api.endpoints import tasks, tags
=======
from src.api.endpoints import tasks, reminders
>>>>>>> reminders-feature

app = FastAPI(
    title="TaskMaster API",
    description="Production-ready task management API",
    version="1.0.0"
)

# Register routers
app.include_router(tasks.router, prefix="/api", tags=["tasks"])
<<<<<<< HEAD
app.include_router(tags.router, prefix="/api", tags=["tags"])
=======
app.include_router(reminders.router, prefix="/api", tags=["reminders"])
>>>>>>> reminders-feature


@app.get("/health")
def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}
