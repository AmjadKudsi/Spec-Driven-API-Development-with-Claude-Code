import unittest
from validators.mime_type_validator import MIMETypeValidator
from validators.file_size_validator import FileSizeValidator
from services.virus_scanning_service import VirusScanningService

class TestMIMETypeValidator(unittest.TestCase):
    def setUp(self):
        self.validator = MIMETypeValidator()

    def test_validate_allowed_pdf(self):
        """Test validating a PDF file with correct magic bytes"""
        result = self.validator.validate("document.pdf", b'%PDF-1.4')
        self.assertTrue(result['valid'])

    def test_validate_allowed_png(self):
        """Test validating a PNG file with correct magic bytes"""
        result = self.validator.validate("image.png", b'\x89PNG')
        self.assertTrue(result['valid'])

    def test_validate_allowed_jpg(self):
        """Test validating a JPG file with correct magic bytes"""
        result = self.validator.validate("photo.jpg", b'\xff\xd8\xff\xe0')
        self.assertTrue(result['valid'])

    def test_validate_disallowed_extension(self):
        """Test rejecting disallowed file extension"""
        result = self.validator.validate("script.exe", b'MZ\x90\x00')
        self.assertFalse(result['valid'])
        self.assertIn('not allowed', result['error'])

    def test_validate_no_extension(self):
        """Test rejecting file with no extension"""
        result = self.validator.validate("noextension", b'data')
        self.assertFalse(result['valid'])
        self.assertIn('no extension', result['error'])

    def test_validate_content_mismatch(self):
        """Test rejecting file with content that doesn't match extension"""
        result = self.validator.validate("fake.pdf", b'\x89PNG')
        self.assertFalse(result['valid'])
        self.assertIn('does not match', result['error'])

    def test_validate_file_too_small(self):
        """Test validating file with less than 4 bytes"""
        result = self.validator.validate("tiny.pdf", b'%PD')
        self.assertFalse(result['valid'])
        self.assertIn('does not match', result['error'])

    def test_validate_docx_file(self):
        """Test validating DOCX file (no magic byte check)"""
        result = self.validator.validate("document.docx", b'PK\x03\x04')
        self.assertTrue(result['valid'])

class TestFileSizeValidator(unittest.TestCase):
    def setUp(self):
        self.validator = FileSizeValidator()

    def test_validate_size_within_limit(self):
        """Test validating file size within limit"""
        result = self.validator.validate(1024)
        self.assertTrue(result['valid'])

    def test_validate_size_at_limit(self):
        """Test validating file size exactly at limit"""
        result = self.validator.validate(5 * 1024 * 1024)
        self.assertTrue(result['valid'])

    def test_validate_size_exceeds_limit(self):
        """Test rejecting file size that exceeds limit"""
        result = self.validator.validate(6 * 1024 * 1024)
        self.assertFalse(result['valid'])
        self.assertIn('exceeds maximum', result['error'])

    def test_validate_zero_size(self):
        """Test validating zero size file"""
        result = self.validator.validate(0)
        self.assertTrue(result['valid'])

class TestVirusScanningService(unittest.TestCase):
    def setUp(self):
        self.scanner = VirusScanningService()

    def test_scan_clean_file(self):
        """Test scanning clean file content"""
        result = self.scanner.scan_file(b'This is clean content')
        self.assertTrue(result['clean'])

    def test_scan_infected_file_with_virus_keyword(self):
        """Test detecting file with VIRUS keyword"""
        result = self.scanner.scan_file(b'This file contains VIRUS')
        self.assertFalse(result['clean'])
        self.assertIn('Virus detected', result['error'])

    def test_scan_infected_file_with_malware_keyword(self):
        """Test detecting file with MALWARE keyword"""
        result = self.scanner.scan_file(b'This file contains MALWARE')
        self.assertFalse(result['clean'])

    def test_scan_empty_file(self):
        """Test scanning empty file"""
        result = self.scanner.scan_file(b'')
        self.assertTrue(result['clean'])

if __name__ == '__main__':
    unittest.main()