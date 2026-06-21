import unittest
from datetime import datetime
from models.attachment import Attachment

class TestAttachmentModel(unittest.TestCase):
    def test_create_attachment_with_all_fields(self):
        """Create an Attachment with all fields specified (including created_at)"""
        created_time = datetime(2024, 1, 15, 10, 30, 0)
        attachment = Attachment(
            id=1,
            task_id=100,
            filename="report.pdf",
            file_size=2048,
            mime_type="application/pdf",
            s3_key="attachments/task-100/report.pdf",
            uploaded_by=5,
            created_at=created_time
        )

        self.assertEqual(attachment.id, 1)
        self.assertEqual(attachment.task_id, 100)
        self.assertEqual(attachment.filename, "report.pdf")
        self.assertEqual(attachment.file_size, 2048)
        self.assertEqual(attachment.mime_type, "application/pdf")
        self.assertEqual(attachment.s3_key, "attachments/task-100/report.pdf")
        self.assertEqual(attachment.uploaded_by, 5)
        self.assertEqual(attachment.created_at, created_time)

    def test_create_attachment_with_default_created_at(self):
        """Create Attachment without created_at parameter"""
        before = datetime.now()
        attachment = Attachment(
            id=2,
            task_id=101,
            filename="image.png",
            file_size=1024,
            mime_type="image/png",
            s3_key="attachments/task-101/image.png",
            uploaded_by=6
        )
        after = datetime.now()

        self.assertIsNotNone(attachment.created_at)
        self.assertGreaterEqual(attachment.created_at, before)
        self.assertLessEqual(attachment.created_at, after)

    def test_attachment_fields_are_accessible(self):
        """Create an Attachment and verify all 8 fields exist"""
        attachment = Attachment(
            id=3,
            task_id=102,
            filename="doc.docx",
            file_size=4096,
            mime_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            s3_key="attachments/task-102/doc.docx",
            uploaded_by=7
        )

        self.assertTrue(hasattr(attachment, 'id'))
        self.assertTrue(hasattr(attachment, 'task_id'))
        self.assertTrue(hasattr(attachment, 'filename'))
        self.assertTrue(hasattr(attachment, 'file_size'))
        self.assertTrue(hasattr(attachment, 'mime_type'))
        self.assertTrue(hasattr(attachment, 's3_key'))
        self.assertTrue(hasattr(attachment, 'uploaded_by'))
        self.assertTrue(hasattr(attachment, 'created_at'))

if __name__ == '__main__':
    unittest.main()