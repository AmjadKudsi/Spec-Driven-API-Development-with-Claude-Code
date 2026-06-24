========================================
  Task 2: Bulk Status Updates
========================================


Running tests...
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-8.3.4, pluggy-1.6.0 -- /usr/bin/python
cachedir: .pytest_cache
rootdir: /usercode/FILESYSTEM
configfile: pytest.ini
plugins: asyncio-0.24.0, cov-6.0.0, anyio-4.12.1, typeguard-4.5.1
asyncio: mode=Mode.STRICT, default_loop_scope=function
collecting ... collected 12 items

test_bulk_status_update.py::test_status_transition_validator_valid PASSED [  8%]
test_bulk_status_update.py::test_status_transition_validator_invalid PASSED [ 16%]
test_bulk_status_update.py::test_bulk_ownership_validator_success PASSED [ 25%]
test_bulk_status_update.py::test_bulk_ownership_validator_failure PASSED [ 33%]
test_bulk_status_update.py::test_bulk_validation_service_success PASSED  [ 41%]
test_bulk_status_update.py::test_bulk_validation_service_invalid_transition PASSED [ 50%]
test_bulk_status_update.py::test_bulk_update_repository_success PASSED   [ 58%]
test_bulk_status_update.py::test_bulk_update_repository_rollback PASSED  [ 66%]
test_bulk_status_update.py::test_bulk_update_service_end_to_end PASSED   [ 75%]
test_bulk_status_update.py::test_bulk_update_api_success PASSED          [ 83%]
test_bulk_status_update.py::test_bulk_update_api_validation_error PASSED [ 91%]
test_bulk_status_update.py::test_bulk_update_api_size_validation PASSED  [100%]

============================== 12 passed in 0.02s ==============================

✅ All tests passed!

Your implementation includes:
  - Validation services
  - Atomic transactions
  - Bulk update orchestration
  - API endpoint handling