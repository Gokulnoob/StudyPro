import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/job_application_provider.dart';

class JobAnalyticsScreen extends StatelessWidget {
  const JobAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Application Analytics'),
      ),
      body: Consumer<JobApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.applications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No data to analyze',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some job applications to see your analytics',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Stats
                _buildOverviewStats(provider),
                const SizedBox(height: 24),

                // Status Distribution Chart
                Text(
                  'Application Status Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildStatusChart(provider),
                const SizedBox(height: 24),

                // Success Rate
                _buildSuccessRateCard(provider),
                const SizedBox(height: 24),

                // Monthly Progress
                Text(
                  'Monthly Application Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildMonthlyChart(provider),
                const SizedBox(height: 24),

                // Insights
                _buildInsightsCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewStats(JobApplicationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Applications',
                    '${provider.totalApplications}',
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Response Rate',
                    '${_calculateResponseRate(provider)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Interviews',
                    '${provider.interviewApplications}',
                    Icons.person,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Offers',
                    '${provider.offerApplications}',
                    Icons.star,
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

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChart(JobApplicationProvider provider) {
    final statusData = _getStatusData(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: statusData.entries.map((entry) {
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '${entry.value}',
                        color: _getStatusColor(entry.key),
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: statusData.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getStatusColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRateCard(JobApplicationProvider provider) {
    final responseRate = _calculateResponseRate(provider);
    final interviewRate = _calculateInterviewRate(provider);
    final offerRate = _calculateOfferRate(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Success Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressIndicator('Response Rate', responseRate, Colors.blue),
            const SizedBox(height: 12),
            _buildProgressIndicator(
                'Interview Rate', interviewRate, Colors.orange),
            const SizedBox(height: 12),
            _buildProgressIndicator('Offer Rate', offerRate, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String title, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(JobApplicationProvider provider) {
    final monthlyData = _getMonthlyData(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: monthlyData.entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      if (value.toInt() < months.length) {
                        return Text(
                          months[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard(JobApplicationProvider provider) {
    final insights = _generateInsights(provider);

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
                  'Insights & Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        insight.isPositive ? Icons.trending_up : Icons.info,
                        color:
                            insight.isPositive ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(insight.message),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getStatusData(JobApplicationProvider provider) {
    return {
      'Applied': provider.getApplicationsByStatus('Applied').length,
      'Interview': provider.getApplicationsByStatus('Interview').length,
      'Offer': provider.getApplicationsByStatus('Offer').length,
      'Rejected': provider.getApplicationsByStatus('Rejected').length,
      'Pending': provider.getApplicationsByStatus('Pending').length,
    };
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return Colors.blue;
      case 'Interview':
        return Colors.orange;
      case 'Offer':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  double _calculateResponseRate(JobApplicationProvider provider) {
    if (provider.totalApplications == 0) return 0;
    final responses =
        provider.interviewApplications + provider.offerApplications;
    return (responses / provider.totalApplications) * 100;
  }

  double _calculateInterviewRate(JobApplicationProvider provider) {
    if (provider.totalApplications == 0) return 0;
    return (provider.interviewApplications / provider.totalApplications) * 100;
  }

  double _calculateOfferRate(JobApplicationProvider provider) {
    if (provider.totalApplications == 0) return 0;
    return (provider.offerApplications / provider.totalApplications) * 100;
  }

  Map<int, int> _getMonthlyData(JobApplicationProvider provider) {
    // Simplified monthly data - in real app, you'd parse actual dates
    return {
      0: 2, // January
      1: 5, // February
      2: 8, // March
      3: 12, // April
      4: 15, // May
      5: provider.totalApplications, // June (current)
    };
  }

  List<Insight> _generateInsights(JobApplicationProvider provider) {
    List<Insight> insights = [];

    final responseRate = _calculateResponseRate(provider);
    final totalApps = provider.totalApplications;

    if (responseRate > 20) {
      insights.add(Insight(
        'Great response rate! You\'re getting ${responseRate.toStringAsFixed(1)}% responses.',
        true,
      ));
    } else if (responseRate < 10 && totalApps > 5) {
      insights.add(Insight(
        'Consider improving your resume or targeting more relevant positions.',
        false,
      ));
    }

    if (provider.offerApplications > 0) {
      insights.add(Insight(
        'Congratulations on receiving ${provider.offerApplications} offer${provider.offerApplications > 1 ? 's' : ''}!',
        true,
      ));
    }

    if (totalApps < 10) {
      insights.add(Insight(
        'Try to apply to more positions to increase your chances of success.',
        false,
      ));
    }

    return insights;
  }
}

class Insight {
  final String message;
  final bool isPositive;

  Insight(this.message, this.isPositive);
}
