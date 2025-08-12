import 'package:flutter/material.dart';

enum NotificationType {
  moodReminder,
  jobFollowUp,
  studySession,
  goalProgress,
  weeklyReview,
  achievement,
  encouragement
}

class NotificationPreferences {
  bool moodReminders;
  TimeOfDay moodReminderTime;
  bool jobFollowUps;
  bool studyReminders;
  bool weeklyReviews;
  List<int> quietHours;
  bool doNotDisturbMode;
  bool adaptiveTiming;
  double engagementThreshold;

  NotificationPreferences({
    this.moodReminders = true,
    this.moodReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.jobFollowUps = true,
    this.studyReminders = true,
    this.weeklyReviews = true,
    this.quietHours = const [22, 23, 0, 1, 2, 3, 4, 5, 6, 7], // 10 PM - 7 AM
    this.doNotDisturbMode = false,
    this.adaptiveTiming = true,
    this.engagementThreshold = 0.7,
  });

  Map<String, dynamic> toJson() {
    return {
      'moodReminders': moodReminders,
      'moodReminderTime': '${moodReminderTime.hour}:${moodReminderTime.minute}',
      'jobFollowUps': jobFollowUps,
      'studyReminders': studyReminders,
      'weeklyReviews': weeklyReviews,
      'quietHours': quietHours,
      'doNotDisturbMode': doNotDisturbMode,
      'adaptiveTiming': adaptiveTiming,
      'engagementThreshold': engagementThreshold,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final timeString = json['moodReminderTime'] as String? ?? '20:0';
    final timeParts = timeString.split(':');

    return NotificationPreferences(
      moodReminders: json['moodReminders'] ?? true,
      moodReminderTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      jobFollowUps: json['jobFollowUps'] ?? true,
      studyReminders: json['studyReminders'] ?? true,
      weeklyReviews: json['weeklyReviews'] ?? true,
      quietHours: List<int>.from(
          json['quietHours'] ?? [22, 23, 0, 1, 2, 3, 4, 5, 6, 7]),
      doNotDisturbMode: json['doNotDisturbMode'] ?? false,
      adaptiveTiming: json['adaptiveTiming'] ?? true,
      engagementThreshold: json['engagementThreshold'] ?? 0.7,
    );
  }
}

class NotificationSchedule {
  final String id;
  final NotificationType type;
  final DateTime scheduledTime;
  final String title;
  final String content;
  final Map<String, dynamic> context;
  final bool isRecurring;
  final Duration? recurringInterval;
  final List<String> actionButtons;
  final DateTime createdAt;

  NotificationSchedule({
    required this.id,
    required this.type,
    required this.scheduledTime,
    required this.title,
    required this.content,
    this.context = const {},
    this.isRecurring = false,
    this.recurringInterval,
    this.actionButtons = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'title': title,
      'content': content,
      'context': context,
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval?.inMilliseconds,
      'actionButtons': actionButtons,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) {
    return NotificationSchedule(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.moodReminder,
      ),
      scheduledTime: DateTime.parse(json['scheduledTime']),
      title: json['title'],
      content: json['content'],
      context: Map<String, dynamic>.from(json['context'] ?? {}),
      isRecurring: json['isRecurring'] ?? false,
      recurringInterval: json['recurringInterval'] != null
          ? Duration(milliseconds: json['recurringInterval'])
          : null,
      actionButtons: List<String>.from(json['actionButtons'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationAnalytics {
  double engagementRate;
  List<String> mostEffectiveContent;
  Map<int, double> timeEffectiveness; // Hour of day -> effectiveness
  Duration averageResponseTime;
  int totalNotificationsSent;
  int totalEngagements;
  DateTime lastUpdated;

  NotificationAnalytics({
    this.engagementRate = 0.0,
    this.mostEffectiveContent = const [],
    this.timeEffectiveness = const {},
    this.averageResponseTime = const Duration(hours: 2),
    this.totalNotificationsSent = 0,
    this.totalEngagements = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'engagementRate': engagementRate,
      'mostEffectiveContent': mostEffectiveContent,
      'timeEffectiveness':
          timeEffectiveness.map((k, v) => MapEntry(k.toString(), v)),
      'averageResponseTime': averageResponseTime.inMilliseconds,
      'totalNotificationsSent': totalNotificationsSent,
      'totalEngagements': totalEngagements,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory NotificationAnalytics.fromJson(Map<String, dynamic> json) {
    return NotificationAnalytics(
      engagementRate: json['engagementRate'] ?? 0.0,
      mostEffectiveContent:
          List<String>.from(json['mostEffectiveContent'] ?? []),
      timeEffectiveness:
          (json['timeEffectiveness'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(int.parse(k), v.toDouble())),
      averageResponseTime:
          Duration(milliseconds: json['averageResponseTime'] ?? 7200000),
      totalNotificationsSent: json['totalNotificationsSent'] ?? 0,
      totalEngagements: json['totalEngagements'] ?? 0,
      lastUpdated: DateTime.parse(
          json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  void recordEngagement(DateTime notificationTime, DateTime responseTime) {
    totalEngagements++;
    final hour = notificationTime.hour;

    // Update time effectiveness
    final currentEffectiveness = timeEffectiveness[hour] ?? 0.0;
    timeEffectiveness[hour] =
        (currentEffectiveness + 1.0) / 2; // Simple moving average

    // Update engagement rate
    engagementRate = totalNotificationsSent > 0
        ? totalEngagements / totalNotificationsSent
        : 0.0;

    // Update average response time
    final responseDelay = responseTime.difference(notificationTime);
    averageResponseTime = Duration(
      milliseconds:
          (averageResponseTime.inMilliseconds + responseDelay.inMilliseconds) ~/
              2,
    );

    lastUpdated = DateTime.now();
  }
}

class NotificationContext {
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic> userContext;
  final Map<String, dynamic> appContext;

  NotificationContext({
    required this.type,
    required this.timestamp,
    this.userContext = const {},
    this.appContext = const {},
  });
}
