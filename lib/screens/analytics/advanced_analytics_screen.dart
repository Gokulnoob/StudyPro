import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/study_group_provider.dart';
import '../../services/ai_career_assistant.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '30 days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Insights'),
            Tab(icon: Icon(Icons.work), text: 'Career'),
            Tab(icon: Icon(Icons.psychology), text: 'Wellbeing'),
            Tab(icon: Icon(Icons.trending_up), text: 'Productivity'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
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
          _buildAIInsightsTab(),
          _buildCareerAnalyticsTab(),
          _buildWellbeingAnalyticsTab(),
          _buildProductivityAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildAIInsightsTab() {
    return Consumer3<JobApplicationProvider, MoodProvider, StudyGroupProvider>(
      builder: (context, jobProvider, moodProvider, studyProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _loadAIInsights(jobProvider, moodProvider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating AI insights...'),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error loading AI insights: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}), // Rebuild to retry
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            final aiInsights = data['aiInsights'] as Map<String, dynamic>;
            final moodCorrelation =
                data['moodCorrelation'] as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Success Score
                  _buildAISuccessScoreCard(aiInsights),
                  const SizedBox(height: 16),

                  // Personalized Recommendations
                  _buildRecommendationsCard(aiInsights),
                  const SizedBox(height: 16),

                  // Mood-Productivity Correlation
                  _buildMoodProductivityCard(moodCorrelation),
                  const SizedBox(height: 16),

                  // Optimal Timing Insights
                  _buildOptimalTimingCard(aiInsights),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadAIInsights(
    JobApplicationProvider jobProvider,
    MoodProvider moodProvider,
  ) async {
    final aiInsights = await AICareerAssistant.analyzeApplicationPattern(
      jobProvider.applications,
    );

    final moodCorrelation =
        await AICareerAssistant.analyzeMoodProductivityCorrelation(
      moodProvider.moodEntries,
      jobProvider.applications,
    );

    return {
      'aiInsights': aiInsights,
      'moodCorrelation': moodCorrelation,
    };
  }

  Widget _buildAISuccessScoreCard(Map<String, dynamic> insights) {
    final successScore = (insights['responseRate'] ?? 0.0) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'AI Success Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${successScore.toStringAsFixed(1)}%',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Application Success Rate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 100,
                    child: CircularProgressIndicator(
                      value: successScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        successScore > 20
                            ? Colors.green
                            : successScore > 10
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(Map<String, dynamic> insights) {
    final suggestions = insights['suggestions'] as List<String>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Recommendations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              const Text('Great job! You\'re following all best practices 🎉')
            else
              ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(suggestion)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodProductivityCard(Map<String, dynamic> correlation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Mood-Productivity Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your optimal mood range for job applications: ${correlation['optimalMoodRange']?['min']?.toStringAsFixed(1) ?? 'N/A'} - ${correlation['optimalMoodRange']?['max']?.toStringAsFixed(1) ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            const Text('💡 Tips based on your patterns:'),
            const SizedBox(height: 8),
            ...((correlation['productivityTips'] as List<String>?) ?? [])
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $tip'),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalTimingCard(Map<String, dynamic> insights) {
    final optimalDays =
        insights['optimalApplicationDays'] as List<String>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Optimal Timing',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Best days to apply: ${optimalDays.join(', ')}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Average response time: ${insights['averageResponseTime']?.toStringAsFixed(1) ?? 'N/A'} days',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerAnalyticsTab() {
    return const Center(child: Text('Career Analytics - Coming Soon'));
  }

  Widget _buildWellbeingAnalyticsTab() {
    return const Center(child: Text('Wellbeing Analytics - Coming Soon'));
  }

  Widget _buildProductivityAnalyticsTab() {
    return const Center(child: Text('Productivity Analytics - Coming Soon'));
  }
}
