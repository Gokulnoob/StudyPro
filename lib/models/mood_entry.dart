enum Mood {
  terrible,
  bad,
  okay,
  good,
  excellent,
}

class MoodEntry {
  final int? id;
  final DateTime date;
  final int moodLevel; // 1-5 scale
  final Mood mood;
  final String? notes;
  final List<String> activities;
  final List<String> factors;
  final int? sleepHours;
  final int? stressLevel; // 1-5 scale
  final int? energyLevel; // 1-5 scale

  MoodEntry({
    this.id,
    required this.date,
    required this.moodLevel,
    required this.mood,
    this.notes,
    this.activities = const [],
    this.factors = const [],
    this.sleepHours,
    this.stressLevel,
    this.energyLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodLevel': moodLevel,
      'mood': mood.index,
      'notes': notes,
      'activities': activities.join(','),
      'factors': factors.join(','),
      'sleepHours': sleepHours,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodLevel: map['moodLevel'],
      mood: Mood.values[map['mood'] ?? 2],
      notes: map['notes'],
      activities: (map['activities'] ?? '')
          .split(',')
          .where((a) => a.isNotEmpty)
          .toList(),
      factors:
          (map['factors'] ?? '').split(',').where((f) => f.isNotEmpty).toList(),
      sleepHours: map['sleepHours'],
      stressLevel: map['stressLevel'],
      energyLevel: map['energyLevel'],
    );
  }

  MoodEntry copyWith({
    int? id,
    DateTime? date,
    int? moodLevel,
    Mood? mood,
    String? notes,
    List<String>? activities,
    List<String>? factors,
    int? sleepHours,
    int? stressLevel,
    int? energyLevel,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      factors: factors ?? this.factors,
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }
}

class MoodLevel {
  static const int terrible = 1;
  static const int bad = 2;
  static const int okay = 3;
  static const int good = 4;
  static const int excellent = 5;

  static String getMoodText(int level) {
    switch (level) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }

  static String getMoodEmoji(int level) {
    switch (level) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '❓';
    }
  }
}
