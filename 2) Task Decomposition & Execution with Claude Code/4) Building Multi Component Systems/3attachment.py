from datetime import datetime


class Attachment:
    def __init__(self, id, task_id, filename, file_size, mime_type, s3_key, uploaded_by, created_at=None):
        self.id = id
        self.task_id = task_id
        self.filename = filename
        self.file_size = file_size
        self.mime_type = mime_type
        self.s3_key = s3_key
        self.uploaded_by = uploaded_by
        self.created_at = created_at if created_at is not None else datetime.now()