import unittest
from unittest.mock import Mock, MagicMock
from services.attachment_service import AttachmentService
from models.attachment import Attachment

class TestAttachmentService(unittest.TestCase):
    def setUp(self):
        self.mock_repository = Mock()
        self.mock_s3_client = Mock()
        self.mock_mime_validator = Mock()
        self.mock_size_validator = Mock()
        self.mock_virus_scanner = Mock()

        self.service = AttachmentService(
            self.mock_repository,
            self.mock_s3_client,
            self.mock_mime_validator,
            self.mock_size_validator,
            self.mock_virus_scanner
        )

    def test_successful_upload_flow(self):
        """Test successful upload with all validations passing"""
        # Setup all validators to return valid/clean
        self.mock_mime_validator.validate.return_value = {'valid': True}
        self.mock_size_validator.validate.return_value = {'valid': True}
        self.mock_virus_scanner.scan_file.return_value = {'clean': True}

        # Setup S3 and repository
        self.mock_s3_client.upload_file.return_value = True
        mock_attachment = Attachment(1, 100, "test.pdf", 7, "application/pdf",
                                      "attachments/task-100/test.pdf", 5)
        self.mock_repository.create.return_value = mock_attachment

        # Call process_upload
        result = self.service.process_upload(100, "test.pdf", b'content', 5)

        # Assert all validators were called
        self.mock_mime_validator.validate.assert_called_once()
        self.mock_size_validator.validate.assert_called_once()
        self.mock_virus_scanner.scan_file.assert_called_once()

        # Assert S3 upload was called
        self.mock_s3_client.upload_file.assert_called_once()

        # Assert repository create was called
        self.mock_repository.create.assert_called_once()

        # Assert result
        self.assertEqual(result.id, 1)

    def test_upload_fails_mime_validation(self):
        """Test upload fails when MIME validation fails"""
        # Setup mime_validator to return invalid
        self.mock_mime_validator.validate.return_value = {
            'valid': False,
            'error': 'Invalid file type'
        }

        # Assert raises ValueError
        with self.assertRaises(ValueError) as context:
            self.service.process_upload(100, "test.exe", b'content', 5)

        self.assertIn('Invalid file type', str(context.exception))

        # Assert s3_client and repository were NOT called
        self.mock_s3_client.upload_file.assert_not_called()
        self.mock_repository.create.assert_not_called()

    def test_upload_fails_size_validation(self):
        """Test upload fails when size validation fails"""
        # Setup mime_validator to pass, size_validator to fail
        self.mock_mime_validator.validate.return_value = {'valid': True}
        self.mock_size_validator.validate.return_value = {
            'valid': False,
            'error': 'File too large'
        }

        # Assert raises ValueError
        with self.assertRaises(ValueError):
            self.service.process_upload(100, "test.pdf", b'content', 5)

        # Assert s3_client was not called
        self.mock_s3_client.upload_file.assert_not_called()

    def test_upload_fails_virus_scan(self):
        """Test upload fails when virus scan fails"""
        # Setup mime and size validators to pass
        self.mock_mime_validator.validate.return_value = {'valid': True}
        self.mock_size_validator.validate.return_value = {'valid': True}

        # Virus scanner returns not clean
        self.mock_virus_scanner.scan_file.return_value = {
            'clean': False,
            'error': 'Virus detected'
        }

        # Assert raises ValueError
        with self.assertRaises(ValueError):
            self.service.process_upload(100, "test.pdf", b'content', 5)

        # Assert s3_client was not called
        self.mock_s3_client.upload_file.assert_not_called()

    def test_rollback_on_database_failure(self):
        """Test rollback when database save fails"""
        # Setup all validators to pass
        self.mock_mime_validator.validate.return_value = {'valid': True}
        self.mock_size_validator.validate.return_value = {'valid': True}
        self.mock_virus_scanner.scan_file.return_value = {'clean': True}

        # Setup s3_client to succeed
        self.mock_s3_client.upload_file.return_value = True

        # Setup repository to fail
        self.mock_repository.create.side_effect = Exception("Database error")

        # Assert raises Exception
        with self.assertRaises(Exception):
            self.service.process_upload(100, "test.pdf", b'content', 5)

        # Assert s3_client.delete_file was called (rollback)
        self.mock_s3_client.delete_file.assert_called_once()

    def test_upload_fails_s3_upload(self):
        """Test upload fails when S3 upload fails"""
        # Setup all validators to pass
        self.mock_mime_validator.validate.return_value = {'valid': True}
        self.mock_size_validator.validate.return_value = {'valid': True}
        self.mock_virus_scanner.scan_file.return_value = {'clean': True}

        # Setup s3_client to fail
        self.mock_s3_client.upload_file.side_effect = Exception("S3 error")

        # Assert raises Exception
        with self.assertRaises(Exception) as context:
            self.service.process_upload(100, "test.pdf", b'content', 5)

        self.assertIn('Failed to upload file to storage', str(context.exception))

if __name__ == '__main__':
    unittest.main()