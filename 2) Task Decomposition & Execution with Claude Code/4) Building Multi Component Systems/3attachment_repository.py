class AttachmentRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def create(self, attachment):
        """Insert attachment into database and return the attachment with its new ID"""
        query = """
            INSERT INTO attachments (task_id, filename, file_size, mime_type, s3_key, uploaded_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        cursor = self.db.execute(
            query,
            (attachment.task_id, attachment.filename, attachment.file_size,
             attachment.mime_type, attachment.s3_key, attachment.uploaded_by,
             attachment.created_at)
        )
        attachment.id = cursor.lastrowid
        self.db.commit()
        return attachment

    def find_by_id(self, attachment_id):
        """Query database for attachment with given ID"""
        query = "SELECT id, task_id, filename, file_size, mime_type, s3_key, uploaded_by, created_at FROM attachments WHERE id = ?"
        cursor = self.db.execute(query, (attachment_id,))
        row = cursor.fetchone()
        if row is None:
            return None
        return self._row_to_attachment(row)

    def find_by_task_id(self, task_id):
        """Query database for all attachments with given task_id"""
        query = "SELECT id, task_id, filename, file_size, mime_type, s3_key, uploaded_by, created_at FROM attachments WHERE task_id = ?"
        cursor = self.db.execute(query, (task_id,))
        rows = cursor.fetchall()
        return [self._row_to_attachment(row) for row in rows]

    def delete(self, attachment_id):
        """Remove attachment from database by ID"""
        query = "DELETE FROM attachments WHERE id = ?"
        self.db.execute(query, (attachment_id,))
        self.db.commit()
    
    def _row_to_attachment(self, row):
        from models.attachment import Attachment
        return Attachment(
            id=row[0],
            task_id=row[1],
            filename=row[2],
            file_size=row[3],
            mime_type=row[4],
            s3_key=row[5],
            uploaded_by=row[6],
            created_at=row[7]
        )