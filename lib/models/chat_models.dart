// Real-time chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final String? replyToMessageId;
  final List<ChatAttachment> attachments;
  final bool isEdited;
  final bool isDeleted;
  final Map<String, String> reactions; // userId -> emoji

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.replyToMessageId,
    this.attachments = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.reactions = const {},
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      type: ChatMessageType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => ChatMessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      replyToMessageId: json['replyToMessageId'],
      attachments: (json['attachments'] as List?)
              ?.map((a) => ChatAttachment.fromJson(a))
              .toList() ??
          [],
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      reactions: Map<String, String>.from(json['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'replyToMessageId': replyToMessageId,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'reactions': reactions,
    };
  }
}

enum ChatMessageType {
  text,
  image,
  file,
  voice,
  video,
  link,
  poll,
  whiteboard,
  flashcard,
  note,
  system,
}

// Chat attachment model
class ChatAttachment {
  final String id;
  final String name;
  final String url;
  final String type; // image, file, video, etc.
  final int? size;
  final String? thumbnail;

  ChatAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.size,
    this.thumbnail,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      size: json['size'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'thumbnail': thumbnail,
    };
  }
}

// Virtual whiteboard model
class WhiteboardStroke {
  final String id;
  final List<WhiteboardPoint> points;
  final String color;
  final double strokeWidth;
  final String userId;
  final DateTime timestamp;

  WhiteboardStroke({
    required this.id,
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.userId,
    required this.timestamp,
  });

  factory WhiteboardStroke.fromJson(Map<String, dynamic> json) {
    return WhiteboardStroke(
      id: json['id'],
      points: (json['points'] as List)
          .map((p) => WhiteboardPoint.fromJson(p))
          .toList(),
      color: json['color'],
      strokeWidth: json['strokeWidth'].toDouble(),
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((p) => p.toJson()).toList(),
      'color': color,
      'strokeWidth': strokeWidth,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WhiteboardPoint {
  final double x;
  final double y;
  final double pressure;

  WhiteboardPoint({
    required this.x,
    required this.y,
    this.pressure = 1.0,
  });

  factory WhiteboardPoint.fromJson(Map<String, dynamic> json) {
    return WhiteboardPoint(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      pressure: json['pressure']?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'pressure': pressure,
    };
  }
}

// Shared flashcard model
class SharedFlashcard {
  final String id;
  final String title;
  final String front;
  final String back;
  final String createdBy;
  final DateTime createdAt;
  final List<String> tags;
  final String studyGroupId;
  final int difficulty; // 1-5
  final Map<String, FlashcardProgress> progress; // userId -> progress

  SharedFlashcard({
    required this.id,
    required this.title,
    required this.front,
    required this.back,
    required this.createdBy,
    required this.createdAt,
    this.tags = const [],
    required this.studyGroupId,
    this.difficulty = 3,
    this.progress = const {},
  });

  factory SharedFlashcard.fromJson(Map<String, dynamic> json) {
    return SharedFlashcard(
      id: json['id'],
      title: json['title'],
      front: json['front'],
      back: json['back'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags'] ?? []),
      studyGroupId: json['studyGroupId'],
      difficulty: json['difficulty'] ?? 3,
      progress: Map<String, FlashcardProgress>.from(
        (json['progress'] as Map?)?.map(
              (key, value) => MapEntry(key, FlashcardProgress.fromJson(value)),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'front': front,
      'back': back,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'studyGroupId': studyGroupId,
      'difficulty': difficulty,
      'progress': progress.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class FlashcardProgress {
  final int timesStudied;
  final int correctAnswers;
  final DateTime lastStudied;
  final double confidence; // 0.0 - 1.0

  FlashcardProgress({
    required this.timesStudied,
    required this.correctAnswers,
    required this.lastStudied,
    required this.confidence,
  });

  factory FlashcardProgress.fromJson(Map<String, dynamic> json) {
    return FlashcardProgress(
      timesStudied: json['timesStudied'],
      correctAnswers: json['correctAnswers'],
      lastStudied: DateTime.parse(json['lastStudied']),
      confidence: json['confidence'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timesStudied': timesStudied,
      'correctAnswers': correctAnswers,
      'lastStudied': lastStudied.toIso8601String(),
      'confidence': confidence,
    };
  }
}

// Voice/Video call models
class CallSession {
  final String id;
  final String studyGroupId;
  final String initiatedBy;
  final DateTime startTime;
  final DateTime? endTime;
  final CallType type;
  final List<CallParticipant> participants;
  final bool isActive;

  CallSession({
    required this.id,
    required this.studyGroupId,
    required this.initiatedBy,
    required this.startTime,
    this.endTime,
    required this.type,
    this.participants = const [],
    this.isActive = true,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  factory CallSession.fromJson(Map<String, dynamic> json) {
    return CallSession(
      id: json['id'],
      studyGroupId: json['studyGroupId'],
      initiatedBy: json['initiatedBy'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      type: CallType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
      ),
      participants: (json['participants'] as List?)
              ?.map((p) => CallParticipant.fromJson(p))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studyGroupId': studyGroupId,
      'initiatedBy': initiatedBy,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'type': type.toString().split('.').last,
      'participants': participants.map((p) => p.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

enum CallType { voice, video, screenShare }

class CallParticipant {
  final String userId;
  final String name;
  final bool isMuted;
  final bool isVideoEnabled;
  final DateTime joinedAt;
  final DateTime? leftAt;

  CallParticipant({
    required this.userId,
    required this.name,
    this.isMuted = false,
    this.isVideoEnabled = true,
    required this.joinedAt,
    this.leftAt,
  });

  bool get isActive => leftAt == null;

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      userId: json['userId'],
      name: json['name'],
      isMuted: json['isMuted'] ?? false,
      isVideoEnabled: json['isVideoEnabled'] ?? true,
      joinedAt: DateTime.parse(json['joinedAt']),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'isMuted': isMuted,
      'isVideoEnabled': isVideoEnabled,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
    };
  }
}
