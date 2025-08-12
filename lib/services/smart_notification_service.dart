import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';
import 'dart:io';

import '../models/notification_models.dart';
import '../models/mood_entry.dart';
import '../models/job_application.dart';
import 'smart_notification_content.dart';
import 'user_pattern_analyzer.dart';

class SmartNotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static NotificationPreferences _preferences = NotificationPreferences();
  static NotificationAnalytics _analytics = NotificationAnalytics();
  static final List<NotificationSchedule> _scheduledNotifications = [];
  static bool _isInitialized = false;

  // Notification channels
  static const String _moodChannel = 'mood_reminders';
  static const String _jobChannel = 'job_followups';
  static const String _studyChannel = 'study_sessions';
  static const String _goalChannel = 'goal_progress';
  static const String _achievementChannel = 'achievements';

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Configure notifications
      await _configureNotifications();

      // Request permissions
      await _requestPermissions();

      // Load preferences and analytics
      await _loadUserPreferences();
      await _loadAnalytics();

      // Initialize background tasks
      await _initializeBackgroundTasks();

      // Schedule initial notifications
      await _scheduleRecurringNotifications();

      _isInitialized = true;
      debugPrint('Smart Notification Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Smart Notification Service: $e');
    }
  }

  /// Configure notification channels and settings
  static Future<void> _configureNotifications() async {
    // Android configuration
    const androidInitialization =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS configuration
    const iosInitialization = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Mood reminders channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _moodChannel,
        'Mood Reminders',
        description: 'Daily mood check-in reminders',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Job follow-ups channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _jobChannel,
        'Job Follow-ups',
        description: 'Job application follow-up reminders',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );

    // Study sessions channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _studyChannel,
        'Study Sessions',
        description: 'Study session reminders and encouragement',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: true,
      ),
    );

    // Goal progress channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _goalChannel,
        'Goal Progress',
        description: 'Goal progress updates and milestones',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: true,
      ),
    );

    // Achievements channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _achievementChannel,
        'Achievements',
        description: 'Achievement celebrations and milestones',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );
  }

  /// Request necessary permissions
  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final permission = await Permission.notification.request();
      if (permission.isDenied) {
        debugPrint('Notification permission denied');
      }
    }

    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Initialize background task processing
  static Future<void> _initializeBackgroundTasks() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );

    // Schedule periodic intelligence updates
    await Workmanager().registerPeriodicTask(
      'smart_notifications_update',
      'updateNotificationIntelligence',
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  /// Background task dispatcher
  @pragma('vm:entry-point')
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case 'updateNotificationIntelligence':
          await _updateIntelligenceModel();
          return Future.value(true);
        case 'scheduleSmartReminder':
          final type = NotificationType.values.firstWhere(
            (e) => e.toString() == inputData?['type'],
            orElse: () => NotificationType.moodReminder,
          );
          await scheduleSmartReminder(type);
          return Future.value(true);
        default:
          return Future.value(false);
      }
    });
  }

  /// Handle notification responses
  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        final type = NotificationType.values.firstWhere(
          (e) => e.toString() == data['type'],
          orElse: () => NotificationType.moodReminder,
        );

        // Track engagement
        _trackEngagement(type, data);

        // Handle quick actions
        _handleQuickActions(response.actionId, type, data);
      } catch (e) {
        debugPrint('Error processing notification response: $e');
      }
    }
  }

  /// Schedule an intelligent notification
  static Future<void> scheduleSmartReminder(NotificationType type) async {
    if (!_isInitialized) {
      debugPrint('Service not initialized. Call initialize() first.');
      return;
    }

    try {
      // Check if this type is enabled
      if (!_isNotificationTypeEnabled(type)) {
        return;
      }

      // Calculate optimal time
      final optimalTime = await _calculateOptimalTime(type);

      // Check quiet hours
      if (UserPatternAnalyzer.isInQuietHours(_preferences.quietHours)) {
        // Schedule for next non-quiet hour
        final scheduledTime = _findNextAvailableTime(optimalTime);
        await _scheduleDelayedNotification(type, scheduledTime);
        return;
      }

      // Generate smart content
      final context = await _buildNotificationContext(type);
      final content = SmartNotificationContent.generateContent(type, context);
      final actionButtons =
          SmartNotificationContent.generateActionButtons(type);

      // Create notification schedule
      final schedule = NotificationSchedule(
        id: _generateNotificationId(type),
        type: type,
        scheduledTime: optimalTime,
        title: content['title']!,
        content: content['body']!,
        context: context.userContext,
        actionButtons: actionButtons,
      );

      // Schedule the notification
      await _scheduleNotification(schedule);

      // Save to scheduled list
      _scheduledNotifications.add(schedule);
      await _saveScheduledNotifications();
    } catch (e) {
      debugPrint('Error scheduling smart reminder: $e');
    }
  }

  /// Calculate optimal time for notification type
  static Future<DateTime> _calculateOptimalTime(NotificationType type) async {
    final now = DateTime.now();

    if (!_preferences.adaptiveTiming) {
      // Use default times if adaptive timing is disabled
      switch (type) {
        case NotificationType.moodReminder:
          return DateTime(
              now.year,
              now.month,
              now.day,
              _preferences.moodReminderTime.hour,
              _preferences.moodReminderTime.minute);
        case NotificationType.studySession:
          return DateTime(now.year, now.month, now.day, 9, 0);
        case NotificationType.jobFollowUp:
          return DateTime(now.year, now.month, now.day, 10, 0);
        default:
          return DateTime(now.year, now.month, now.day, 18, 0);
      }
    }

    // Use pattern analysis for adaptive timing
    try {
      // Get user data (this would normally come from providers)
      final moodEntries = <MoodEntry>[]; // Load from database
      final studySessions = <StudySession>[]; // Load from database
      final jobApplications = <JobApplication>[]; // Load from database

      final optimalTime = UserPatternAnalyzer.findOptimalTimeForType(
        type,
        _analytics,
        moodEntries,
        studySessions,
        jobApplications,
      );

      return DateTime(
          now.year, now.month, now.day, optimalTime.hour, optimalTime.minute);
    } catch (e) {
      debugPrint('Error calculating optimal time: $e');
      return DateTime(now.year, now.month, now.day, 20, 0); // Fallback
    }
  }

  /// Build notification context
  static Future<NotificationContext> _buildNotificationContext(
      NotificationType type) async {
    final userContext = <String, dynamic>{};
    final appContext = <String, dynamic>{};

    // Add stress level prediction
    try {
      userContext['stressLevel'] =
          UserPatternAnalyzer.predictStressLevel([], [], []);
    } catch (e) {
      userContext['stressLevel'] = 0.5;
    }

    // Add type-specific context
    switch (type) {
      case NotificationType.goalProgress:
        appContext['goalName'] = 'Study Goal';
        appContext['progress'] = 0.6;
        break;
      case NotificationType.jobFollowUp:
        appContext['company'] = 'Tech Company';
        appContext['position'] = 'Software Engineer';
        appContext['daysSince'] = 5;
        break;
      case NotificationType.studySession:
        appContext['studyStreak'] = 3;
        appContext['totalHours'] = 25.5;
        break;
      default:
        break;
    }

    return NotificationContext(
      type: type,
      timestamp: DateTime.now(),
      userContext: userContext,
      appContext: appContext,
    );
  }

  /// Schedule the actual notification
  static Future<void> _scheduleNotification(
      NotificationSchedule schedule) async {
    final channelId = _getChannelForType(schedule.type);
    final scheduledDate = tz.TZDateTime.from(schedule.scheduledTime, tz.local);

    // Create platform-specific details
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(schedule.type),
      channelDescription: _getChannelDescription(schedule.type),
      importance: _getImportanceForType(schedule.type),
      priority: Priority.high,
      actions: schedule.actionButtons
          .map((action) => AndroidNotificationAction(
              action.toLowerCase().replaceAll(' ', '_'), action))
          .toList(),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create payload
    final payload = jsonEncode({
      'type': schedule.type.toString(),
      'id': schedule.id,
      'context': schedule.context,
    });

    await _notifications.zonedSchedule(
      schedule.id.hashCode,
      schedule.title,
      schedule.content,
      scheduledDate,
      platformDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    _analytics.totalNotificationsSent++;
    await _saveAnalytics();
  }

  /// Schedule recurring notifications (daily mood reminders, etc.)
  static Future<void> _scheduleRecurringNotifications() async {
    if (_preferences.moodReminders) {
      await _scheduleRecurringNotification(
        NotificationType.moodReminder,
        _preferences.moodReminderTime,
        RepeatInterval.daily,
      );
    }

    if (_preferences.weeklyReviews) {
      await _scheduleRecurringNotification(
        NotificationType.weeklyReview,
        const TimeOfDay(hour: 10, minute: 0),
        RepeatInterval.weekly,
      );
    }
  }

  /// Schedule a recurring notification
  static Future<void> _scheduleRecurringNotification(
    NotificationType type,
    TimeOfDay time,
    RepeatInterval interval,
  ) async {
    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final context = await _buildNotificationContext(type);
    final content = SmartNotificationContent.generateContent(type, context);
    final channelId = _getChannelForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: _getImportanceForType(type),
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      type.hashCode,
      content['title']!,
      content['body']!,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      payload: jsonEncode({
        'type': type.toString(),
        'recurring': true,
      }),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: interval == RepeatInterval.daily
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Update notification intelligence model
  static Future<void> _updateIntelligenceModel() async {
    try {
      // This would analyze recent user patterns and update optimal timing
      debugPrint('Updating notification intelligence model...');

      // Update analytics based on recent engagement
      await _analyzeRecentEngagement();

      // Adjust notification timing if needed
      await _optimizeNotificationTiming();

      debugPrint('Notification intelligence updated successfully');
    } catch (e) {
      debugPrint('Error updating notification intelligence: $e');
    }
  }

  /// Track notification engagement
  static void _trackEngagement(
      NotificationType type, Map<String, dynamic> data) {
    final now = DateTime.now();
    final notificationTime =
        DateTime.tryParse(data['scheduledTime'] ?? '') ?? now;

    _analytics.recordEngagement(notificationTime, now);
    _saveAnalytics();
  }

  /// Handle quick actions from notifications
  static void _handleQuickActions(
      String? actionId, NotificationType type, Map<String, dynamic> data) {
    if (actionId == null) return;

    switch (actionId) {
      case 'log_mood':
        // Navigate to mood logging screen
        debugPrint('Quick action: Log mood');
        break;
      case 'start_session':
        // Start study session
        debugPrint('Quick action: Start study session');
        break;
      case 'send_email':
        // Open email for job follow-up
        debugPrint('Quick action: Send follow-up email');
        break;
      default:
        debugPrint('Unknown quick action: $actionId');
    }
  }

  // Helper methods
  static bool _isNotificationTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return _preferences.moodReminders;
      case NotificationType.jobFollowUp:
        return _preferences.jobFollowUps;
      case NotificationType.studySession:
        return _preferences.studyReminders;
      case NotificationType.weeklyReview:
        return _preferences.weeklyReviews;
      default:
        return true;
    }
  }

  static String _getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return _moodChannel;
      case NotificationType.jobFollowUp:
        return _jobChannel;
      case NotificationType.studySession:
        return _studyChannel;
      case NotificationType.goalProgress:
        return _goalChannel;
      case NotificationType.achievement:
        return _achievementChannel;
      default:
        return _moodChannel;
    }
  }

  static String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return 'Mood Reminders';
      case NotificationType.jobFollowUp:
        return 'Job Follow-ups';
      case NotificationType.studySession:
        return 'Study Sessions';
      case NotificationType.goalProgress:
        return 'Goal Progress';
      case NotificationType.achievement:
        return 'Achievements';
      default:
        return 'StudyPro Notifications';
    }
  }

  static String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
        return 'Daily mood check-in reminders';
      case NotificationType.jobFollowUp:
        return 'Job application follow-up reminders';
      case NotificationType.studySession:
        return 'Study session reminders and encouragement';
      case NotificationType.goalProgress:
        return 'Goal progress updates and milestones';
      case NotificationType.achievement:
        return 'Achievement celebrations';
      default:
        return 'StudyPro app notifications';
    }
  }

  static Importance _getImportanceForType(NotificationType type) {
    switch (type) {
      case NotificationType.moodReminder:
      case NotificationType.jobFollowUp:
      case NotificationType.achievement:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  static String _generateNotificationId(NotificationType type) {
    return '${type.toString()}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static DateTime _findNextAvailableTime(DateTime preferredTime) {
    final quietHours = _preferences.quietHours;
    var nextTime = preferredTime;

    while (quietHours.contains(nextTime.hour)) {
      nextTime = nextTime.add(const Duration(hours: 1));
    }

    return nextTime;
  }

  static Future<void> _scheduleDelayedNotification(
      NotificationType type, DateTime scheduledTime) async {
    await Workmanager().registerOneOffTask(
      'delayed_${type.toString()}_${scheduledTime.millisecondsSinceEpoch}',
      'scheduleSmartReminder',
      inputData: {'type': type.toString()},
      initialDelay: scheduledTime.difference(DateTime.now()),
    );
  }

  static Future<void> _analyzeRecentEngagement() async {
    // Analyze patterns in the last 30 days
    // This would involve looking at notification response times,
    // user actions, and effectiveness metrics
  }

  static Future<void> _optimizeNotificationTiming() async {
    // Use machine learning or statistical analysis to optimize timing
    // Based on engagement patterns
  }

  // Persistence methods
  static Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('notification_preferences');
      if (prefsJson != null) {
        _preferences = NotificationPreferences.fromJson(jsonDecode(prefsJson));
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  static Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'notification_preferences', jsonEncode(_preferences.toJson()));
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  static Future<void> _loadAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString('notification_analytics');
      if (analyticsJson != null) {
        _analytics = NotificationAnalytics.fromJson(jsonDecode(analyticsJson));
      }
    } catch (e) {
      debugPrint('Error loading notification analytics: $e');
    }
  }

  static Future<void> _saveAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'notification_analytics', jsonEncode(_analytics.toJson()));
    } catch (e) {
      debugPrint('Error saving notification analytics: $e');
    }
  }

  static Future<void> _saveScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson =
          _scheduledNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(
          'scheduled_notifications', jsonEncode(scheduledJson));
    } catch (e) {
      debugPrint('Error saving scheduled notifications: $e');
    }
  }

  // Public API methods
  static Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      debugPrint('Service not initialized. Call initialize() first.');
      return;
    }

    try {
      final context =
          await _buildNotificationContext(NotificationType.moodReminder);
      final content = SmartNotificationContent.generateContent(
          NotificationType.moodReminder, context);

      const androidDetails = AndroidNotificationDetails(
        _moodChannel,
        'Mood Reminders',
        channelDescription: 'Daily mood check-in reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        0,
        content['title']!,
        content['body']!,
        platformDetails,
        payload: jsonEncode({
          'type': NotificationType.moodReminder.toString(),
          'test': true,
        }),
      );

      debugPrint('Test notification sent successfully!');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  static Future<void> updatePreferences(
      NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _saveUserPreferences();

    // Reschedule notifications based on new preferences
    await cancelAllNotifications();
    await _scheduleRecurringNotifications();
  }

  static NotificationPreferences getPreferences() => _preferences;
  static NotificationAnalytics getAnalytics() => _analytics;

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _scheduledNotifications.clear();
    await _saveScheduledNotifications();
  }

  static Future<void> cancelNotification(String notificationId) async {
    await _notifications.cancel(notificationId.hashCode);
    _scheduledNotifications.removeWhere((n) => n.id == notificationId);
    await _saveScheduledNotifications();
  }

  static List<NotificationSchedule> getScheduledNotifications() =>
      List.from(_scheduledNotifications);
}
