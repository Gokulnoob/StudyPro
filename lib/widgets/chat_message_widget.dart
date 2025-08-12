import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onReply;
  final Function(String emoji)? onReaction;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onReply,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = message.senderId == 'current_user_id';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOwnMessage
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOwnMessage)
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (message.replyToMessageId != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Replying to previous message',
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    _buildMessageContent(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isOwnMessage ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            'edited',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color:
                                  isOwnMessage ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (message.reactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: message.reactions.entries.map((entry) {
                            return Chip(
                              label: Text('${entry.value} 1'),
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              labelStyle: const TextStyle(fontSize: 10),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case ChatMessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: message.senderId == 'current_user_id'
                ? Colors.white
                : Colors.black87,
          ),
        );

      case ChatMessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachments.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.attachments.first.url,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    );
                  },
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: message.senderId == 'current_user_id'
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ],
        );

      case ChatMessageType.file:
        return Row(
          children: [
            const Icon(Icons.attach_file, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.attachments.isNotEmpty
                        ? message.attachments.first.name
                        : 'File',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: message.senderId == 'current_user_id'
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  if (message.attachments.isNotEmpty &&
                      message.attachments.first.size != null)
                    Text(
                      _formatFileSize(message.attachments.first.size!),
                      style: TextStyle(
                        fontSize: 12,
                        color: message.senderId == 'current_user_id'
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      case ChatMessageType.voice:
        return Row(
          children: [
            const Icon(Icons.mic, size: 20),
            const SizedBox(width: 8),
            Text(
              'Voice message',
              style: TextStyle(
                color: message.senderId == 'current_user_id'
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        );

      case ChatMessageType.flashcard:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.style, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Flashcard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(message.content),
            ],
          ),
        );

      default:
        return Text(
          message.content,
          style: TextStyle(
            color: message.senderId == 'current_user_id'
                ? Colors.white
                : Colors.black87,
          ),
        );
    }
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              onReply?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('Add Reaction'),
            onTap: () {
              Navigator.pop(context);
              _showReactionPicker(context);
            },
          ),
          if (message.senderId == 'current_user_id') ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // Implement edit functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                // Implement delete functionality
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              // Implement copy functionality
            },
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reaction'),
        content: Wrap(
          spacing: 16,
          children: emojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onReaction?.call(emoji);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
