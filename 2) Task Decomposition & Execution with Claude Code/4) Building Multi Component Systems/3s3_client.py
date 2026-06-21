# This is a mocked S3 client for CodeSignal environment
# In production, this would use boto3 to communicate with AWS S3

class S3Client:
    def __init__(self):
        self.storage = {}  # Mock storage for testing

    def upload_file(self, file_data, s3_key):
        """Simulate file upload to S3 by storing in self.storage dictionary"""
        try:
            print(f"Uploading file to S3: {s3_key}")
            self.storage[s3_key] = file_data
            return True
        except Exception as e:
            raise Exception(f"Failed to upload file to S3: {str(e)}")

    def delete_file(self, s3_key):
        """Simulate file deletion from S3"""
        try:
            if s3_key in self.storage:
                del self.storage[s3_key]
            print(f"Deleting file from S3: {s3_key}")
            return True
        except Exception as e:
            raise Exception(f"Failed to delete file from S3: {str(e)}")

    def generate_presigned_url(self, s3_key, expiration=3600):
        """Generate a mock presigned URL string using the s3_key"""
        return f"https://s3.amazonaws.com/taskmaster-attachments/{s3_key}?token=mock_token&expires={expiration}"