import unittest
from unittest.mock import Mock, MagicMock
from datetime import datetime
from repositories.attachment_repository import AttachmentRepository
from models.attachment import Attachment

class TestAttachmentRepository(unittest.TestCase):
    def setUp(self):
        self.mock_db = Mock()
        self.repository = AttachmentRepository(self.mock_db)

    def test_create_attachment(self):
        """Setup mock_cursor with lastrowid = 1 and test create"""
        mock_cursor = Mock()
        mock_cursor.lastrowid = 1
        self.mock_db.execute.return_value = mock_cursor

        attachment = Attachment(
            id=None,
            task_id=100,
            filename="test.pdf",
            file_size=2048,
            mime_type="application/pdf",
            s3_key="attachments/task-100/test.pdf",
            uploaded_by=5,
            created_at=datetime(2024, 1, 15, 10, 30, 0)
        )

        result = self.repository.create(attachment)

        self.mock_db.execute.assert_called_once()
        self.mock_db.commit.assert_called_once()
        self.assertEqual(result.id, 1)

    def test_find_by_id_returns_attachment(self):
        """Setup mock_cursor.fetchone to return attachment data"""
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = (
            1, 100, "report.pdf", 2048, "application/pdf",
            "attachments/task-100/report.pdf", 5, datetime(2024, 1, 15, 10, 30, 0)
        )
        self.mock_db.execute.return_value = mock_cursor

        result = self.repository.find_by_id(1)

        self.assertIsNotNone(result)
        self.assertEqual(result.id, 1)
        self.assertEqual(result.filename, "report.pdf")

    def test_find_by_id_returns_none_when_not_found(self):
        """Setup mock_cursor.fetchone to return None"""
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = None
        self.mock_db.execute.return_value = mock_cursor

        result = self.repository.find_by_id(999)

        self.assertIsNone(result)

    def test_find_by_task_id_returns_list(self):
        """Setup mock_cursor.fetchall to return list of two tuples"""
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = [
            (1, 100, "first.pdf", 1024, "application/pdf",
             "attachments/task-100/first.pdf", 5, datetime(2024, 1, 15, 10, 30, 0)),
            (2, 100, "second.png", 2048, "image/png",
             "attachments/task-100/second.png", 6, datetime(2024, 1, 15, 11, 0, 0))
        ]
        self.mock_db.execute.return_value = mock_cursor

        result = self.repository.find_by_task_id(100)

        self.assertEqual(len(result), 2)
        self.assertEqual(result[0].filename, "first.pdf")
        self.assertEqual(result[1].filename, "second.png")

    def test_find_by_task_id_returns_empty_list(self):
        """Setup mock_cursor.fetchall to return empty list"""
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = []
        self.mock_db.execute.return_value = mock_cursor

        result = self.repository.find_by_task_id(999)

        self.assertEqual(len(result), 0)

    def test_delete_attachment(self):
        """Test delete calls execute and commit"""
        self.repository.delete(1)

        self.mock_db.execute.assert_called_once()
        self.mock_db.commit.assert_called_once()

if __name__ == '__main__':
    unittest.main()