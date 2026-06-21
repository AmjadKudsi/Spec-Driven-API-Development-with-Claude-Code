class MIMETypeValidator:
    ALLOWED_TYPES = ['pdf', 'png', 'jpg', 'jpeg', 'docx']

    def validate(self, filename, file_data):
        """Validate file type based on extension and content"""
        # Check if filename has an extension
        if '.' not in filename:
            return {
                'valid': False,
                'error': f"File has no extension. Allowed types: {', '.join(self.ALLOWED_TYPES)}"
            }

        # Extract extension
        extension = filename.rsplit('.', 1)[-1].lower()

        # Check if extension is allowed
        if extension not in self.ALLOWED_TYPES:
            return {
                'valid': False,
                'error': f"File type '{extension}' not allowed. Allowed types: {', '.join(self.ALLOWED_TYPES)}"
            }

        # Verify content matches extension
        if not self._verify_content(extension, file_data):
            return {
                'valid': False,
                'error': f"File content does not match extension '{extension}'"
            }

        return {'valid': True}
    
    def _verify_content(self, extension, file_data):
        # Simple magic byte verification for common types
        if len(file_data) < 4:
            return False
        
        magic_bytes = {
            'pdf': b'%PDF',
            'png': b'\x89PNG',
            'jpg': b'\xff\xd8\xff',
            'jpeg': b'\xff\xd8\xff'
        }
        
        if extension in magic_bytes:
            return file_data.startswith(magic_bytes[extension])
        
        # For types we can't easily verify (like docx), accept them
        return True