========================================
  Task 3: File Attachment System
========================================

✅ Repository
✅ S3 client
✅ Service
✅ API controller

📊 Components implemented: 5/5

Running integration tests...
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-8.3.4, pluggy-1.6.0 -- /usr/bin/python
cachedir: .pytest_cache
rootdir: /usercode/FILESYSTEM/workspace/unit-4/task-3
plugins: asyncio-0.24.0, cov-6.0.0, anyio-4.12.1, typeguard-4.5.1
asyncio: mode=Mode.STRICT, default_loop_scope=None
collecting ... collected 9 items

tests/test_integration.py::TestIntegration::test_complete_upload_workflow PASSED [ 11%]
tests/test_integration.py::TestIntegration::test_delete_attachment_forbidden PASSED [ 22%]
tests/test_integration.py::TestIntegration::test_delete_attachment_not_found PASSED [ 33%]
tests/test_integration.py::TestIntegration::test_delete_attachment_removes_from_storage_and_database PASSED [ 44%]
tests/test_integration.py::TestIntegration::test_delete_attachment_when_s3_file_missing PASSED [ 55%]
tests/test_integration.py::TestIntegration::test_list_attachments_with_presigned_urls PASSED [ 66%]
tests/test_integration.py::TestIntegration::test_upload_infected_file PASSED [ 77%]
tests/test_integration.py::TestIntegration::test_upload_invalid_file_type PASSED [ 88%]
tests/test_integration.py::TestIntegration::test_upload_oversized_file PASSED [100%]

============================== 9 passed in 0.03s ===============================
✅ Execution log found

✅ File attachment system complete!