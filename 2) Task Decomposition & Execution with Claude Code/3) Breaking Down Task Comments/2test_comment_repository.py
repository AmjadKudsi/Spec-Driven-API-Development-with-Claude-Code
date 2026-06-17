"""Unit tests for CommentRepository - T002"""

import pytest
from unittest.mock import Mock
from src.repositories.comment_repository import CommentRepository
from src.models.comment import Comment


class TestCommentRepository:
    """Test suite for T002 CommentRepository"""

    def test_create_comment(self):
        """Test creating a new comment"""
        # Arrange
        mock_db = Mock()
        task_id = 1
        author_id = 1
        content = "Test comment content"

        # Act
        result = CommentRepository.create_comment(mock_db, task_id, author_id, content)

        # Assert
        mock_db.add.assert_called_once()
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once()

        # Verify the comment object was created with correct attributes
        added_comment = mock_db.add.call_args[0][0]
        assert isinstance(added_comment, Comment)
        assert added_comment.task_id == task_id
        assert added_comment.user_id == author_id
        assert added_comment.content == content

    def test_get_by_id_found(self):
        """Test getting a comment by ID when it exists"""
        # Arrange
        mock_db = Mock()
        mock_query = Mock()
        mock_filter = Mock()
        comment_id = 1
        expected_comment = Comment(id=comment_id, task_id=1, user_id=1, content="Test")

        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.first.return_value = expected_comment

        # Act
        result = CommentRepository.get_by_id(mock_db, comment_id)

        # Assert
        mock_db.query.assert_called_once_with(Comment)
        assert result == expected_comment

    def test_get_by_id_not_found(self):
        """Test getting a comment by ID when it doesn't exist"""
        # Arrange
        mock_db = Mock()
        mock_query = Mock()
        mock_filter = Mock()
        comment_id = 999

        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.first.return_value = None

        # Act
        result = CommentRepository.get_by_id(mock_db, comment_id)

        # Assert
        assert result is None

    def test_get_task_comments(self):
        """Test getting all comments for a task"""
        # Arrange
        mock_db = Mock()
        mock_query = Mock()
        mock_filter = Mock()
        mock_order = Mock()

        task_id = 1
        expected_comments = [
            Comment(id=1, task_id=task_id, user_id=1, content="Comment 1"),
            Comment(id=2, task_id=task_id, user_id=1, content="Comment 2")
        ]

        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.order_by.return_value = mock_order
        mock_order.all.return_value = expected_comments

        # Act
        result = CommentRepository.get_task_comments(mock_db, task_id)

        # Assert
        mock_db.query.assert_called_once_with(Comment)
        assert result == expected_comments

    def test_get_task_comments_empty(self):
        """Test getting comments for a task with no comments"""
        # Arrange
        mock_db = Mock()
        mock_query = Mock()
        mock_filter = Mock()
        mock_order = Mock()
        task_id = 1

        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.order_by.return_value = mock_order
        mock_order.all.return_value = []

        # Act
        result = CommentRepository.get_task_comments(mock_db, task_id)

        # Assert
        assert result == []

    def test_delete_comment(self):
        """Test deleting a comment"""
        # Arrange
        mock_db = Mock()
        comment_id = 1
        existing_comment = Comment(id=comment_id, task_id=1, user_id=1, content="To delete")

        mock_query = Mock()
        mock_filter = Mock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.first.return_value = existing_comment

        # Act
        result = CommentRepository.delete_comment(mock_db, comment_id)

        # Assert
        mock_db.delete.assert_called_once_with(existing_comment)
        mock_db.commit.assert_called_once()
        assert result is True

    def test_delete_comment_not_found(self):
        """Test deleting a comment that doesn't exist"""
        # Arrange
        mock_db = Mock()
        comment_id = 999

        mock_query = Mock()
        mock_filter = Mock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_filter
        mock_filter.first.return_value = None

        # Act
        result = CommentRepository.delete_comment(mock_db, comment_id)

        # Assert
        assert result is False
        mock_db.delete.assert_not_called()
        mock_db.commit.assert_not_called()
