import unittest
from unittest.mock import Mock, MagicMock
from api.attachment_controller import AttachmentController
from services.attachment_service import AttachmentService
from repositories.attachment_repository import AttachmentRepository
from services.s3_client import S3Client
from services.file_upload_handler import FileUploadHandler
from validators.mime_type_validator import MIMETypeValidator
from validators.file_size_validator import FileSizeValidator
from services.virus_scanning_service import VirusScanningService

class TestIntegration(unittest.TestCase):
    def setUp(self):
        # Create real instances with mocked database
        self.mock_db = Mock()
        self.repository = AttachmentRepository(self.mock_db)
        self.s3_client = S3Client()
        self.file_handler = FileUploadHandler()
        self.mime_validator = MIMETypeValidator()
        self.size_validator = FileSizeValidator()
        self.virus_scanner = VirusScanningService()
        
        self.attachment_service = AttachmentService(
            self.repository,
            self.s3_client,
            self.mime_validator,
            self.size_validator,
            self.virus_scanner
        )
        
        self.controller = AttachmentController(
            self.attachment_service,
            self.repository,
            self.s3_client,
            self.file_handler
        )
    
    def test_complete_upload_workflow(self):
        """Test complete upload workflow from controller to storage"""
        # Mock database cursor with lastrowid = 1
        mock_cursor = Mock()
        mock_cursor.lastrowid = 1
        self.mock_db.execute.return_value = mock_cursor

        # Create request_data with file
        request_data = {
            'file': {
                'filename': 'report.pdf',
                'data': b'%PDF-1.4 test content'
            }
        }

        # Create user dict
        user = {'id': 5}

        # Call controller.upload
        response = self.controller.upload(100, request_data, user)

        # Assert response
        self.assertEqual(response['status'], 201)
        self.assertEqual(response['data']['filename'], 'report.pdf')
        self.assertIn('download_url', response['data'])

        # Assert file exists in s3_client.storage
        s3_key = 'attachments/task-100/report.pdf'
        self.assertIn(s3_key, self.s3_client.storage)
    
    def test_upload_invalid_file_type(self):
        """Test uploading invalid file type"""
        request_data = {
            'file': {
                'filename': 'script.exe',
                'data': b'MZ\x90\x00'
            }
        }
        user = {'id': 5}

        response = self.controller.upload(100, request_data, user)

        self.assertEqual(response['status'], 400)
        self.assertIn('not allowed', response['error'])

    def test_upload_oversized_file(self):
        """Test uploading oversized file"""
        # Create file_data larger than 5MB
        large_data = b'%PDF-1.4' + b'x' * (6 * 1024 * 1024)
        request_data = {
            'file': {
                'filename': 'large.pdf',
                'data': large_data
            }
        }
        user = {'id': 5}

        response = self.controller.upload(100, request_data, user)

        self.assertEqual(response['status'], 400)
        self.assertIn('exceeds maximum', response['error'])

    def test_upload_infected_file(self):
        """Test uploading infected file"""
        request_data = {
            'file': {
                'filename': 'infected.pdf',
                'data': b'%PDF-1.4 this contains VIRUS'
            }
        }
        user = {'id': 5}

        response = self.controller.upload(100, request_data, user)

        self.assertEqual(response['status'], 400)
        self.assertIn('Virus detected', response['error'])

    def test_list_attachments_with_presigned_urls(self):
        """Test listing attachments with presigned URLs"""
        # Mock database cursor.fetchall to return 2 attachment rows
        from datetime import datetime
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = [
            (1, 100, "first.pdf", 1024, "application/pdf",
             "attachments/task-100/first.pdf", 5, datetime.now()),
            (2, 100, "second.png", 2048, "image/png",
             "attachments/task-100/second.png", 6, datetime.now())
        ]
        self.mock_db.execute.return_value = mock_cursor

        user = {'id': 5}
        response = self.controller.list_attachments(100, user)

        self.assertEqual(response['status'], 200)
        self.assertEqual(len(response['data']), 2)
        self.assertIn('download_url', response['data'][0])
        self.assertIn('download_url', response['data'][1])

    def test_delete_attachment_removes_from_storage_and_database(self):
        """Test deleting attachment removes from both storage and database"""
        # Add file to s3_client.storage manually
        s3_key = "attachments/task-100/test.pdf"
        self.s3_client.storage[s3_key] = b'test data'

        # Mock database cursor.fetchone to return attachment row
        from datetime import datetime
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = (
            1, 100, "test.pdf", 1024, "application/pdf",
            s3_key, 5, datetime.now()
        )
        self.mock_db.execute.return_value = mock_cursor

        user = {'id': 5}
        response = self.controller.delete(1, user)

        self.assertEqual(response['status'], 204)
        self.assertNotIn(s3_key, self.s3_client.storage)

    def test_delete_attachment_when_s3_file_missing(self):
        """Test deleting attachment when S3 file is missing"""
        # Mock database to return attachment (but don't add file to S3)
        from datetime import datetime
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = (
            1, 100, "test.pdf", 1024, "application/pdf",
            "attachments/task-100/test.pdf", 5, datetime.now()
        )
        self.mock_db.execute.return_value = mock_cursor

        user = {'id': 5}
        response = self.controller.delete(1, user)

        # Should still succeed
        self.assertEqual(response['status'], 204)

    def test_delete_attachment_not_found(self):
        """Test deleting non-existent attachment"""
        # Mock database to return None
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = None
        self.mock_db.execute.return_value = mock_cursor

        user = {'id': 5}
        response = self.controller.delete(999, user)

        self.assertEqual(response['status'], 404)
        self.assertIn('not found', response['error'])

    def test_delete_attachment_forbidden(self):
        """Test deleting attachment without permission"""
        from datetime import datetime
        mock_cursor = Mock()
        mock_cursor.fetchone.return_value = (
            1, 100, "test.pdf", 1024, "application/pdf",
            "attachments/task-100/test.pdf", 5, datetime.now()
        )
        self.mock_db.execute.return_value = mock_cursor

        # User with different ID and not task owner
        user = {'id': 999, 'is_task_owner': False}
        response = self.controller.delete(1, user)

        self.assertEqual(response['status'], 403)
        self.assertIn('permission', response['error'])

if __name__ == '__main__':
    unittest.main()