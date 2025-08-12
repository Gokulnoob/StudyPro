class StudyGroup {
  final int? id;
  final String name;
  final String description;
  final String subject;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final bool isActive;
  final String? meetingLink;
  final DateTime? nextSession;
  final bool isOnline;
  final String? location;
  final int maxMembers;
  final List<StudyResource> resources;
  final bool isPrivate;
  final List<String> tags;
  final String? meetingSchedule;
  final DateTime? lastActivity;
  final int memberCount;

  StudyGroup({
    this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    this.isActive = true,
    this.meetingLink,
    this.nextSession,
    this.isOnline = true,
    this.location,
    this.maxMembers = 10,
    this.resources = const [],
    this.isPrivate = false,
    this.tags = const [],
    this.meetingSchedule,
    this.lastActivity,
    int? memberCount,
  }) : memberCount = memberCount ?? members.length;

  bool get isMember => true; // This would be determined by user authentication
  bool get isOwner => true; // This would be determined by user authentication
  bool get isJoined => isMember; // Alias for backward compatibility
  bool get hasActiveSession =>
      nextSession != null && nextSession!.isAfter(DateTime.now());

  /// Convert to SQLite map format (compatible with local database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'members': members
          .join(','), // Convert list to comma-separated string for SQLite
      'isActive': isActive ? 1 : 0, // Convert bool to int for SQLite
      'meetingLink': meetingLink,
      'nextSession': nextSession?.toIso8601String(),
      'isOnline': isOnline ? 1 : 0, // Convert bool to int for SQLite
      'location': location,
      'maxMembers': maxMembers,
      'isPrivate': isPrivate ? 1 : 0, // Convert bool to int for SQLite
      'tags':
          tags.join(','), // Convert list to comma-separated string for SQLite
      'meetingSchedule': meetingSchedule,
      'lastActivity': (lastActivity ?? DateTime.now()).toIso8601String(),
      'memberCount': memberCount,
    };
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      subject: map['subject'],
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt'] ??
          map['createdDate'] ??
          DateTime.now().toIso8601String()),
      members:
          (map['members'] ?? '').split(',').where((m) => m.isNotEmpty).toList(),
      isActive: map['isActive'] == 1,
      meetingLink: map['meetingLink'],
      nextSession: map['nextSession'] != null
          ? DateTime.parse(map['nextSession'])
          : null,
      isOnline: map['isOnline'] == 1,
      location: map['location'],
      maxMembers: map['maxMembers'] ?? 10,
      resources: [], // Resources would be loaded separately
      isPrivate: map['isPrivate'] == 1,
      tags: (map['tags'] ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      meetingSchedule: map['meetingSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'members': members,
      'isActive': isActive,
      'meetingLink': meetingLink,
      'nextSession': nextSession?.toIso8601String(),
      'isOnline': isOnline,
      'location': location,
      'maxMembers': maxMembers,
      'resources': resources.map((r) => r.toJson()).toList(),
      'isPrivate': isPrivate,
      'tags': tags,
      'meetingSchedule': meetingSchedule,
    };
  }

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      subject: json['subject'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      members: List<String>.from(json['members'] ?? []),
      isActive: json['isActive'] ?? true,
      meetingLink: json['meetingLink'],
      nextSession: json['nextSession'] != null
          ? DateTime.parse(json['nextSession'])
          : null,
      isOnline: json['isOnline'] ?? true,
      location: json['location'],
      maxMembers: json['maxMembers'] ?? 10,
      resources: (json['resources'] as List<dynamic>?)
              ?.map((r) => StudyResource.fromJson(r))
              .toList() ??
          [],
      isPrivate: json['isPrivate'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      meetingSchedule: json['meetingSchedule'],
    );
  }

  StudyGroup copyWith({
    int? id,
    String? name,
    String? description,
    String? subject,
    String? createdBy,
    DateTime? createdAt,
    List<String>? members,
    bool? isActive,
    String? meetingLink,
    DateTime? nextSession,
    bool? isOnline,
    String? location,
    int? maxMembers,
    List<StudyResource>? resources,
    bool? isPrivate,
    List<String>? tags,
    String? meetingSchedule,
    DateTime? lastActivity,
    int? memberCount,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      isActive: isActive ?? this.isActive,
      meetingLink: meetingLink ?? this.meetingLink,
      nextSession: nextSession ?? this.nextSession,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      maxMembers: maxMembers ?? this.maxMembers,
      resources: resources ?? this.resources,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      lastActivity: lastActivity ?? this.lastActivity,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}

class StudyResource {
  final String title;
  final String description;
  final String url;
  final String type;
  final String sharedBy;
  final DateTime createdAt;

  StudyResource({
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.sharedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'type': type,
      'sharedBy': sharedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyResource.fromJson(Map<String, dynamic> json) {
    return StudyResource(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      type: json['type'],
      sharedBy: json['sharedBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'type': type,
      'sharedBy': sharedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyResource.fromMap(Map<String, dynamic> map) {
    return StudyResource(
      title: map['title'],
      description: map['description'],
      url: map['url'],
      type: map['type'],
      sharedBy: map['sharedBy'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class StudySession {
  final int? id;
  final int groupId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String? notes;
  final List<String> attendees;

  StudySession({
    this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    this.notes,
    required this.attendees,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'notes': notes,
      'attendees': attendees.join(','),
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      groupId: map['groupId'],
      title: map['title'],
      description: map['description'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      notes: map['notes'],
      attendees: (map['attendees'] ?? '')
          .split(',')
          .where((a) => a.isNotEmpty)
          .toList(),
    );
  }
}
