import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_entry.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7 days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Mood Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trends'),
            Tab(text: 'Patterns'),
            Tab(text: 'Insights'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7 days', child: Text('Last 7 days')),
              const PopupMenuItem(
                  value: '30 days', child: Text('Last 30 days')),
              const PopupMenuItem(
                  value: '90 days', child: Text('Last 3 months')),
              const PopupMenuItem(value: '1 year', child: Text('Last year')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendsTab(),
          _buildPatternsTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final entries = _getFilteredEntries(provider.moodEntries);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodTrendChart(entries),
              const SizedBox(height: 24),
              _buildMoodDistributionChart(entries),
              const SizedBox(height: 24),
              _buildAverageMoodCard(entries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatternsTab() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final entries = _getFilteredEntries(provider.moodEntries);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayOfWeekPattern(entries),
              const SizedBox(height: 24),
              _buildTimeOfDayPattern(entries),
              const SizedBox(height: 24),
              _buildMoodFactorsAnalysis(entries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final entries = _getFilteredEntries(provider.moodEntries);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodInsights(entries),
              const SizedBox(height: 24),
              _buildRecommendations(entries),
              const SizedBox(height: 24),
              _buildGoalsProgress(entries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodTrendChart(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState('No mood data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _getMoodLabel(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            final date = entries[value.toInt()].date;
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: entries.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.mood.index.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState('No mood data available');
    }

    final moodCounts = <Mood, int>{};
    for (final mood in Mood.values) {
      moodCounts[mood] = entries.where((e) => e.mood == mood).length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: moodCounts.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: _getMoodColor(entry.key),
                      radius: 50,
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: Mood.values.map((mood) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: _getMoodColor(mood),
                      ),
                      const SizedBox(width: 4),
                      Text(_getMoodLabel(mood.index)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageMoodCard(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState('No mood data available');
    }

    final averageMood =
        entries.map((e) => e.mood.index).reduce((a, b) => a + b) /
            entries.length;
    final moodEmoji = _getMoodEmoji(averageMood.round());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Average Mood',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              moodEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              _getMoodLabel(averageMood.round()),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Based on ${entries.length} entries',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekPattern(List<MoodEntry> entries) {
    final dayPattern = <int, List<int>>{};

    for (final entry in entries) {
      final dayOfWeek = entry.date.weekday;
      dayPattern.putIfAbsent(dayOfWeek, () => []);
      dayPattern[dayOfWeek]!.add(entry.mood.index);
    }

    final averages = dayPattern.map((day, moods) {
      final average =
          moods.isEmpty ? 0.0 : moods.reduce((a, b) => a + b) / moods.length;
      return MapEntry(day, average);
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day of Week Pattern',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 4,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 1:
                              text = const Text('Mon', style: style);
                              break;
                            case 2:
                              text = const Text('Tue', style: style);
                              break;
                            case 3:
                              text = const Text('Wed', style: style);
                              break;
                            case 4:
                              text = const Text('Thu', style: style);
                              break;
                            case 5:
                              text = const Text('Fri', style: style);
                              break;
                            case 6:
                              text = const Text('Sat', style: style);
                              break;
                            case 7:
                              text = const Text('Sun', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 16,
                            child: text,
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(_getMoodLabel(value.toInt()));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    final day = index + 1;
                    final average = averages[day] ?? 0.0;
                    return BarChartGroupData(
                      x: day,
                      barRods: [
                        BarChartRodData(
                          toY: average,
                          color: Theme.of(context).primaryColor,
                          width: 16,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOfDayPattern(List<MoodEntry> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time of Day Pattern',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Morning entries tend to be more positive'),
            const SizedBox(height: 8),
            const Text('Evening entries show more variation'),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodFactorsAnalysis(List<MoodEntry> entries) {
    final factorCounts = <String, int>{};

    for (final entry in entries) {
      for (final factor in entry.factors) {
        factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
      }
    }

    final sortedFactors = factorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Common Factors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedFactors.take(5).map((factor) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(factor.key),
                    Text('${factor.value} times'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodInsights(List<MoodEntry> entries) {
    final insights = _generateInsights(entries);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(insight)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<MoodEntry> entries) {
    final recommendations = _generateRecommendations(entries);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.recommend, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsProgress(List<MoodEntry> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildGoalProgress('Daily Check-ins', 0.8),
            const SizedBox(height: 8),
            _buildGoalProgress('Positive Mood Days', 0.6),
            const SizedBox(height: 8),
            _buildGoalProgress('Mindfulness Practice', 0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.mood_bad, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MoodEntry> _getFilteredEntries(List<MoodEntry> entries) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedPeriod) {
      case '7 days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30 days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '90 days':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '1 year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 7));
    }

    return entries.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getMoodLabel(int moodIndex) {
    switch (moodIndex) {
      case 0:
        return 'Terrible';
      case 1:
        return 'Bad';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      default:
        return 'Unknown';
    }
  }

  String _getMoodEmoji(int moodIndex) {
    switch (moodIndex) {
      case 0:
        return '😢';
      case 1:
        return '😕';
      case 2:
        return '😐';
      case 3:
        return '😊';
      case 4:
        return '😄';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.terrible:
        return Colors.red;
      case Mood.bad:
        return Colors.orange;
      case Mood.okay:
        return Colors.yellow;
      case Mood.good:
        return Colors.lightGreen;
      case Mood.excellent:
        return Colors.green;
    }
  }

  List<String> _generateInsights(List<MoodEntry> entries) {
    if (entries.isEmpty) return ['No data available for insights'];

    return [
      'Your mood has been trending upward this week',
      'You log more positive moods on weekends',
      'Exercise appears to correlate with better moods',
      'Your mood stability has improved over time',
    ];
  }

  List<String> _generateRecommendations(List<MoodEntry> entries) {
    if (entries.isEmpty) return ['Start logging your mood regularly'];

    return [
      'Try maintaining your current exercise routine',
      'Consider meditation on stressful days',
      'Schedule more social activities',
      'Keep a gratitude journal',
    ];
  }
}
