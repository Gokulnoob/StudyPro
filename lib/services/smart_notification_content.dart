import 'dart:math';
import '../models/notification_models.dart';

class SmartNotificationContent {
  static final Random _random = Random();

  /// Generate personalized mood reminder prompts
  static Map<String, String> generateMoodPrompt(NotificationContext context) {
    final timeOfDay = context.timestamp.hour;
    final dayOfWeek = context.timestamp.weekday;

    List<String> titles = [];
    List<String> bodies = [];

    // Time-based prompts
    if (timeOfDay < 12) {
      titles.addAll([
        "Good Morning! 🌅",
        "Start Your Day Right ✨",
        "Morning Check-in 🌞",
      ]);
      bodies.addAll([
        "How are you feeling this morning? Let's capture your mood to start the day mindfully.",
        "Take a moment to reflect on your current state of mind and log your morning mood.",
        "A new day, a fresh start! How would you describe your mood right now?",
      ]);
    } else if (timeOfDay < 17) {
      titles.addAll([
        "Afternoon Reflection 🌤️",
        "Midday Check-in ⏰",
        "How's Your Day? 🤔",
      ]);
      bodies.addAll([
        "How has your day been treating you so far? Time for a quick mood check.",
        "Pause for a moment and reflect on your current emotional state.",
        "Halfway through the day - how are you feeling right now?",
      ]);
    } else {
      titles.addAll([
        "Evening Reflection 🌙",
        "Day's End Check-in 🌆",
        "Unwind & Reflect 🧘",
      ]);
      bodies.addAll([
        "As the day winds down, how would you describe your overall mood?",
        "Take a moment to reflect on your day and capture your current feelings.",
        "Time to unwind and check in with yourself. How are you feeling this evening?",
      ]);
    }

    // Weekend vs weekday variations
    if (dayOfWeek >= 6) {
      bodies.add(
          "Weekend vibes! How are you spending your time and how does it make you feel?");
      titles.add("Weekend Mood Check 🎉");
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate job application follow-up reminders
  static Map<String, String> generateJobReminder(NotificationContext context) {
    final jobContext = context.appContext;
    final company = jobContext['company'] as String? ?? 'the company';
    final position = jobContext['position'] as String? ?? 'position';
    final daysSince = jobContext['daysSince'] as int? ?? 0;

    List<String> titles = [];
    List<String> bodies = [];

    if (daysSince <= 3) {
      titles.addAll([
        "Follow-up Time! 📧",
        "Stay on Their Radar 🎯",
        "Professional Follow-up ✉️",
      ]);
      bodies.addAll([
        "It's been $daysSince days since you applied to $company for the $position role. Consider sending a follow-up email.",
        "Time to follow up on your $position application at $company. A polite check-in can make a difference!",
        "Your application to $company is still fresh in their minds. A brief follow-up could help you stand out.",
      ]);
    } else if (daysSince <= 7) {
      titles.addAll([
        "Week Check-in 📅",
        "Application Update 🔄",
        "Stay Connected 🤝",
      ]);
      bodies.addAll([
        "It's been a week since your $position application at $company. Time for a professional follow-up!",
        "One week milestone! Consider reaching out to $company about your $position application status.",
        "A week has passed - perfect timing for a courteous follow-up on your $company application.",
      ]);
    } else {
      titles.addAll([
        "Long-term Follow-up 📈",
        "Stay Persistent 💪",
        "Professional Persistence 🎯",
      ]);
      bodies.addAll([
        "It's been $daysSince days since your $company application. Consider a final follow-up or moving forward.",
        "Long-term follow-up time! Reach out to $company or focus your energy on new opportunities.",
        "Persistence pays off! Consider one more professional follow-up with $company.",
      ]);
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate study session encouragement
  static Map<String, String> generateStudyEncouragement(
      NotificationContext context) {
    final studyContext = context.appContext;
    final streak = studyContext['studyStreak'] as int? ?? 0;
    final totalHours = studyContext['totalHours'] as double? ?? 0.0;

    List<String> titles = [];
    List<String> bodies = [];

    if (streak > 0) {
      titles.addAll([
        "Keep the Streak! 🔥",
        "Study Momentum 📚",
        "You're on Fire! ⚡",
      ]);
      bodies.addAll([
        "Amazing! You're on a $streak-day study streak. Time to keep the momentum going!",
        "Your $streak-day streak is impressive! Ready for another productive study session?",
        "Consistency is key! You've studied for $streak days straight. Let's continue!",
      ]);
    } else {
      titles.addAll([
        "Study Time! 📖",
        "Learning Awaits 🧠",
        "Knowledge Quest 🎓",
      ]);
      bodies.addAll([
        "Time to dive into your studies! Every session brings you closer to your goals.",
        "Ready to expand your knowledge? Let's start a productive study session.",
        "Your future self will thank you for studying today. Let's get started!",
      ]);
    }

    if (totalHours > 50) {
      bodies.add(
          "Wow! You've already studied ${totalHours.toStringAsFixed(1)} hours. You're making incredible progress!");
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate goal progress notifications
  static Map<String, String> generateGoalProgress(NotificationContext context) {
    final goalContext = context.appContext;
    final goalName = goalContext['goalName'] as String? ?? 'your goal';
    final progress = goalContext['progress'] as double? ?? 0.0;
    final deadline = goalContext['deadline'] as DateTime?;

    List<String> titles = [];
    List<String> bodies = [];

    final progressPercent = (progress * 100).toInt();

    if (progress < 0.25) {
      titles.addAll([
        "Goal Check-in 🎯",
        "Progress Update 📊",
        "Keep Going! 💪",
      ]);
      bodies.addAll([
        "You're $progressPercent% of the way to achieving $goalName. Every step counts!",
        "Progress on $goalName: $progressPercent%. Small steps lead to big achievements!",
        "You've started your journey towards $goalName. Keep building momentum!",
      ]);
    } else if (progress < 0.5) {
      titles.addAll([
        "Quarter Milestone! 🎉",
        "Making Progress 📈",
        "You're Getting There! ⭐",
      ]);
      bodies.addAll([
        "Fantastic! You're $progressPercent% complete with $goalName. Keep up the great work!",
        "Quarter way there! Your progress on $goalName is at $progressPercent%. Stay focused!",
        "You're making solid progress on $goalName. $progressPercent% complete and counting!",
      ]);
    } else if (progress < 0.75) {
      titles.addAll([
        "Halfway Hero! 🏆",
        "Strong Progress 💪",
        "You're Crushing It! 🚀",
      ]);
      bodies.addAll([
        "Incredible! You're $progressPercent% of the way to $goalName. The finish line is in sight!",
        "More than halfway there! Your dedication to $goalName is paying off at $progressPercent%.",
        "Outstanding progress! You're $progressPercent% complete with $goalName. Keep pushing!",
      ]);
    } else {
      titles.addAll([
        "Almost There! 🎊",
        "Final Sprint 🏃‍♀️",
        "So Close! ✨",
      ]);
      bodies.addAll([
        "You're so close! At $progressPercent%, $goalName is almost within reach!",
        "Final push time! You're $progressPercent% complete with $goalName. You've got this!",
        "Amazing dedication! $progressPercent% progress on $goalName. The finish line awaits!",
      ]);
    }

    // Add deadline urgency if applicable
    if (deadline != null) {
      final daysLeft = deadline.difference(DateTime.now()).inDays;
      if (daysLeft <= 7 && daysLeft > 0) {
        bodies.add(
            "⏰ Only $daysLeft days left until your $goalName deadline. Time to focus!");
      } else if (daysLeft <= 0) {
        bodies.add(
            "🚨 Your $goalName deadline has arrived! Time for the final push!");
      }
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate achievement celebration notifications
  static Map<String, String> generateAchievementNotification(
      NotificationContext context) {
    final achievementContext = context.appContext;
    final achievement =
        achievementContext['achievement'] as String? ?? 'your achievement';
    final type = achievementContext['type'] as String? ?? 'milestone';

    List<String> titles = [];
    List<String> bodies = [];

    switch (type) {
      case 'streak':
        titles.addAll([
          "Streak Master! 🔥",
          "Consistency Champion! 🏆",
          "Habit Hero! ⭐",
        ]);
        bodies.addAll([
          "Congratulations! You've achieved $achievement! Your consistency is paying off.",
          "Amazing streak! $achievement unlocked. Keep this momentum going!",
          "You're on fire! $achievement completed through dedication and consistency.",
        ]);
        break;
      case 'goal':
        titles.addAll([
          "Goal Achieved! 🎯",
          "Mission Accomplished! ✅",
          "Victory! 🎊",
        ]);
        bodies.addAll([
          "Incredible! You've successfully achieved $achievement! Time to celebrate!",
          "Goal crushed! $achievement is now complete. You should be proud!",
          "Outstanding work! $achievement has been conquered. What's next?",
        ]);
        break;
      case 'milestone':
        titles.addAll([
          "Milestone Reached! 🏔️",
          "Progress Celebration! 🎉",
          "Level Up! ⬆️",
        ]);
        bodies.addAll([
          "Milestone unlocked! You've reached $achievement. Keep climbing!",
          "Fantastic progress! $achievement milestone achieved. Onward and upward!",
          "Level up! You've hit the $achievement milestone. Your growth is inspiring!",
        ]);
        break;
      default:
        titles.addAll([
          "Achievement Unlocked! 🏅",
          "Success! 🌟",
          "Well Done! 👏",
        ]);
        bodies.addAll([
          "Congratulations on achieving $achievement! Your hard work is paying off.",
          "Success! You've earned $achievement through dedication and effort.",
          "Well deserved! $achievement is yours. Keep up the excellent work!",
        ]);
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate encouraging notifications during tough times
  static Map<String, String> generateEncouragement(
      NotificationContext context) {
    final userContext = context.userContext;
    final stressLevel = userContext['stressLevel'] as double? ?? 0.5;
    final recentMoodTrend = userContext['moodTrend'] as String? ?? 'neutral';

    List<String> titles = [];
    List<String> bodies = [];

    if (stressLevel > 0.7 || recentMoodTrend == 'declining') {
      titles.addAll([
        "You've Got This! 💪",
        "Tough Times Pass 🌈",
        "Strength Within 🧘",
        "One Step at a Time 👣",
      ]);
      bodies.addAll([
        "Feeling overwhelmed? Remember that tough times don't last, but tough people do. You're stronger than you know.",
        "It's okay to feel stressed. Take a deep breath and remember that every challenge is an opportunity to grow.",
        "You've overcome difficulties before, and you'll get through this too. Be kind to yourself today.",
        "Stress is temporary, but your resilience is permanent. Take things one step at a time.",
        "Remember: progress, not perfection. You're doing better than you think.",
      ]);
    } else {
      titles.addAll([
        "Keep Shining! ✨",
        "You're Doing Great! 🌟",
        "Momentum Builder 🚀",
        "Stay Focused! 🎯",
      ]);
      bodies.addAll([
        "You're making great progress! Keep up the positive momentum and trust the process.",
        "Your dedication is inspiring! Every small action you take is building towards something bigger.",
        "You're in a good flow right now. Use this positive energy to tackle your goals!",
        "Great job staying consistent! Your future self will thank you for the work you're putting in today.",
        "You're proof that steady progress leads to amazing results. Keep going!",
      ]);
    }

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate weekly review prompts
  static Map<String, String> generateWeeklyReview(NotificationContext context) {
    final weekContext = context.appContext;
    final weekNumber = weekContext['weekNumber'] as int? ?? 1;
    final completedGoals = weekContext['completedGoals'] as int? ?? 0;
    final totalMoodEntries = weekContext['totalMoodEntries'] as int? ?? 0;

    List<String> titles = [];
    List<String> bodies = [];

    titles.addAll([
      "Weekly Reflection 📝",
      "Week $weekNumber Review 📊",
      "Progress Check-in 🔍",
      "Weekly Wins 🏆",
    ]);

    if (completedGoals > 0) {
      bodies.add(
          "What a week! You completed $completedGoals goals and logged $totalMoodEntries mood entries. Time to reflect on your progress!");
    } else {
      bodies.add(
          "Week $weekNumber is complete! You logged $totalMoodEntries mood entries. Let's review your journey and plan ahead.");
    }

    bodies.addAll([
      "Take a moment to celebrate your wins this week and identify areas for growth. What made you proud?",
      "Weekly reflection time! What were your biggest achievements and learnings this week?",
      "How did this week contribute to your bigger goals? Let's review and plan for an even better week ahead!",
      "Time for your weekly check-in. What patterns do you notice in your mood and productivity?",
    ]);

    return {
      'title': titles[_random.nextInt(titles.length)],
      'body': bodies[_random.nextInt(bodies.length)],
    };
  }

  /// Generate content based on notification type
  static Map<String, String> generateContent(
    NotificationType type,
    NotificationContext context,
  ) {
    switch (type) {
      case NotificationType.moodReminder:
        return generateMoodPrompt(context);
      case NotificationType.jobFollowUp:
        return generateJobReminder(context);
      case NotificationType.studySession:
        return generateStudyEncouragement(context);
      case NotificationType.goalProgress:
        return generateGoalProgress(context);
      case NotificationType.achievement:
        return generateAchievementNotification(context);
      case NotificationType.encouragement:
        return generateEncouragement(context);
      case NotificationType.weeklyReview:
        return generateWeeklyReview(context);
    }
  }

  /// Generate action buttons for notifications
  static List<String> generateActionButtons(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return ['Log Mood', 'Remind Later', 'Skip Today'];
      case NotificationType.jobFollowUp:
        return ['Send Email', 'Update Status', 'Remind Tomorrow'];
      case NotificationType.studySession:
        return ['Start Session', 'Set Timer', 'View Goals'];
      case NotificationType.goalProgress:
        return ['Update Progress', 'View Goal', 'Celebrate'];
      case NotificationType.achievement:
        return ['Celebrate!', 'Share', 'View Progress'];
      case NotificationType.encouragement:
        return ['Thank you', 'Log Mood', 'Take Break'];
      case NotificationType.weeklyReview:
        return ['Start Review', 'View Stats', 'Plan Week'];
    }
  }
}
