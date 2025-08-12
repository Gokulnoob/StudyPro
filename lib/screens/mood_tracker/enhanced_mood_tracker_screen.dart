import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_entry.dart';
import 'add_mood_entry_screen.dart';
import 'mood_analytics_screen.dart';

class EnhancedMoodTrackerScreen extends StatefulWidget {
  const EnhancedMoodTrackerScreen({super.key});

  @override
  State<EnhancedMoodTrackerScreen> createState() =>
      _EnhancedMoodTrackerScreenState();
}

class _EnhancedMoodTrackerScreenState extends State<EnhancedMoodTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load mood entries when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MoodProvider>(context, listen: false);
      provider.loadMoodEntries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider =
                  Provider.of<MoodProvider>(context, listen: false);
              provider.loadMoodEntries();
            },
            tooltip: 'Refresh mood entries',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodAnalyticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMoodEntryScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(provider),
              _buildTrendsTab(provider),
              _buildHistoryTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMoodEntryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(Provider.of<MoodProvider>(context).hasTodaysEntry
            ? 'Update Mood'
            : 'Log Mood'),
      ),
    );
  }

  Widget _buildOverviewTab(MoodProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadMoodEntries();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Status Card
            _buildTodayStatusCard(provider),
            const SizedBox(height: 16),

            // Quick Stats
            _buildQuickStatsCard(provider),
            const SizedBox(height: 16),

            // Weekly Progress
            _buildWeeklyProgressCard(provider),
            const SizedBox(height: 16),

            // Mood Insights
            _buildMoodInsightsCard(provider),
            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActionsCard(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(MoodProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeframe Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('View: '),
                  const SizedBox(width: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Week', label: Text('Week')),
                      ButtonSegment(value: 'Month', label: Text('Month')),
                      ButtonSegment(value: 'Year', label: Text('Year')),
                    ],
                    selected: {_selectedTimeframe},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedTimeframe = selection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mood Trend Chart
          _buildMoodTrendChart(provider),
          const SizedBox(height: 16),

          // Mood Distribution
          _buildMoodDistributionChart(provider),
          const SizedBox(height: 16),

          // Activity Correlation
          _buildActivityCorrelationCard(provider),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(MoodProvider provider) {
    final entries = provider.moodEntries;

    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mood_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No mood entries yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start by logging your first mood',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadMoodEntries();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return EnhancedMoodEntryCard(
            entry: entry,
            onTap: () => _showMoodEntryDetails(context, entry),
          );
        },
      ),
    );
  }

  Widget _buildTodayStatusCard(MoodProvider provider) {
    final todaysEntry = provider.getTodaysMoodEntry();
    final hasEntry = todaysEntry != null;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: hasEntry
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasEntry ? Icons.check_circle : Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasEntry ? 'Today\'s Mood Logged' : 'Log Today\'s Mood',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasEntry) ...[
                Row(
                  children: [
                    Text(
                      MoodLevel.getMoodEmoji(todaysEntry.moodLevel),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoodLevel.getMoodText(todaysEntry.moodLevel),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${provider.streakDays} day streak!',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                const Text(
                  'Keep your streak going! Log how you\'re feeling today.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMoodEntryScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                  ),
                  child: const Text('Log Mood Now'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(MoodProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Streak',
                    '${provider.streakDays}',
                    'days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Average',
                    provider.weeklyAverageMoodLevel.toStringAsFixed(1),
                    'this week',
                    Icons.trending_up,
                    _getMoodColor(provider.weeklyAverageMoodLevel),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Entries',
                    '${provider.moodEntries.length}',
                    'total',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressCard(MoodProvider provider) {
    final weeklyEntries = provider.getWeeklyMoodEntries();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final date =
                      DateTime.now().subtract(Duration(days: 6 - index));
                  final entry = weeklyEntries
                      .where((e) =>
                          e.date.year == date.year &&
                          e.date.month == date.month &&
                          e.date.day == date.day)
                      .firstOrNull;

                  return Column(
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: entry != null
                              ? _getMoodColor(entry.moodLevel.toDouble())
                                  .withOpacity(0.8)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry != null
                                ? MoodLevel.getMoodEmoji(entry.moodLevel)
                                : '?',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodInsightsCard(MoodProvider provider) {
    final insights = _generateMoodInsights(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Mood Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        insight.isPositive ? Icons.thumb_up : Icons.info,
                        color:
                            insight.isPositive ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(insight.message,
                              style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(MoodProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.self_improvement, size: 18),
                  label: const Text('Meditation'),
                  onPressed: () {
                    // Start meditation timer
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.directions_walk, size: 18),
                  label: const Text('Take a Walk'),
                  onPressed: () {
                    // Suggest walk activity
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.music_note, size: 18),
                  label: const Text('Listen to Music'),
                  onPressed: () {
                    // Music recommendations
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.call, size: 18),
                  label: const Text('Call Someone'),
                  onPressed: () {
                    // Suggest calling a friend
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrendChart(MoodProvider provider) {
    final entries = _selectedTimeframe == 'Week'
        ? provider.getWeeklyMoodEntries()
        : provider.getMonthlyMoodEntries();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: entries.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(),
                            entry.value.moodLevel.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  minY: 1,
                  maxY: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart(MoodProvider provider) {
    final distribution = provider.moodDistribution;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final percentage = provider.moodEntries.isNotEmpty
                  ? (entry.value / provider.moodEntries.length) * 100
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(MoodLevel.getMoodEmoji(entry.key)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(MoodLevel.getMoodText(entry.key)),
                    ),
                    Text('${percentage.toStringAsFixed(1)}%'),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getMoodColor(entry.key.toDouble()),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCorrelationCard(MoodProvider provider) {
    // Simplified activity correlation analysis
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Impact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Activities that tend to improve your mood:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ['Exercise', 'Meditation', 'Socializing', 'Music']
                  .map((activity) => Chip(
                        label: Text(activity),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(double moodLevel) {
    if (moodLevel >= 4.0) return Colors.green;
    if (moodLevel >= 3.0) return Colors.orange;
    return Colors.red;
  }

  List<MoodInsight> _generateMoodInsights(MoodProvider provider) {
    List<MoodInsight> insights = [];

    final avgMood = provider.weeklyAverageMoodLevel;
    final streak = provider.streakDays;

    if (streak >= 7) {
      insights.add(MoodInsight(
        'Amazing! You\'ve maintained a $streak-day streak of mood logging.',
        true,
      ));
    }

    if (avgMood >= 4.0) {
      insights.add(MoodInsight(
        'Your mood has been consistently positive this week!',
        true,
      ));
    } else if (avgMood < 3.0) {
      insights.add(MoodInsight(
        'Your mood seems lower than usual. Consider reaching out to someone or trying a mood-boosting activity.',
        false,
      ));
    }

    if (provider.moodEntries.length >= 30) {
      insights.add(MoodInsight(
        'You\'ve logged ${provider.moodEntries.length} moods! This data helps you understand your patterns.',
        true,
      ));
    }

    return insights;
  }

  void _showMoodEntryDetails(BuildContext context, MoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  MoodLevel.getMoodEmoji(entry.moodLevel),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MoodLevel.getMoodText(entry.moodLevel),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(entry.date),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(entry.notes!),
            ],
            if (entry.activities.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Activities:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: entry.activities
                    .map((activity) => Chip(
                          label: Text(activity),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EnhancedMoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onTap;

  const EnhancedMoodEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.moodLevel).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  MoodLevel.getMoodEmoji(entry.moodLevel),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          MoodLevel.getMoodText(entry.moodLevel),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getRelativeTime(entry.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM dd').format(entry.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.notes!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.sleepHours != null || entry.stressLevel != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    if (entry.sleepHours != null) ...[
                      const Icon(Icons.bedtime, size: 16, color: Colors.grey),
                      Text(
                        '${entry.sleepHours}h',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    if (entry.stressLevel != null) ...[
                      const SizedBox(height: 4),
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: _getStressColor(entry.stressLevel!),
                      ),
                      Text(
                        '${entry.stressLevel}/5',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStressColor(entry.stressLevel!),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  Color _getStressColor(int stressLevel) {
    if (stressLevel <= 2) return Colors.green;
    if (stressLevel <= 3) return Colors.orange;
    return Colors.red;
  }

  String _getRelativeTime(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

class MoodInsight {
  final String message;
  final bool isPositive;

  MoodInsight(this.message, this.isPositive);
}
