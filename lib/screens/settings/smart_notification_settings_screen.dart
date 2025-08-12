import 'package:flutter/material.dart';
import '../../models/notification_models.dart';
import '../../services/smart_notification_service.dart';

class SmartNotificationSettingsScreen extends StatefulWidget {
  const SmartNotificationSettingsScreen({super.key});

  @override
  State<SmartNotificationSettingsScreen> createState() =>
      _SmartNotificationSettingsScreenState();
}

class _SmartNotificationSettingsScreenState
    extends State<SmartNotificationSettingsScreen> {
  late NotificationPreferences _preferences;
  late NotificationAnalytics _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _preferences = SmartNotificationService.getPreferences();
      _analytics = SmartNotificationService.getAnalytics();
    } catch (e) {
      debugPrint('Error loading notification data: $e');
      _preferences = NotificationPreferences();
      _analytics = NotificationAnalytics();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    try {
      await SmartNotificationService.updatePreferences(_preferences);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Smart Notifications'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Notifications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
            tooltip: 'Save Preferences',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsCard(),
            const SizedBox(height: 20),
            _buildNotificationTypesCard(),
            const SizedBox(height: 20),
            _buildTimingCard(),
            const SizedBox(height: 20),
            _buildAdvancedCard(),
            const SizedBox(height: 20),
            _buildTestNotificationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsItem(
                    'Engagement Rate',
                    '${(_analytics.engagementRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    _analytics.engagementRate > 0.7
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsItem(
                    'Total Sent',
                    '${_analytics.totalNotificationsSent}',
                    Icons.send,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsItem(
                    'Avg Response',
                    '${_analytics.averageResponseTime.inMinutes}m',
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsItem(
                    'Best Time',
                    _getBestNotificationTime(),
                    Icons.schedule,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBestNotificationTime() {
    if (_analytics.timeEffectiveness.isEmpty) return 'N/A';

    final bestHour = _analytics.timeEffectiveness.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return '${bestHour.toString().padLeft(2, '0')}:00';
  }

  Widget _buildNotificationTypesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNotificationToggle(
              'Mood Reminders',
              'Daily check-ins for your emotional wellbeing',
              Icons.mood,
              _preferences.moodReminders,
              (value) {
                setState(() {
                  _preferences.moodReminders = value;
                });
              },
            ),
            _buildNotificationToggle(
              'Job Follow-ups',
              'Smart reminders for job application follow-ups',
              Icons.work,
              _preferences.jobFollowUps,
              (value) {
                setState(() {
                  _preferences.jobFollowUps = value;
                });
              },
            ),
            _buildNotificationToggle(
              'Study Reminders',
              'Encouragement and session reminders',
              Icons.school,
              _preferences.studyReminders,
              (value) {
                setState(() {
                  _preferences.studyReminders = value;
                });
              },
            ),
            _buildNotificationToggle(
              'Weekly Reviews',
              'Weekly progress summaries and reflections',
              Icons.assessment,
              _preferences.weeklyReviews,
              (value) {
                setState(() {
                  _preferences.weeklyReviews = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTimingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timing Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Mood Reminder Time'),
              subtitle: Text(
                '${_preferences.moodReminderTime.format(context)}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectTime(context),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.psychology,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Adaptive Timing'),
              subtitle:
                  const Text('Learn from your patterns to optimize timing'),
              trailing: Switch(
                value: _preferences.adaptiveTiming,
                onChanged: (value) {
                  setState(() {
                    _preferences.adaptiveTiming = value;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.do_not_disturb,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Do Not Disturb'),
              subtitle: const Text('Temporarily disable all notifications'),
              trailing: Switch(
                value: _preferences.doNotDisturbMode,
                onChanged: (value) {
                  setState(() {
                    _preferences.doNotDisturbMode = value;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quiet Hours',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(24, (index) {
                final isQuiet = _preferences.quietHours.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isQuiet) {
                        _preferences.quietHours.remove(index);
                      } else {
                        _preferences.quietHours.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isQuiet
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${index.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        color: isQuiet ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Engagement Threshold',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _preferences.engagementThreshold,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              label: '${(_preferences.engagementThreshold * 100).toInt()}%',
              onChanged: (value) {
                setState(() {
                  _preferences.engagementThreshold = value;
                });
              },
            ),
            Text(
              'Notifications will be optimized for ${(_preferences.engagementThreshold * 100).toInt()}% engagement rate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await SmartNotificationService.sendTestNotification();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Test notification sent! Check your notifications.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error sending test notification: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.send),
        label: const Text('Send Test Notification'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _preferences.moodReminderTime,
    );

    if (picked != null && picked != _preferences.moodReminderTime) {
      setState(() {
        _preferences.moodReminderTime = picked;
      });
    }
  }
}
