class FileSizeValidator:
    MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB in bytes

    def validate(self, file_size):
        """Validate file size is within acceptable limits"""
        if file_size > self.MAX_FILE_SIZE:
            size_mb = file_size / (1024 * 1024)
            max_mb = self.MAX_FILE_SIZE / (1024 * 1024)
            return {
                'valid': False,
                'error': f"File size {size_mb:.2f}MB exceeds maximum {max_mb:.0f}MB"
            }
        return {'valid': True}