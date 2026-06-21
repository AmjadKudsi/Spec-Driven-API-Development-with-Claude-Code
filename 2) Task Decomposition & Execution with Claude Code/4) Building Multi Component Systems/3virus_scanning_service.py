# This is a mocked virus scanner for CodeSignal environment
# In production, this would integrate with ClamAV or a similar service

class VirusScanningService:
    def scan_file(self, file_data):
        """Scan file for viruses and malware"""
        try:
            # Check for test virus signatures
            if b'VIRUS' in file_data or b'MALWARE' in file_data:
                return {
                    'clean': False,
                    'error': 'Virus detected: File contains malicious content'
                }
            return {'clean': True}
        except Exception as e:
            return {
                'clean': False,
                'error': f'Virus scan failed: {str(e)}'
            }