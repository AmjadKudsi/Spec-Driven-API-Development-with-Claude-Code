class AttachmentController:
    def __init__(self, attachment_service, attachment_repository, s3_client, file_upload_handler):
        self.attachment_service = attachment_service
        self.repository = attachment_repository
        self.s3_client = s3_client
        self.file_handler = file_upload_handler

    def upload(self, task_id, request_data, user):
        """POST /tasks/{task_id}/attachments"""
        try:
            # Parse uploaded file
            file_info = self.file_handler.parse_upload(request_data)

            # Process upload
            attachment = self.attachment_service.process_upload(
                task_id, file_info['filename'], file_info['file_data'], user['id']
            )

            # Generate presigned URL
            presigned_url = self.s3_client.generate_presigned_url(attachment.s3_key)

            # Return success
            return {
                'status': 201,
                'data': {
                    'id': attachment.id,
                    'task_id': attachment.task_id,
                    'filename': attachment.filename,
                    'file_size': attachment.file_size,
                    'mime_type': attachment.mime_type,
                    's3_key': attachment.s3_key,
                    'uploaded_by': attachment.uploaded_by,
                    'created_at': attachment.created_at,
                    'download_url': presigned_url
                }
            }
        except ValueError as e:
            return {'status': 400, 'error': str(e)}
        except Exception as e:
            return {'status': 500, 'error': f"Upload failed: {str(e)}"}

    def list_attachments(self, task_id, user):
        """GET /tasks/{task_id}/attachments"""
        try:
            # Fetch attachments
            attachments = self.repository.find_by_task_id(task_id)

            # Create attachment list with presigned URLs
            attachment_list = []
            for attachment in attachments:
                presigned_url = self.s3_client.generate_presigned_url(attachment.s3_key)
                attachment_list.append({
                    'id': attachment.id,
                    'task_id': attachment.task_id,
                    'filename': attachment.filename,
                    'file_size': attachment.file_size,
                    'mime_type': attachment.mime_type,
                    's3_key': attachment.s3_key,
                    'uploaded_by': attachment.uploaded_by,
                    'created_at': attachment.created_at,
                    'download_url': presigned_url
                })

            return {'status': 200, 'data': attachment_list}
        except Exception as e:
            return {'status': 500, 'error': f"Failed to list attachments: {str(e)}"}

    def delete(self, attachment_id, user):
        """DELETE /attachments/{attachment_id}"""
        try:
            # Find attachment
            attachment = self.repository.find_by_id(attachment_id)

            # Check if exists
            if attachment is None:
                return {'status': 404, 'error': f"Attachment {attachment_id} not found"}

            # Check permission
            if not self._can_delete(attachment, user):
                return {'status': 403, 'error': "You do not have permission to delete this attachment"}

            # Delete from S3 (best effort)
            try:
                self.s3_client.delete_file(attachment.s3_key)
            except:
                pass  # Continue even if S3 delete fails

            # Delete from database
            self.repository.delete(attachment_id)

            return {'status': 204, 'data': None}
        except Exception as e:
            return {'status': 500, 'error': f"Failed to delete attachment: {str(e)}"}

    def _can_delete(self, attachment, user):
        # User can delete if they are the uploader or task owner
        return user['id'] == attachment.uploaded_by or user.get('is_task_owner', False)