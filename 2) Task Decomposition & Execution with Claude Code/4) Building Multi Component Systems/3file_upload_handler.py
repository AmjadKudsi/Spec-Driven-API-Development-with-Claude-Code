class FileUploadHandler:
    def parse_upload(self, request_data):
        """Parse multipart/form-data request and extract file information"""
        if 'file' not in request_data:
            raise ValueError("No file provided in request")

        file_obj = request_data['file']
        filename = file_obj.get('filename', 'unnamed')
        file_data = file_obj.get('data', b'')
        file_size = len(file_data)
        mime_type = self._get_mime_type(filename)

        return {
            'filename': filename,
            'file_data': file_data,
            'file_size': file_size,
            'mime_type': mime_type
        }

    def _get_mime_type(self, filename):
        extension = filename.rsplit('.', 1)[-1].lower()
        mime_types = {
            'pdf': 'application/pdf',
            'png': 'image/png',
            'jpg': 'image/jpeg',
            'jpeg': 'image/jpeg',
            'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        }
        return mime_types.get(extension, 'application/octet-stream')