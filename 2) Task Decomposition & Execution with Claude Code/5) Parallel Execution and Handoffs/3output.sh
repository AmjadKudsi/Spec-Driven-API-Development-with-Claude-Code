========================================
  Task 3: Real-Time Notifications
========================================


Running tests...
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-8.3.4, pluggy-1.6.0 -- /usr/bin/python
cachedir: .pytest_cache
rootdir: /usercode/FILESYSTEM
configfile: pytest.ini
plugins: asyncio-0.24.0, cov-6.0.0, anyio-4.12.1, typeguard-4.5.1
asyncio: mode=Mode.STRICT, default_loop_scope=function
collecting ... collected 15 items

test_notification_system.py::test_connection_manager PASSED              [  6%]
test_notification_system.py::test_authenticator_valid_token PASSED       [ 13%]
test_notification_system.py::test_authenticator_invalid_token PASSED     [ 20%]
test_notification_system.py::test_lifecycle_handlers PASSED              [ 26%]
test_notification_system.py::test_redis_pub_sub PASSED                   [ 33%]
test_notification_system.py::test_user_notification_channel PASSED       [ 40%]
test_notification_system.py::test_redis_to_websocket_forwarding PASSED   [ 46%]
test_notification_system.py::test_notification_event_creation PASSED     [ 53%]
test_notification_system.py::test_event_publisher PASSED                 [ 60%]
test_notification_system.py::test_task_event_integration PASSED          [ 66%]
test_notification_system.py::test_comment_event_integration PASSED       [ 73%]
test_notification_system.py::test_notification_system_initialization PASSED [ 80%]
test_notification_system.py::test_handle_new_connection PASSED           [ 86%]
test_notification_system.py::test_end_to_end_notification_flow PASSED    [ 93%]
test_notification_system.py::test_disconnection_cleanup PASSED           [100%]

============================== 15 passed in 0.02s ==============================

✅ All tests passed!

Your implementation successfully:
  - Integrates WebSocket infrastructure
  - Connects Redis pub/sub
  - Hooks event publishing
  - Validates end-to-end flow

🎉 Congratulations on completing the course!