import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime deadline;
  final GoalPriority priority;
  final bool isCompleted;
  final List<String> milestones;
  final Map<String, dynamic> metadata;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.deadline,
    this.priority = GoalPriority.medium,
    this.isCompleted = false,
    this.milestones = const [],
    this.metadata = const {},
  });

  double get progress => currentValue / targetValue;
  bool get isOverdue => DateTime.now().isAfter(deadline) && !isCompleted;

  int get daysLeft => deadline.difference(DateTime.now()).inDays;
}

enum GoalType {
  jobApplications,
  interviews,
  skillDevelopment,
  networking,
  moodConsistency,
  studyHours,
  custom
}

enum GoalPriority { low, medium, high, critical }

class GoalTrackingService {
  static List<Goal> _goals = [];

  static List<Goal> get goals => _goals;

  // Smart goal suggestions based on user patterns
  static List<Goal> generateSmartGoals({
    required int totalApplications,
    required double averageMood,
    required int studyGroupsJoined,
  }) {
    List<Goal> suggestions = [];

    // Application-based goals
    if (totalApplications < 10) {
      suggestions.add(Goal(
        id: 'apps_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Apply to 10 Jobs',
        description: 'Increase your job search activity to boost opportunities',
        type: GoalType.jobApplications,
        targetValue: 10,
        currentValue: totalApplications,
        deadline: DateTime.now().add(const Duration(days: 30)),
        priority: GoalPriority.high,
      ));
    }

    // Mood consistency goals
    if (averageMood < 3.5) {
      suggestions.add(Goal(
        id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Maintain Positive Mood',
        description: 'Log mood above 4.0 for 7 consecutive days',
        type: GoalType.moodConsistency,
        targetValue: 7,
        deadline: DateTime.now().add(const Duration(days: 14)),
        priority: GoalPriority.medium,
        milestones: ['Day 1', 'Day 3', 'Day 5', 'Day 7'],
      ));
    }

    // Study goals
    if (studyGroupsJoined == 0) {
      suggestions.add(Goal(
        id: 'study_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Join Study Community',
        description: 'Join at least 2 study groups to enhance learning',
        type: GoalType.networking,
        targetValue: 2,
        deadline: DateTime.now().add(const Duration(days: 7)),
        priority: GoalPriority.medium,
      ));
    }

    return suggestions;
  }

  static void addGoal(Goal goal) {
    _goals.add(goal);
  }

  static void updateProgress(String goalId, int newValue) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      _goals[goalIndex] = Goal(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        type: goal.type,
        targetValue: goal.targetValue,
        currentValue: newValue,
        deadline: goal.deadline,
        priority: goal.priority,
        isCompleted: newValue >= goal.targetValue,
        milestones: goal.milestones,
        metadata: goal.metadata,
      );
    }
  }

  static List<Goal> getActiveGoals() {
    return _goals
        .where((goal) => !goal.isCompleted && !goal.isOverdue)
        .toList();
  }

  static List<Goal> getOverdueGoals() {
    return _goals.where((goal) => goal.isOverdue).toList();
  }

  static List<Goal> getCompletedGoals() {
    return _goals.where((goal) => goal.isCompleted).toList();
  }
}

// Achievement system
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime unlockedAt;
  final AchievementRarity rarity;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlockedAt,
    this.rarity = AchievementRarity.common,
  });
}

enum AchievementRarity { common, rare, epic, legendary }

class AchievementService {
  static List<Achievement> _unlockedAchievements = [];

  static List<Achievement> get achievements => _unlockedAchievements;

  static void checkForAchievements({
    required int totalApplications,
    required int moodStreak,
    required int studySessionsCompleted,
    required List<Goal> completedGoals,
  }) {
    // First Application Achievement
    if (totalApplications == 1 && !_hasAchievement('first_app')) {
      _unlockAchievement(Achievement(
        id: 'first_app',
        title: 'First Step',
        description: 'Submitted your first job application!',
        icon: Icons.work,
        color: Colors.blue,
        unlockedAt: DateTime.now(),
      ));
    }

    // Application Milestone Achievements
    if (totalApplications == 10 && !_hasAchievement('apps_10')) {
      _unlockAchievement(Achievement(
        id: 'apps_10',
        title: 'Getting Started',
        description: 'Applied to 10 jobs - you\'re building momentum!',
        icon: Icons.trending_up,
        color: Colors.green,
        unlockedAt: DateTime.now(),
        rarity: AchievementRarity.rare,
      ));
    }

    // Mood Streak Achievements
    if (moodStreak == 7 && !_hasAchievement('mood_week')) {
      _unlockAchievement(Achievement(
        id: 'mood_week',
        title: 'Consistency Champion',
        description: 'Logged your mood for 7 days straight!',
        icon: Icons.emoji_emotions,
        color: Colors.amber,
        unlockedAt: DateTime.now(),
      ));
    }

    // Goal Completion Achievement
    if (completedGoals.length >= 5 && !_hasAchievement('goal_master')) {
      _unlockAchievement(Achievement(
        id: 'goal_master',
        title: 'Goal Master',
        description: 'Completed 5 goals - you\'re unstoppable!',
        icon: Icons.emoji_events,
        color: Colors.purple,
        unlockedAt: DateTime.now(),
        rarity: AchievementRarity.epic,
      ));
    }
  }

  static bool _hasAchievement(String id) {
    return _unlockedAchievements.any((achievement) => achievement.id == id);
  }

  static void _unlockAchievement(Achievement achievement) {
    _unlockedAchievements.add(achievement);
    // Trigger celebration animation/notification
  }
}
