class AttachmentService:
    def __init__(self, attachment_repository, s3_client, mime_validator, size_validator, virus_scanner):
        self.repository = attachment_repository
        self.s3_client = s3_client
        self.mime_validator = mime_validator
        self.size_validator = size_validator
        self.virus_scanner = virus_scanner

    def process_upload(self, task_id, filename, file_data, uploaded_by):
        """Orchestrate the complete upload workflow"""
        # Step 1: Validate MIME type
        mime_result = self.mime_validator.validate(filename, file_data)
        if not mime_result['valid']:
            raise ValueError(mime_result['error'])

        # Step 2: Validate file size
        file_size = len(file_data)
        size_result = self.size_validator.validate(file_size)
        if not size_result['valid']:
            raise ValueError(size_result['error'])

        # Step 3: Scan for viruses
        scan_result = self.virus_scanner.scan_file(file_data)
        if not scan_result['clean']:
            raise ValueError(scan_result['error'])

        # Step 4: Upload to S3
        s3_key = f"attachments/task-{task_id}/{filename}"
        try:
            self.s3_client.upload_file(file_data, s3_key)
        except Exception as e:
            raise Exception(f"Failed to upload file to storage: {str(e)}")

        # Step 5: Save metadata to database (with rollback)
        from models.attachment import Attachment
        attachment = Attachment(
            id=None,
            task_id=task_id,
            filename=filename,
            file_size=file_size,
            mime_type=self._get_mime_type(filename),
            s3_key=s3_key,
            uploaded_by=uploaded_by
        )
        try:
            return self.repository.create(attachment)
        except Exception as e:
            # Rollback: delete from S3
            try:
                self.s3_client.delete_file(s3_key)
            except:
                pass  # Best effort rollback
            raise Exception(f"Failed to save attachment metadata: {str(e)}")
    
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