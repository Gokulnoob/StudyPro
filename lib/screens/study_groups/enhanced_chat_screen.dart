import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../../models/study_group.dart';
import '../../models/chat_models.dart';
import '../../services/realtime_communication_service.dart';
import '../../widgets/chat_message_widget.dart';
import '../../widgets/typing_indicator.dart';
import '../../screens/study_groups/whiteboard_screen.dart';
import '../../screens/study_groups/voice_call_screen.dart';

class EnhancedStudyGroupChatScreen extends StatefulWidget {
  final StudyGroup studyGroup;

  const EnhancedStudyGroupChatScreen({
    super.key,
    required this.studyGroup,
  });

  @override
  State<EnhancedStudyGroupChatScreen> createState() =>
      _EnhancedStudyGroupChatScreenState();
}

class _EnhancedStudyGroupChatScreenState
    extends State<EnhancedStudyGroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final Set<String> _typingUsers = {};

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;

  bool _isLoading = true;
  bool _isRecording = false;
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Initialize real-time communication
      await RealTimeCommunicationService.instance.initialize(
        userId: 'current_user_id', // Replace with actual user ID
        userName: 'Current User', // Replace with actual user name
      );

      // Join the study group room
      await RealTimeCommunicationService.instance
          .joinStudyGroup(widget.studyGroup.id.toString());

      // Subscribe to message stream
      _messagesSubscription =
          RealTimeCommunicationService.instance.messagesStream.listen(
        (message) {
          setState(() {
            _messages.add(message);
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          });
          _scrollToBottom();
        },
      );

      // Subscribe to typing stream
      _typingSubscription =
          RealTimeCommunicationService.instance.typingStream.listen(
        (data) {
          final userId = data['userId'] as String;
          final isTyping = data['isTyping'] as bool;

          setState(() {
            if (isTyping) {
              _typingUsers.add(userId);
            } else {
              _typingUsers.remove(userId);
            }
          });
        },
      );

      // Load initial messages (from local storage or API)
      await _loadInitialMessages();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInitialMessages() async {
    // Load messages from local storage or API
    // For now, add some mock messages
    final mockMessages = [
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Alice Johnson',
        content: 'Hey everyone! Ready for today\'s study session?',
        type: ChatMessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ChatMessage(
        id: '2',
        senderId: 'user2',
        senderName: 'Bob Smith',
        content: 'Yes! I\'ve prepared some notes on Chapter 5',
        type: ChatMessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ];

    setState(() {
      _messages.addAll(mockMessages);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user_id',
      senderName: 'You',
      content: content,
      type: ChatMessageType.text,
      timestamp: DateTime.now(),
      replyToMessageId: _replyToMessageId,
    );

    RealTimeCommunicationService.instance.sendMessage(message);

    _messageController.clear();
    _replyToMessageId = null;
    _stopTyping();
  }

  void _onTyping() {
    RealTimeCommunicationService.instance.sendTypingIndicator(
      widget.studyGroup.id.toString(),
      true,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    RealTimeCommunicationService.instance.sendTypingIndicator(
      widget.studyGroup.id.toString(),
      false,
    );
    _typingTimer?.cancel();
  }

  Future<void> _pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // In a real app, you'd upload the file and get a URL
        final attachment = ChatAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          url: 'https://example.com/files/${file.name}', // Mock URL
          type: file.extension ?? 'unknown',
          size: file.size,
        );

        final message = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'current_user_id',
          senderName: 'You',
          content: 'Shared a file: ${file.name}',
          type: ChatMessageType.file,
          timestamp: DateTime.now(),
          attachments: [attachment],
        );

        RealTimeCommunicationService.instance.sendMessage(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // In a real app, you'd upload the image and get a URL
        final attachment = ChatAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: image.name,
          url: 'https://example.com/images/${image.name}', // Mock URL
          type: 'image',
          size: await image.length(),
        );

        final message = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'current_user_id',
          senderName: 'You',
          content: 'Shared an image',
          type: ChatMessageType.image,
          timestamp: DateTime.now(),
          attachments: [attachment],
        );

        RealTimeCommunicationService.instance.sendMessage(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _startVoiceCall() {
    RealTimeCommunicationService.instance.startCall(
      widget.studyGroup.id.toString(),
      CallType.voice,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(studyGroup: widget.studyGroup),
      ),
    );
  }

  void _startVideoCall() {
    RealTimeCommunicationService.instance.startCall(
      widget.studyGroup.id.toString(),
      CallType.video,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(
          studyGroup: widget.studyGroup,
          isVideoCall: true,
        ),
      ),
    );
  }

  void _openWhiteboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhiteboardScreen(studyGroup: widget.studyGroup),
      ),
    );
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyToMessageId = message.id;
    });
    _messageController.text = '@${message.senderName} ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.studyGroup.name),
            Text(
              '${widget.studyGroup.memberCount} members',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startVoiceCall,
            tooltip: 'Voice Call',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
            tooltip: 'Video Call',
          ),
          IconButton(
            icon: const Icon(Icons.draw),
            onPressed: _openWhiteboard,
            tooltip: 'Whiteboard',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'members',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('View Members'),
                ),
              ),
              const PopupMenuItem(
                value: 'resources',
                child: ListTile(
                  leading: Icon(Icons.folder),
                  title: Text('Shared Resources'),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
            onSelected: (value) {
              // Handle menu actions
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessageWidget(
                        message: message,
                        onReply: () => _replyToMessage(message),
                        onReaction: (emoji) {
                          RealTimeCommunicationService.instance.sendReaction(
                            message.id,
                            emoji,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Typing indicator
                if (_typingUsers.isNotEmpty)
                  TypingIndicator(userNames: _typingUsers.toList()),

                // Reply indicator
                if (_replyToMessageId != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.reply, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Replying to message...')),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () =>
                              setState(() => _replyToMessageId = null),
                        ),
                      ],
                    ),
                  ),

                // Message input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment button
                      PopupMenuButton(
                        icon: const Icon(Icons.add),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'image',
                            child: const ListTile(
                              leading: Icon(Icons.image),
                              title: Text('Image'),
                            ),
                            onTap: _pickAndSendImage,
                          ),
                          PopupMenuItem(
                            value: 'file',
                            child: const ListTile(
                              leading: Icon(Icons.attach_file),
                              title: Text('File'),
                            ),
                            onTap: _pickAndSendFile,
                          ),
                          PopupMenuItem(
                            value: 'flashcard',
                            child: const ListTile(
                              leading: Icon(Icons.style),
                              title: Text('Flashcard'),
                            ),
                            onTap: () {
                              // Open flashcard creation dialog
                            },
                          ),
                        ],
                      ),

                      // Message input field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          onChanged: (_) => _onTyping(),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),

                      // Voice recording button
                      IconButton(
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        onPressed: () {
                          setState(() => _isRecording = !_isRecording);
                          // Implement voice recording
                        },
                      ),

                      // Send button
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    RealTimeCommunicationService.instance
        .leaveStudyGroup(widget.studyGroup.id.toString());
    super.dispose();
  }
}
