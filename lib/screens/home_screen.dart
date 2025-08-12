import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_application_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/study_group_provider.dart';
import '../models/mood_entry.dart';
import '../services/performance_optimizer.dart';
import 'job_tracker/enhanced_job_tracker_screen.dart';
import 'mood_tracker/enhanced_mood_tracker_screen.dart';
import 'study_groups/enhanced_study_groups_screen.dart';
import 'settings/smart_notification_settings_screen.dart';
import 'ai_career_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _dataLoaded = false;

  // Lazy-loaded screens - only create when needed
  final Map<int, Widget> _screenCache = {};

  Widget _getScreen(int index) {
    if (!_screenCache.containsKey(index)) {
      switch (index) {
        case 0:
          _screenCache[index] = const DashboardScreen();
          break;
        case 1:
          _screenCache[index] = const EnhancedJobTrackerScreen();
          break;
        case 2:
          _screenCache[index] = const EnhancedMoodTrackerScreen();
          break;
        case 3:
          // Don't cache the study groups screen to ensure it refreshes
          return const EnhancedStudyGroupsScreen();
        default:
          _screenCache[index] = const DashboardScreen();
      }
    }
    return _screenCache[index]!;
  }

  @override
  void initState() {
    super.initState();
    // Load data asynchronously without blocking UI
    _loadDataAsync();
  }

  void _loadDataAsync() async {
    PerformanceOptimizer.startOperation('homeDataLoad');

    // Show UI immediately with loading state
    setState(() {
      _dataLoaded = false;
    });

    try {
      final jobProvider = context.read<JobApplicationProvider>();
      final moodProvider = context.read<MoodProvider>();
      final studyGroupProvider = context.read<StudyGroupProvider>();

      // Load essential data first (for dashboard) with timeout
      await jobProvider.loadApplications().timeout(const Duration(seconds: 5));

      // Update UI with essential data loaded
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
      }

      // Load remaining data in background with staggered timing
      Future.delayed(const Duration(milliseconds: 100), () async {
        await moodProvider
            .loadMoodEntries()
            .timeout(const Duration(seconds: 3));
      });

      Future.delayed(const Duration(milliseconds: 200), () async {
        await studyGroupProvider
            .loadStudyGroups()
            .timeout(const Duration(seconds: 3));
      });

      // Clear expired cache periodically
      Future.delayed(const Duration(seconds: 1), () {
        PerformanceOptimizer.clearExpiredCache();
      });
    } catch (e) {
      debugPrint('Error loading essential data: $e');
      // Show UI anyway with fallback data
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
      }
    }

    PerformanceOptimizer.endOperation('homeDataLoad');
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mood_outlined),
                label: 'Mood',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                label: 'Groups',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(context),
                const SizedBox(height: 32),

                // Quick Stats
                _buildQuickStats(context),
                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(context),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_getGreeting()}!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ready to boost your productivity?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
      builder: (context, jobProvider, moodProvider, groupProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress Today',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Job Apps',
                      '${jobProvider.applications.length}',
                      Icons.work_outline,
                      const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Mood Entries',
                      '${moodProvider.moodEntries.length}',
                      Icons.mood_outlined,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Study Groups',
                      '${groupProvider.studyGroups.length}',
                      Icons.group_outlined,
                      const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'New mood entry added',
            'Track your daily emotions',
            Icons.mood,
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Study group created',
            'Join collaborative learning',
            Icons.group,
            const Color(0xFFEC4899),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Job application submitted',
            'Track your career progress',
            Icons.work,
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Add Mood',
                  Icons.mood_outlined,
                  const Color(0xFF8B5CF6),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedMoodTrackerScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'New Job',
                  Icons.work_outline,
                  const Color(0xFF6366F1),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedJobTrackerScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Study Group',
                  Icons.group_outlined,
                  const Color(0xFFEC4899),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedStudyGroupsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Notifications',
                  Icons.notifications_outlined,
                  const Color(0xFF10B981),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SmartNotificationSettingsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'AI Career Assistant',
                  Icons.psychology_outlined,
                  const Color(0xFF6366F1),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AICareerAssistantScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // Placeholder for future action
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Welcome Card with Motivational Quotes
class EnhancedWelcomeCard extends StatelessWidget {
  const EnhancedWelcomeCard({super.key});

  static final List<String> _motivationalQuotes = [
    "Your career journey starts with a single application!",
    "Every mood logged is a step towards better mental health.",
    "Great things happen when you study together!",
    "Success is the sum of small efforts repeated daily.",
    "Your future self will thank you for today's efforts.",
  ];

  @override
  Widget build(BuildContext context) {
    final quote =
        _motivationalQuotes[DateTime.now().day % _motivationalQuotes.length];
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = "Good morning! ☀️";
    } else if (hour < 17) {
      greeting = "Good afternoon! 🌤️";
    } else {
      greeting = "Good evening! 🌙";
    }

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                quote,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<MoodProvider>(
                builder: (context, moodProvider, child) {
                  final streak = moodProvider.streakDays;
                  return Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$streak day streak!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Quick Stats with Trends
class EnhancedQuickStatsGrid extends StatelessWidget {
  const EnhancedQuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
      builder: (context, jobProvider, moodProvider, studyProvider, child) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildEnhancedStatCard(
              context,
              'Applications',
              '${jobProvider.totalApplications}',
              '+${jobProvider.pendingApplications} pending',
              Icons.work,
              Colors.blue,
              () {
                // Navigate to job tracker
              },
            ),
            _buildEnhancedStatCard(
              context,
              'Interview Rate',
              '${jobProvider.totalApplications > 0 ? ((jobProvider.interviewApplications / jobProvider.totalApplications) * 100).toStringAsFixed(0) : "0"}%',
              '${jobProvider.interviewApplications} interviews',
              Icons.trending_up,
              Colors.green,
              () {
                // Show interview analytics
              },
            ),
            _buildEnhancedStatCard(
              context,
              'Mood Score',
              '${moodProvider.weeklyAverageMoodLevel.toStringAsFixed(1)}/5',
              '${moodProvider.streakDays} day streak',
              Icons.mood,
              _getMoodColor(moodProvider.weeklyAverageMoodLevel),
              () {
                // Navigate to mood tracker
              },
            ),
            _buildEnhancedStatCard(
              context,
              'Study Groups',
              '${studyProvider.activeGroupsCount}',
              '${studyProvider.totalGroups} total groups',
              Icons.groups,
              Colors.purple,
              () {
                // Navigate to study groups
              },
            ),
          ],
        );
      },
    );
  }

  Color _getMoodColor(double averageMood) {
    if (averageMood >= 4.0) return Colors.green;
    if (averageMood >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildEnhancedStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Weekly Goals Progress Card
class WeeklyGoalsCard extends StatelessWidget {
  const WeeklyGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
      builder: (context, jobProvider, moodProvider, studyProvider, child) {
        final moodGoalProgress =
            moodProvider.streakDays >= 7 ? 1.0 : moodProvider.streakDays / 7.0;
        final jobGoalProgress = jobProvider.totalApplications >= 3
            ? 1.0
            : jobProvider.totalApplications / 3.0;
        final studyGoalProgress = studyProvider.activeGroupsCount >= 1
            ? 1.0
            : studyProvider.activeGroupsCount / 1.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGoalProgress(
                  'Log mood 7 days',
                  moodGoalProgress,
                  '${moodProvider.streakDays}/7 days',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildGoalProgress(
                  'Apply to 3 jobs',
                  jobGoalProgress,
                  '${jobProvider.totalApplications}/3 applications',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildGoalProgress(
                  'Join 1 study group',
                  studyGoalProgress,
                  '${studyProvider.activeGroupsCount}/1 groups',
                  Colors.purple,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalProgress(
      String title, double progress, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

// Smart Actions Card with AI-like Suggestions
class SmartActionsCard extends StatelessWidget {
  const SmartActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
      builder: (context, jobProvider, moodProvider, studyProvider, child) {
        final suggestions =
            _generateSmartSuggestions(jobProvider, moodProvider, studyProvider);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Suggestions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...suggestions
                    .map((suggestion) => _buildSuggestionTile(suggestion)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ActionSuggestion> _generateSmartSuggestions(
    JobApplicationProvider jobProvider,
    MoodProvider moodProvider,
    StudyGroupProvider studyProvider,
  ) {
    List<ActionSuggestion> suggestions = [];

    // Mood-based suggestions
    if (!moodProvider.hasTodaysEntry) {
      suggestions.add(ActionSuggestion(
        title: 'Log today\'s mood',
        subtitle: 'Keep your ${moodProvider.streakDays} day streak going!',
        icon: Icons.mood,
        color: Colors.green,
        priority: 1,
      ));
    }

    // Job application suggestions
    if (jobProvider.pendingApplications == 0 &&
        jobProvider.totalApplications > 0) {
      suggestions.add(ActionSuggestion(
        title: 'Follow up on applications',
        subtitle: 'Check status of recent applications',
        icon: Icons.email,
        color: Colors.blue,
        priority: 2,
      ));
    }

    if (jobProvider.totalApplications < 3) {
      suggestions.add(ActionSuggestion(
        title: 'Apply to more jobs',
        subtitle: 'Reach your weekly goal of 3 applications',
        icon: Icons.work_outline,
        color: Colors.orange,
        priority: 3,
      ));
    }

    // Study group suggestions
    if (studyProvider.activeGroupsCount == 0) {
      suggestions.add(ActionSuggestion(
        title: 'Join a study group',
        subtitle: 'Collaborate and learn together',
        icon: Icons.group_add,
        color: Colors.purple,
        priority: 4,
      ));
    }

    // Sort by priority and take top 3
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));
    return suggestions.take(3).toList();
  }

  Widget _buildSuggestionTile(ActionSuggestion suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          // Handle suggestion tap
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: suggestion.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(suggestion.icon, size: 20, color: suggestion.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      suggestion.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionSuggestion {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int priority;

  ActionSuggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

// Enhanced Recent Activity with More Details
class EnhancedRecentActivityCard extends StatelessWidget {
  const EnhancedRecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
              builder:
                  (context, jobProvider, moodProvider, studyProvider, child) {
                final activities = _generateRecentActivities(
                    jobProvider, moodProvider, studyProvider);

                if (activities.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No recent activity yet. Start by logging your mood or adding a job application!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: activities
                      .map((activity) => _buildActivityItem(
                            context,
                            activity.title,
                            activity.time,
                            activity.icon,
                            activity.color,
                            activity.isImportant,
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<ActivityItem> _generateRecentActivities(
    JobApplicationProvider jobProvider,
    MoodProvider moodProvider,
    StudyGroupProvider studyProvider,
  ) {
    List<ActivityItem> activities = [];

    // Add recent mood entries
    if (moodProvider.moodEntries.isNotEmpty) {
      final latestMood = moodProvider.moodEntries.first;
      activities.add(ActivityItem(
        title: 'Logged mood: ${MoodLevel.getMoodText(latestMood.moodLevel)}',
        time: _getRelativeTime(latestMood.date),
        icon: Icons.mood,
        color: _getMoodColor(latestMood.moodLevel),
        isImportant: latestMood.moodLevel <= 2,
      ));
    }

    // Add recent job applications
    if (jobProvider.applications.isNotEmpty) {
      final latestApp = jobProvider.applications.first;
      activities.add(ActivityItem(
        title: 'Applied to ${latestApp.position} at ${latestApp.company}',
        time: _getRelativeTime(DateTime.parse(latestApp.applicationDate)),
        icon: Icons.work,
        color: Colors.blue,
        isImportant:
            latestApp.status == 'Interview' || latestApp.status == 'Offer',
      ));
    }

    // Add study group activities
    if (studyProvider.studyGroups.isNotEmpty) {
      final latestGroup = studyProvider.studyGroups.first;
      activities.add(ActivityItem(
        title: 'Joined "${latestGroup.name}" study group',
        time: _getRelativeTime(latestGroup.createdAt),
        icon: Icons.groups,
        color: Colors.purple,
        isImportant: false,
      ));
    }

    // Sort by importance and time
    activities.sort((a, b) {
      if (a.isImportant && !b.isImportant) return -1;
      if (!a.isImportant && b.isImportant) return 1;
      return 0;
    });

    return activities.take(5).toList();
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRelativeTime(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
    bool isImportant,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: isImportant ? Border.all(color: color, width: 2) : null,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isImportant ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          if (isImportant)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Important',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final bool isImportant;

  ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    required this.isImportant,
  });
}
