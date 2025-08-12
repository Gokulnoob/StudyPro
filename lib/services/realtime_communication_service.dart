import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';

class RealTimeCommunicationService {
  static RealTimeCommunicationService? _instance;
  static RealTimeCommunicationService get instance =>
      _instance ??= RealTimeCommunicationService._();

  RealTimeCommunicationService._();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentUserName;

  // Stream controllers for real-time events
  final _messagesController = StreamController<ChatMessage>.broadcast();
  final _whiteboardController = StreamController<WhiteboardStroke>.broadcast();
  final _memberActivityController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _callEventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<ChatMessage> get messagesStream => _messagesController.stream;
  Stream<WhiteboardStroke> get whiteboardStream => _whiteboardController.stream;
  Stream<Map<String, dynamic>> get memberActivityStream =>
      _memberActivityController.stream;
  Stream<Map<String, dynamic>> get callEventsStream =>
      _callEventsController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  bool get isConnected => _isConnected;

  // Initialize connection
  Future<void> initialize({
    required String userId,
    required String userName,
    String serverUrl = 'http://localhost:3000', // Replace with your server URL
  }) async {
    try {
      _currentUserId = userId;
      _currentUserName = userName;

      _socket = IO.io(
          serverUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setExtraHeaders({'userId': userId, 'userName': userName})
              .enableAutoConnect()
              .build());

      _setupEventHandlers();

      // Wait for connection
      final completer = Completer<void>();
      _socket!.onConnect((_) {
        _isConnected = true;
        log('Connected to real-time server');
        if (!completer.isCompleted) completer.complete();
      });

      _socket!.onConnectError((error) {
        log('Connection error: $error');
        if (!completer.isCompleted) completer.completeError(error);
      });

      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
    } catch (e) {
      log('Error initializing real-time communication: $e');
      // Use mock service for development
      _initializeMockService();
    }
  }

  void _setupEventHandlers() {
    _socket!.onDisconnect((_) {
      _isConnected = false;
      log('Disconnected from real-time server');
    });

    // Message events
    _socket!.on('new_message', (data) {
      try {
        final message = ChatMessage.fromJson(data);
        _messagesController.add(message);
      } catch (e) {
        log('Error parsing message: $e');
      }
    });

    // Whiteboard events
    _socket!.on('whiteboard_stroke', (data) {
      try {
        final stroke = WhiteboardStroke.fromJson(data);
        _whiteboardController.add(stroke);
      } catch (e) {
        log('Error parsing whiteboard stroke: $e');
      }
    });

    // Member activity events
    _socket!.on('member_activity', (data) {
      _memberActivityController.add(Map<String, dynamic>.from(data));
    });

    // Call events
    _socket!.on('call_event', (data) {
      _callEventsController.add(Map<String, dynamic>.from(data));
    });

    // Typing indicators
    _socket!.on('typing', (data) {
      _typingController.add(Map<String, dynamic>.from(data));
    });
  }

  // Join a study group room
  Future<void> joinStudyGroup(String studyGroupId) async {
    if (_socket?.connected == true) {
      _socket!.emit('join_group', {'groupId': studyGroupId});
      log('Joined study group: $studyGroupId');
    }
  }

  // Leave a study group room
  Future<void> leaveStudyGroup(String studyGroupId) async {
    if (_socket?.connected == true) {
      _socket!.emit('leave_group', {'groupId': studyGroupId});
      log('Left study group: $studyGroupId');
    }
  }

  // Send a chat message
  Future<void> sendMessage(ChatMessage message) async {
    if (_socket?.connected == true) {
      _socket!.emit('send_message', message.toJson());
    } else {
      // Add to mock stream for development
      _messagesController.add(message);
    }
  }

  // Send typing indicator
  void sendTypingIndicator(String studyGroupId, bool isTyping) {
    if (_socket?.connected == true) {
      _socket!.emit('typing', {
        'groupId': studyGroupId,
        'userId': _currentUserId,
        'isTyping': isTyping,
      });
    }
  }

