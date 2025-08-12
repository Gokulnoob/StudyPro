import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../models/job_application.dart';
import '../models/notification_models.dart';

class UserPatternAnalyzer {
  static const int _minDataPoints = 5;
  static const int _analysisWindowDays = 30;

  /// Analyze when user typically logs mood entries to find optimal reminder time
  static TimeOfDay getOptimalMoodReminderTime(List<MoodEntry> entries) {
    if (entries.length < _minDataPoints) {
      return const TimeOfDay(hour: 20, minute: 0); // Default fallback
    }

    // Filter recent entries
    final recentEntries = entries.where((entry) {
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: _analysisWindowDays));
      return entry.date.isAfter(cutoff);
    }).toList();

    if (recentEntries.isEmpty) {
      return const TimeOfDay(hour: 20, minute: 0);
    }

    // Calculate average logging time
    int totalMinutes = 0;
    for (final entry in recentEntries) {
      totalMinutes += entry.date.hour * 60 + entry.date.minute;
    }

    final averageMinutes = totalMinutes ~/ recentEntries.length;
    final hour = (averageMinutes ~/ 60) % 24;
    final minute = averageMinutes % 60;

    // Adjust to a reasonable reminder time (1 hour before average logging time)
    final reminderHour = hour > 0 ? hour - 1 : 23;

    return TimeOfDay(hour: reminderHour, minute: minute);
  }

  /// Identify productive study times based on session data
  static List<TimeOfDay> getOptimalStudyTimes(List<StudySession> sessions) {
    if (sessions.length < _minDataPoints) {
      return [
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 19, minute: 0),
      ]; // Default study times
    }

    // Group sessions by hour and calculate productivity scores
    final Map<int, List<double>> hourlyProductivity = {};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      final productivity = _calculateSessionProductivity(session);

      hourlyProductivity.putIfAbsent(hour, () => []).add(productivity);
    }

    // Calculate average productivity for each hour
    final Map<int, double> avgProductivity = {};
    hourlyProductivity.forEach((hour, scores) {
      avgProductivity[hour] = scores.reduce((a, b) => a + b) / scores.length;
    });

    // Sort hours by productivity and return top 3
    final sortedHours = avgProductivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours
        .take(3)
        .map((entry) => TimeOfDay(hour: entry.key, minute: 0))
        .toList();
  }

  /// Calculate average response time for job applications
  static Duration getAverageResponseTime(List<JobApplication> applications) {
    final responseApplications = applications
        .where((app) =>
            app.status == 'Interview' ||
            app.status == 'Offered' ||
            app.status == 'Rejected')
        .toList();

    if (responseApplications.length < _minDataPoints) {
      return const Duration(days: 7); // Default follow-up time
    }

    int totalDays = 0;
    int count = 0;

    for (final app in responseApplications) {
      if (app.notes?.isNotEmpty == true) {
        // Try to extract response timing from notes or use a heuristic
        final applicationDate = DateTime.tryParse(app.applicationDate);
        if (applicationDate != null) {
          final daysSinceApplication =
              DateTime.now().difference(applicationDate).inDays;
          if (daysSinceApplication > 0) {
            totalDays += daysSinceApplication;
            count++;
          }
        }
      }
    }

    if (count == 0) {
      return const Duration(days: 7);
    }

    final averageDays = totalDays / count;
    return Duration(
        days: (averageDays * 0.8).round()); // Follow up before average response
  }

  /// Analyze engagement patterns with notifications
  static Map<int, double> analyzeEngagementPatterns(
      NotificationAnalytics analytics) {
    if (analytics.timeEffectiveness.isEmpty) {
      // Return default engagement pattern if no data
      return {
        8: 0.7, // Morning
        12: 0.6, // Lunch
        17: 0.8, // Evening
        20: 0.9, // Night
      };
    }

    return Map.from(analytics.timeEffectiveness);
  }

  /// Find optimal time for specific notification type
  static TimeOfDay findOptimalTimeForType(
    NotificationType type,
    NotificationAnalytics analytics,
    List<MoodEntry> moodEntries,
    List<StudySession> studySessions,
    List<JobApplication> jobApplications,
  ) {
    switch (type) {
      case NotificationType.moodReminder:
        return getOptimalMoodReminderTime(moodEntries);

      case NotificationType.studySession:
        final optimalTimes = getOptimalStudyTimes(studySessions);
        return optimalTimes.isNotEmpty
            ? optimalTimes.first
            : const TimeOfDay(hour: 9, minute: 0);

      case NotificationType.jobFollowUp:
        // Use engagement patterns for job follow-ups
        final engagementMap = analyzeEngagementPatterns(analytics);
        final bestHour = engagementMap.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        return TimeOfDay(hour: bestHour, minute: 0);

      case NotificationType.weeklyReview:
        return const TimeOfDay(hour: 10, minute: 0); // Sunday morning

      case NotificationType.goalProgress:
        return const TimeOfDay(hour: 18, minute: 0); // Evening reflection

      case NotificationType.achievement:
        return TimeOfDay.now(); // Immediate for achievements

      case NotificationType.encouragement:
        // Use most engaged time
        final engagementMap = analyzeEngagementPatterns(analytics);
        final bestHour = engagementMap.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        return TimeOfDay(hour: bestHour, minute: 0);
    }
  }

  /// Predict user's current stress level based on recent activity
  static double predictStressLevel(
    List<MoodEntry> recentMoods,
    List<JobApplication> recentApplications,
    List<StudySession> recentSessions,
  ) {
    double stressScore = 0.5; // Neutral baseline

    // Analyze recent mood trends
    if (recentMoods.isNotEmpty) {
      final avgMood =
          recentMoods.map((entry) => entry.moodLevel).reduce((a, b) => a + b) /
              recentMoods.length;

      // Lower mood correlates with higher stress (scale is 1-5)
      stressScore += (3.0 - avgMood) / 10.0; // Normalize to smaller impact
    }

    // Factor in job application activity
    final recentJobActivity = recentApplications.where((app) {
      final applicationDate = DateTime.tryParse(app.applicationDate);
      return applicationDate
              ?.isAfter(DateTime.now().subtract(const Duration(days: 7))) ??
          false;
    }).length;

    if (recentJobActivity > 5) {
      stressScore += 0.2; // High job search activity increases stress
    }

    // Factor in study session intensity
    if (recentSessions.isNotEmpty) {
      final avgSessionLength = recentSessions
              .map((session) => session.duration.inMinutes)
              .reduce((a, b) => a + b) /
          recentSessions.length;

      if (avgSessionLength > 180) {
        // More than 3 hours
        stressScore += 0.15;
      }
    }

    return stressScore.clamp(0.0, 1.0);
  }

  /// Determine if current time is within user's quiet hours
  static bool isInQuietHours(List<int> quietHours) {
    final now = DateTime.now();
    return quietHours.contains(now.hour);
  }

  /// Calculate session productivity score
  static double _calculateSessionProductivity(StudySession session) {
    // Simple heuristic: longer sessions with notes are more productive
    double score = 0.5;

    // Duration factor (diminishing returns after 2 hours)
    final hours = session.duration.inMinutes / 60.0;
    score += (hours / (1 + hours)) * 0.3;

    // Notes factor
    if (session.notes.isNotEmpty) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }
}

// Extension to add study session support (if not already available)
class StudySession {
  final DateTime startTime;
  final Duration duration;
  final String notes;
  final String subject;

  StudySession({
    required this.startTime,
    required this.duration,
    this.notes = '',
    this.subject = '',
  });
}
