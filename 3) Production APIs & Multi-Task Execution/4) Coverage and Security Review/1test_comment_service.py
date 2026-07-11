import pytest
from uuid import uuid4
from src.services.comment_service import CommentService


class TestCommentService:
    """Test suite for CommentService with full edge case coverage."""
    
    def test_create_comment_with_content_exceeding_5000_characters(self):
        """Test that creating a comment with content > 5000 characters raises ValueError."""
        service = CommentService()
        long_content = "a" * 5001

        with pytest.raises(ValueError, match="Comment content cannot exceed 5000 characters"):
            service.create_comment(task_id=1, content=long_content, user_id=1)

    def test_create_comment_with_empty_content(self):
        """Test that creating a comment with empty content raises ValueError."""
        service = CommentService()

        with pytest.raises(ValueError, match="Comment content cannot be empty"):
            service.create_comment(task_id=1, content="", user_id=1)

    def test_create_comment_with_whitespace_only_content(self):
        """Test that creating a comment with whitespace-only content raises ValueError."""
        service = CommentService()

        with pytest.raises(ValueError, match="Comment content cannot be empty"):
            service.create_comment(task_id=1, content="   \n\t  ", user_id=1)

    def test_create_comment_with_invalid_task_id(self):
        """Test that creating a comment with invalid task_id raises ValueError."""
        service = CommentService()

        with pytest.raises(ValueError, match="Invalid task_id"):
            service.create_comment(task_id=0, content="Valid content", user_id=1)

        with pytest.raises(ValueError, match="Invalid task_id"):
            service.create_comment(task_id=-1, content="Valid content", user_id=1)

    def test_update_comment_unauthorized(self):
        """Test that updating another user's comment raises ValueError."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="Original", user_id=1)

        with pytest.raises(ValueError, match="Not authorized to update this comment"):
            service.update_comment(comment.id, "Hacked content", user_id=2)

    def test_delete_comment_unauthorized(self):
        """Test that deleting another user's comment raises ValueError."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="Original", user_id=1)

        with pytest.raises(ValueError, match="Not authorized to delete this comment"):
            service.delete_comment(comment.id, user_id=2)

    def test_get_comments_by_task_with_no_comments(self):
        """Test that getting comments for a task with no comments returns empty list."""
        service = CommentService()
        service.create_comment(task_id=1, content="First comment", user_id=1)
        service.create_comment(task_id=1, content="Second comment", user_id=2)

        comments = service.get_comments_by_task(task_id=2)
        assert comments == []
        assert len(comments) == 0

    def test_update_comment_with_empty_content(self):
        """Test that updating a comment with empty content raises ValueError."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="Original", user_id=1)

        with pytest.raises(ValueError, match="Comment content cannot be empty"):
            service.update_comment(comment.id, "", user_id=1)

    def test_update_comment_with_content_exceeding_5000_characters(self):
        """Test that updating a comment with content > 5000 characters raises ValueError."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="Original", user_id=1)
        long_content = "a" * 5001

        with pytest.raises(ValueError, match="Comment content cannot exceed 5000 characters"):
            service.update_comment(comment.id, long_content, user_id=1)

    def test_update_nonexistent_comment(self):
        """Test that updating a non-existent comment raises ValueError."""
        service = CommentService()
        non_existent_id = uuid4()

        with pytest.raises(ValueError, match="Comment not found"):
            service.update_comment(non_existent_id, "New content", user_id=1)

    # Happy path tests below
    
    def test_create_comment_success(self):
        """Test successful comment creation."""
        service = CommentService()
        comment = service.create_comment(
            task_id=1,
            content="This is a great task!",
            user_id=1
        )
        
        assert comment.content == "This is a great task!"
        assert comment.task_id == 1
        assert comment.user_id == 1
        assert comment.id is not None
    
    def test_get_comments_by_task(self):
        """Test retrieving comments for a specific task."""
        service = CommentService()
        service.create_comment(task_id=1, content="First comment", user_id=1)
        service.create_comment(task_id=1, content="Second comment", user_id=2)
        service.create_comment(task_id=2, content="Different task", user_id=1)
        
        comments = service.get_comments_by_task(task_id=1)
        assert len(comments) == 2
        assert all(c.task_id == 1 for c in comments)
    
    def test_update_comment_success(self):
        """Test successful comment update."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="Original", user_id=1)
        
        updated = service.update_comment(comment.id, "Updated content", user_id=1)
        assert updated.content == "Updated content"
    
    def test_delete_comment_success(self):
        """Test successful comment deletion."""
        service = CommentService()
        comment = service.create_comment(task_id=1, content="To delete", user_id=1)
        
        result = service.delete_comment(comment.id, user_id=1)
        assert result is True
        assert len(service.comments) == 0