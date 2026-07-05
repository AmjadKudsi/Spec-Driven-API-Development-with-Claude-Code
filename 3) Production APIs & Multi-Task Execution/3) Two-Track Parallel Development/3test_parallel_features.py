"""Test that tags and reminders work together on the same task"""

from datetime import datetime, timezone, timedelta
from src.repositories.tag_repository import TagRepository
from src.repositories.reminder_repository import ReminderRepository
from src.services.tag_service import TagService
from src.services.reminder_service import ReminderService


def test_tags_and_reminders_coexist(db_session, sample_task, authenticated_user):
    """
    Test that both tags and reminders can be added to the same task
    without conflicts, proving the features are truly independent.
    """
    # Create TagRepository and TagService instances
    tag_repository = TagRepository(db_session)
    tag_service = TagService(tag_repository)

    # Create ReminderRepository and ReminderService instances
    reminder_repository = ReminderRepository(db_session)
    reminder_service = ReminderService(reminder_repository)

    # Task already belongs to authenticated_user (created in fixture)
    task_id = sample_task.id

    # Assign two tags to the task
    tag_service.assign_tag_to_task(task_id, "urgent")
    tag_service.assign_tag_to_task(task_id, "work")

    # Create a future date for the reminder
    future_date = datetime.now(timezone.utc) + timedelta(days=7)

    # Create a reminder for the task
    reminder_service.create_reminder(task_id, future_date, "Complete review by next week")

    # Get all tags for the task
    task_tags = tag_service.get_tags_for_task(task_id)

    # Assert that there are 2 tags
    assert len(task_tags) == 2

    # Assert that "urgent" and "work" are in the tags
    tag_names = [tag.name for tag in task_tags]
    assert "urgent" in tag_names
    assert "work" in tag_names

    # Get all reminders for the task
    task_reminders = reminder_service.get_task_reminders(task_id)

    # Assert that there is 1 reminder
    assert len(task_reminders) == 1

    # Assert that the reminder description matches what we created
    assert task_reminders[0].description == "Complete review by next week"

    # Prove coexistence: both features work independently on the same task
    assert task_tags is not None
    assert task_reminders is not None
    assert len(task_tags) == 2
    assert len(task_reminders) == 1
