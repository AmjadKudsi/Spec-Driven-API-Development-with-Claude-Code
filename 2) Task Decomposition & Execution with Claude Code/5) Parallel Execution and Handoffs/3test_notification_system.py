import pytest
import json
from notification_system import NotificationSystem
from websocket_manager import (
    WebSocketConnectionManager,
    WebSocketAuthenticator,
    WebSocketLifecycleHandler
)
from redis_client import (
    RedisPubSubClient,
    UserNotificationChannel,
    RedisToWebSocketForwarder
)
from notification_events import (
    NotificationEvent,
    EventPublisher,
    TaskEventIntegration,
    CommentEventIntegration
)
from mock_dependencies import (
    MockWebSocket,
    MockTaskRepository,
    MockCommentRepository
)


# Track A Tests

def test_connection_manager():
    """Test WebSocket connection management (T001)."""
    manager = WebSocketConnectionManager()
    websocket = MockWebSocket()
    
    manager.connect("user123", websocket)
    assert manager.is_connected("user123")
    assert manager.get_connection("user123") == websocket
    
    manager.disconnect("user123")
    assert not manager.is_connected("user123")


def test_authenticator_valid_token():
    """Test authentication with valid token (T002)."""
    valid_tokens = {"token123": "user123"}
    authenticator = WebSocketAuthenticator(valid_tokens)
    
    user_id = authenticator.authenticate({"token": "token123"})
    assert user_id == "user123"


def test_authenticator_invalid_token():
    """Test authentication with invalid token (T002)."""
    authenticator = WebSocketAuthenticator({})
    
    with pytest.raises(ValueError, match="Invalid authentication token"):
        authenticator.authenticate({"token": "bad_token"})


def test_lifecycle_handlers():
    """Test lifecycle event handlers (T003)."""
    manager = WebSocketConnectionManager()
    handler = WebSocketLifecycleHandler(manager)
    websocket = MockWebSocket()
    
    handler.on_connect("user123", websocket)
    assert len(handler.event_log) == 1
    assert handler.event_log[0]["event"] == "connect"
    
    handler.on_disconnect("user123")
    assert len(handler.event_log) == 2
    assert handler.event_log[1]["event"] == "disconnect"


# Track B Tests

def test_redis_pub_sub():
    """Test Redis publish/subscribe (T004)."""
    redis = RedisPubSubClient()
    redis.connect()
    
    redis.subscribe("test_channel")
    assert "test_channel" in redis.subscribed_channels
    
    redis.publish("test_channel", "test message")
    messages = list(redis.listen())
    assert len(messages) == 1
    assert messages[0]["message"] == "test message"


def test_user_notification_channel():
    """Test user channel management (T005)."""
    redis = RedisPubSubClient()
    redis.connect()
    channel_manager = UserNotificationChannel(redis)
    
    channel_name = channel_manager.get_channel_name("user123")
    assert channel_name == "notifications:user123"
    
    channel_manager.subscribe_to_user("user123")
    assert "notifications:user123" in redis.subscribed_channels


def test_redis_to_websocket_forwarding():
    """Test message forwarding (T006)."""
    redis = RedisPubSubClient()
    ws_manager = WebSocketConnectionManager()
    forwarder = RedisToWebSocketForwarder(redis, ws_manager)
    
    websocket = MockWebSocket()
    ws_manager.connect("user123", websocket)
    
    forwarder.start_forwarding()
    forwarder.forward_message("user123", "test notification")
    
    assert len(websocket.messages) == 1
    assert websocket.messages[0] == "test notification"


# Track C Tests

def test_notification_event_creation():
    """Test event model (T007)."""
    event = NotificationEvent(
        event_type="task_created",
        user_id="user123",
        resource_id="task456",
        message="Task created"
    )
    
    event_dict = event.to_dict()
    assert event_dict["event_type"] == "task_created"
    assert event_dict["user_id"] == "user123"
    assert event_dict["resource_id"] == "task456"
    
    event_json = event.to_json()
    parsed = json.loads(event_json)
    assert parsed["event_type"] == "task_created"


def test_event_publisher():
    """Test event publishing (T008)."""
    redis = RedisPubSubClient()
    redis.connect()
    publisher = EventPublisher(redis)
    
    publisher.publish_task_created("task123", "user456")
    
    assert len(redis.message_queue) == 1
    message = redis.message_queue[0]
    assert message["channel"] == "notifications:user456"
    
    event_data = json.loads(message["message"])
    assert event_data["event_type"] == "task_created"
    assert event_data["resource_id"] == "task123"


def test_task_event_integration():
    """Test task operation hooks (T009 part 1)."""
    redis = RedisPubSubClient()
    redis.connect()
    publisher = EventPublisher(redis)
    task_repo = MockTaskRepository()
    
    integration = TaskEventIntegration(publisher, task_repo)
    integration.register_publisher()
    
    task = task_repo.create_task("task123", "user456", "Test Task")
    integration.on_task_created(task)
    
    assert len(redis.message_queue) == 1
    event_data = json.loads(redis.message_queue[0]["message"])
    assert event_data["event_type"] == "task_created"