  // Send whiteboard stroke
  Future<void> sendWhiteboardStroke(WhiteboardStroke stroke) async {
    if (_socket?.connected == true) {
      _socket!.emit('whiteboard_stroke', stroke.toJson());
    } else {
      // Add to mock stream for development
      _whiteboardController.add(stroke);
    }
  }

  // Start voice/video call
  Future<void> startCall(String studyGroupId, CallType type) async {
    if (_socket?.connected == true) {
      _socket!.emit('start_call', {
        'groupId': studyGroupId,
        'type': type.toString().split('.').last,
        'initiatedBy': _currentUserId,
      });
    }
  }

  // Join voice/video call
  Future<void> joinCall(String callId) async {
    if (_socket?.connected == true) {
      _socket!.emit('join_call', {
        'callId': callId,
        'userId': _currentUserId,
      });
    }
  }

  // End voice/video call
  Future<void> endCall(String callId) async {
    if (_socket?.connected == true) {
      _socket!.emit('end_call', {
        'callId': callId,
        'userId': _currentUserId,
      });
    }
  }

  // Share resource in study group
  Future<void> shareResource(
      String studyGroupId, Map<String, dynamic> resource) async {
    if (_socket?.connected == true) {
      _socket!.emit('share_resource', {
        'groupId': studyGroupId,
        'resource': resource,
        'sharedBy': _currentUserId,
      });
    }
  }

  // Send reaction to message
  Future<void> sendReaction(String messageId, String emoji) async {
    if (_socket?.connected == true) {
      _socket!.emit('message_reaction', {
        'messageId': messageId,
        'emoji': emoji,
        'userId': _currentUserId,
      });
    }
  }

  // Initialize mock service for development/testing
  void _initializeMockService() {
    _isConnected = true;
    log('Using mock real-time service for development');

    // Simulate some activity for testing
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_messagesController.hasListener) {
        final mockMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'mock_user',
          senderName: 'Mock User',
          content: 'This is a mock message for testing',
          type: ChatMessageType.text,
          timestamp: DateTime.now(),
        );
        _messagesController.add(mockMessage);
      }
    });
  }

  // Dispose resources
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _messagesController.close();
    _whiteboardController.close();
    _memberActivityController.close();
    _callEventsController.close();
    _typingController.close();
    _isConnected = false;
  }
}

// WebRTC service for voice/video calls
class WebRTCService {
  static WebRTCService? _instance;
  static WebRTCService get instance => _instance ??= WebRTCService._();

  WebRTCService._();

  bool _isInitialized = false;
  CallSession? _currentCall;

  // Initialize WebRTC (using Agora as an example)
  Future<void> initialize(String appId) async {
    try {
      // Initialize Agora RTC Engine
      // await AgoraRtcEngine.create(appId);
      _isInitialized = true;
      log('WebRTC service initialized');
    } catch (e) {
      log('Error initializing WebRTC: $e');
    }
  }

  // Join voice call
  Future<void> joinVoiceCall(String channelId, String token) async {
    if (!_isInitialized) return;

    try {
      // Implementation would depend on your WebRTC provider
      log('Joining voice call: $channelId');
    } catch (e) {
      log('Error joining voice call: $e');
    }
  }

  // Join video call
  Future<void> joinVideoCall(String channelId, String token) async {
    if (!_isInitialized) return;

    try {
      // Implementation would depend on your WebRTC provider
      log('Joining video call: $channelId');
    } catch (e) {
      log('Error joining video call: $e');
    }
  }

  // Leave call
  Future<void> leaveCall() async {
    try {
      // Implementation would depend on your WebRTC provider
      _currentCall = null;
      log('Left call');
    } catch (e) {
      log('Error leaving call: $e');
    }
  }

  // Toggle mute
  Future<void> toggleMute() async {
    try {
      // Implementation would depend on your WebRTC provider
      log('Toggled mute');
    } catch (e) {
      log('Error toggling mute: $e');
    }
  }

  // Toggle video
  Future<void> toggleVideo() async {
    try {
      // Implementation would depend on your WebRTC provider
      log('Toggled video');
    } catch (e) {
      log('Error toggling video: $e');
    }
  }

  void dispose() {
    // Clean up WebRTC resources
    _currentCall = null;
    _isInitialized = false;
  }
}
