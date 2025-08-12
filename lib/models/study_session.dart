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

  StudySession copyWith({
    int? id,
    int? groupId,
    String? title,
    String? description,
    DateTime? scheduledDate,
    String? notes,
    List<String>? attendees,
  }) {
    return StudySession(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      attendees: attendees ?? this.attendees,
    );
  }
}