def test_comment_event_integration():
    """Test comment operation hooks (T009 part 2)."""
    redis = RedisPubSubClient()
    redis.connect()
    publisher = EventPublisher(redis)
    comment_repo = MockCommentRepository()
    
    integration = CommentEventIntegration(publisher, comment_repo)
    integration.register_publisher()
    
    comment = comment_repo.create_comment("comment123", "task456", "user789", "Great!")
    integration.on_comment_created(comment)
    
    assert len(redis.message_queue) == 1
    event_data = json.loads(redis.message_queue[0]["message"])
    assert event_data["event_type"] == "comment_added"


# Integration Tests

def test_notification_system_initialization():
    """Test system initialization (T010)."""
    # Setup all components
    ws_manager = WebSocketConnectionManager()
    authenticator = WebSocketAuthenticator({"token123": "user123"})
    lifecycle = WebSocketLifecycleHandler(ws_manager)
    redis = RedisPubSubClient()
    forwarder = RedisToWebSocketForwarder(redis, ws_manager)
    publisher = EventPublisher(redis)
    task_repo = MockTaskRepository()
    comment_repo = MockCommentRepository()
    task_integration = TaskEventIntegration(publisher, task_repo)
    comment_integration = CommentEventIntegration(publisher, comment_repo)
    
    system = NotificationSystem(
        ws_manager, authenticator, lifecycle,
        redis, forwarder, publisher,
        task_integration, comment_integration
    )
    
    system.initialize()
    
    assert system.is_running
    assert redis.connected
    assert forwarder.forwarding
    assert task_integration.registered
    assert comment_integration.registered


def test_handle_new_connection():
    """Test connection handling (T010)."""
    ws_manager = WebSocketConnectionManager()
    authenticator = WebSocketAuthenticator({"token123": "user123"})
    lifecycle = WebSocketLifecycleHandler(ws_manager)
    redis = RedisPubSubClient()
    redis.connect()
    forwarder = RedisToWebSocketForwarder(redis, ws_manager)
    publisher = EventPublisher(redis)
    task_repo = MockTaskRepository()
    comment_repo = MockCommentRepository()
    task_integration = TaskEventIntegration(publisher, task_repo)
    comment_integration = CommentEventIntegration(publisher, comment_repo)
    
    system = NotificationSystem(
        ws_manager, authenticator, lifecycle,
        redis, forwarder, publisher,
        task_integration, comment_integration
    )
    
    websocket = MockWebSocket()
    system.handle_new_connection("user123", websocket, {"token": "token123"})
    
    assert ws_manager.is_connected("user123")
    assert "notifications:user123" in redis.subscribed_channels


def test_end_to_end_notification_flow():
    """
    Test complete flow: task created → event published → 
    Redis delivers → WebSocket sends → client receives.
    
    This is T011: validating that all three tracks work together.
    """
    # Setup complete system
    ws_manager = WebSocketConnectionManager()
    authenticator = WebSocketAuthenticator({"token123": "user123"})
    lifecycle = WebSocketLifecycleHandler(ws_manager)
    redis = RedisPubSubClient()
    forwarder = RedisToWebSocketForwarder(redis, ws_manager)
    publisher = EventPublisher(redis)
    task_repo = MockTaskRepository()
    comment_repo = MockCommentRepository()
    task_integration = TaskEventIntegration(publisher, task_repo)
    comment_integration = CommentEventIntegration(publisher, comment_repo)
    
    system = NotificationSystem(
        ws_manager, authenticator, lifecycle,
        redis, forwarder, publisher,
        task_integration, comment_integration
    )
    
    system.initialize()
    
    # Connect a client
    websocket = MockWebSocket()
    system.handle_new_connection("user123", websocket, {"token": "token123"})

    task = task_repo.create_task("task789", "user123", "Important Task")

    task_integration.on_task_created(task)

    assert len(redis.message_queue) == 1

    redis_message = redis.message_queue[0]
    assert redis_message["channel"] == "notifications:user123"

    event_data = json.loads(redis_message["message"])
    assert event_data["event_type"] == "task_created"
    assert event_data["user_id"] == "user123"
    assert event_data["resource_id"] == "task789"
    assert "task789" in event_data["message"]

    forwarder.forward_message("user123", redis_message["message"])

    assert len(websocket.messages) == 1

    received_message = websocket.messages[0]
    received_data = json.loads(received_message)
    assert received_data["event_type"] == "task_created"
    assert received_data["resource_id"] == "task789"


def test_disconnection_cleanup():
    """Test disconnection handling and cleanup (T010)."""
    ws_manager = WebSocketConnectionManager()
    authenticator = WebSocketAuthenticator({"token123": "user123"})
    lifecycle = WebSocketLifecycleHandler(ws_manager)
    redis = RedisPubSubClient()
    redis.connect()
    forwarder = RedisToWebSocketForwarder(redis, ws_manager)
    publisher = EventPublisher(redis)
    task_repo = MockTaskRepository()
    comment_repo = MockCommentRepository()
    task_integration = TaskEventIntegration(publisher, task_repo)
    comment_integration = CommentEventIntegration(publisher, comment_repo)
    
    system = NotificationSystem(
        ws_manager, authenticator, lifecycle,
        redis, forwarder, publisher,
        task_integration, comment_integration
    )
    
    # Connect then disconnect
    websocket = MockWebSocket()
    system.handle_new_connection("user123", websocket, {"token": "token123"})
    system.handle_disconnection("user123")
    
    assert not ws_manager.is_connected("user123")
    assert "notifications:user123" not in redis.subscribed_channels