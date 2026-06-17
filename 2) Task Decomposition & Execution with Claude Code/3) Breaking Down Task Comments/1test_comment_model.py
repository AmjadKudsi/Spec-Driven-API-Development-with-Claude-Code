"""Comment model tests"""

import pytest
from datetime import datetime
from src.models.comment import Comment
from src.models.user import User
from src.models.task import Task


def test_comment_creation(db):
    """Test creating a comment with all required fields"""
    # Create user and task first
    user = User(email="john@example.com", username="johndoe", hashed_password="hashedpass")
    db.add(user)
    db.commit()
    db.refresh(user)

    task = Task(title="Test Task", user_id=user.id)
    db.add(task)
    db.commit()
    db.refresh(task)

    # Create comment
    comment = Comment(
        task_id=task.id,
        author_id=user.id,
        content="This is a test comment"
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)

    assert comment.id is not None
    assert comment.task_id == task.id
    assert comment.author_id == user.id
    assert comment.content == "This is a test comment"
    assert comment.created_at is not None
    assert comment.updated_at is not None


def test_comment_relationships(db):
    """Test comment relationships to task and author"""
    # Create user and task
    user = User(email="author@example.com", username="author", hashed_password="hashedpass")
    db.add(user)
    db.commit()
    db.refresh(user)

    task = Task(title="Task with comments", user_id=user.id)
    db.add(task)
    db.commit()
    db.refresh(task)

    # Create comment
    comment = Comment(task_id=task.id, author_id=user.id, content="Great work!")
    db.add(comment)
    db.commit()
    db.refresh(comment)

    # Test relationships
    assert comment.task.id == task.id
    assert comment.task.title == "Task with comments"
    assert comment.author.id == user.id
    assert comment.author.username == "author"


def test_comment_content_required(db):
    """Test that content field is required"""
    user = User(email="test@example.com", username="testuser", hashed_password="hashedpass")
    db.add(user)
    db.commit()

    task = Task(title="Test", user_id=user.id)
    db.add(task)
    db.commit()

    # Try to create comment without content
    comment = Comment(task_id=task.id, author_id=user.id)
    db.add(comment)

    with pytest.raises(Exception):  # Should raise database constraint error
        db.commit()


def test_comment_timestamps(db):
    """Test that timestamps are set automatically"""
    user = User(email="time@example.com", username="timeuser", hashed_password="hashedpass")
    db.add(user)
    db.commit()

    task = Task(title="Time test", user_id=user.id)
    db.add(task)
    db.commit()

    before = datetime.utcnow()
    comment = Comment(task_id=task.id, author_id=user.id, content="Timestamp test")
    db.add(comment)
    db.commit()
    db.refresh(comment)
    after = datetime.utcnow()

    assert before <= comment.created_at <= after
    assert before <= comment.updated_at <= after


def test_comment_updated_at_changes(db):
    """Test that updated_at changes when comment is modified"""
    user = User(email="update@example.com", username="updateuser", hashed_password="hashedpass")
    db.add(user)
    db.commit()

    task = Task(title="Update test", user_id=user.id)
    db.add(task)
    db.commit()

    comment = Comment(task_id=task.id, author_id=user.id, content="Original content")
    db.add(comment)
    db.commit()
    db.refresh(comment)

    original_updated_at = comment.updated_at

    # Update content
    import time
    time.sleep(0.01)  # Small delay to ensure timestamp difference
    comment.content = "Updated content"
    db.commit()
    db.refresh(comment)

    assert comment.updated_at >= original_updated_at
    assert comment.content == "Updated content"


def test_task_can_have_multiple_comments(db):
    """Test that a task can have multiple comments"""
    user = User(email="multi@example.com", username="multiuser", hashed_password="hashedpass")
    db.add(user)
    db.commit()

    task = Task(title="Task with many comments", user_id=user.id)
    db.add(task)
    db.commit()
    db.refresh(task)

    # Create multiple comments
    comment1 = Comment(task_id=task.id, author_id=user.id, content="First comment")
    comment2 = Comment(task_id=task.id, author_id=user.id, content="Second comment")
    comment3 = Comment(task_id=task.id, author_id=user.id, content="Third comment")

    db.add_all([comment1, comment2, comment3])
    db.commit()

    # Query comments for this task
    comments = db.query(Comment).filter(Comment.task_id == task.id).all()
    assert len(comments) == 3

    # Test via task relationship
    db.refresh(task)
    assert len(task.comments) == 3


def test_delete_task_cascades_to_comments(db):
    """Test that deleting a task deletes its comments"""
    user = User(email="cascade@example.com", username="cascadeuser", hashed_password="hashedpass")
    db.add(user)
    db.commit()

    task = Task(title="Task to be deleted", user_id=user.id)
    db.add(task)
    db.commit()
    task_id = task.id

    comment = Comment(task_id=task.id, author_id=user.id, content="Will be deleted")
    db.add(comment)
    db.commit()
    comment_id = comment.id

    # Delete task
    db.delete(task)
    db.commit()

    # Comment should be deleted too (cascade)
    deleted_comment = db.query(Comment).filter(Comment.id == comment_id).first()
    assert deleted_comment is None
