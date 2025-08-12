import 'package:flutter/material.dart';

class StudyGroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const StudyGroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<StudyGroupChatScreen> createState() => _StudyGroupChatScreenState();
}

class _StudyGroupChatScreenState extends State<StudyGroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName),
            Text(
              '12 members • 3 online',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoSession,
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startAudioSession,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'screen_share',
                child: ListTile(
                  leading: Icon(Icons.screen_share),
                  title: Text('Screen Share'),
                ),
              ),
              const PopupMenuItem(
                value: 'whiteboard',
                child: ListTile(
                  leading: Icon(Icons.draw),
                  title: Text('Collaborative Whiteboard'),
                ),
              ),
              const PopupMenuItem(
                value: 'study_timer',
                child: ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('Group Study Timer'),
                ),
              ),
              const PopupMenuItem(
                value: 'file_share',
                child: ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text('Share Files'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Active session banner
          _buildActiveSessionBanner(),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping) _buildTypingIndicator(),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildActiveSessionBanner() {
    // Show when there's an active study session or video call
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.videocam, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Video study session active'),
          const Spacer(),
          ElevatedButton(
            onPressed: _joinActiveSession,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe =
        message.senderId == 'current_user'; // Replace with actual user ID

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(message.senderName),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 2),
                  _buildMessageContent(message, isMe),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe) _buildAvatar(message.senderName),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.content,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            if (message.caption != null) ...[
              const SizedBox(height: 4),
              Text(
                message.caption!,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      case MessageType.studyNote:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.note, color: Colors.amber),
                  const SizedBox(width: 4),
                  const Text(
                    'Study Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildAvatar(String name) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(''),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: _onTyping,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      senderId: 'current_user',
      senderName: 'You',
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  void _onTyping(String text) {
    // Implement typing indicator logic
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                _attachPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _attachFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Study Note'),
              onTap: () {
                Navigator.pop(context);
                _createStudyNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz Question'),
              onTap: () {
                Navigator.pop(context);
                _createQuizQuestion();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoSession() {
    // Implement video session logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Video Session'),
        content: const Text(
            'This will start a video session for all group members.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start video session
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _startAudioSession() {
    // Implement audio session logic
  }

  void _joinActiveSession() {
    // Join existing video/audio session
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'screen_share':
        _startScreenShare();
        break;
      case 'whiteboard':
        _openWhiteboard();
        break;
      case 'study_timer':
        _startGroupStudyTimer();
        break;
      case 'file_share':
        _attachFile();
        break;
    }
  }

  void _startScreenShare() {
    // Implement screen sharing
  }

  void _openWhiteboard() {
    // Open collaborative whiteboard
  }

  void _startGroupStudyTimer() {
    // Start synchronized study timer for all members
  }

  void _attachPhoto() {
    // Implement photo attachment
  }

  void _attachFile() {
    // Implement file attachment
  }

  void _createStudyNote() {
    // Create and share study note
  }

  void _createQuizQuestion() {
    // Create quiz question for the group
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final String? caption;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.type,
    this.caption,
    this.fileName,
  });
}

enum MessageType {
  text,
  image,
  file,
  studyNote,
}
