class NotificationSystem:
    """
    Integration layer that wires together WebSocket, Redis, and Event publishing.
    This is T010: connecting all three independent tracks.
    """
    
    def __init__(self, websocket_manager, authenticator, lifecycle_handler,
                 redis_client, redis_forwarder, event_publisher,
                 task_integration, comment_integration):
        self.websocket_manager = websocket_manager
        self.authenticator = authenticator
        self.lifecycle_handler = lifecycle_handler
        self.redis_client = redis_client
        self.redis_forwarder = redis_forwarder
        self.event_publisher = event_publisher
        self.task_integration = task_integration
        self.comment_integration = comment_integration
        self.is_running = False
    
    def initialize(self):
        """
        Initialize all components and start the notification system.
        Connects: Track A + Track B + Track C
        """
        if self.is_running:
            return

        self.redis_client.connect()
        self.redis_forwarder.start_forwarding()
        self.task_integration.register_publisher()
        self.comment_integration.register_publisher()

        self.is_running = True
    
    def handle_new_connection(self, user_id, websocket, query_params):
        """
        Handle new WebSocket connection with authentication and subscription.
        Uses: Track A (auth + connection) + Track B (Redis subscription)
        """
        authenticated_user_id = self.authenticator.authenticate(query_params)

        if authenticated_user_id != user_id:
            raise ValueError("Authentication failed: user_id mismatch")

        self.websocket_manager.connect(user_id, websocket)

        channel = f"notifications:{user_id}"
        self.redis_client.subscribe(channel)

        self.lifecycle_handler.on_connect(user_id, websocket)
    
    def handle_disconnection(self, user_id):
        """
        Handle WebSocket disconnection and cleanup.
        Uses: Track A (connection cleanup) + Track B (Redis unsubscribe)
        """
        channel = f"notifications:{user_id}"
        self.redis_client.unsubscribe(channel)

        self.websocket_manager.disconnect(user_id)

        self.lifecycle_handler.on_disconnect(user_id)
    
    def shutdown(self):
        """Clean shutdown of all components."""
        if not self.is_running:
            return
        
        self.redis_forwarder.stop_forwarding()
        self.redis_client.disconnect()
        self.is_running = False