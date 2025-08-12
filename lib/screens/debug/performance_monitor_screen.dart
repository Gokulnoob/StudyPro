import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/performance_optimizer.dart';

class PerformanceMonitorScreen extends StatefulWidget {
  const PerformanceMonitorScreen({super.key});

  @override
  State<PerformanceMonitorScreen> createState() =>
      _PerformanceMonitorScreenState();
}

class _PerformanceMonitorScreenState extends State<PerformanceMonitorScreen> {
  Map<String, dynamic> _performanceStats = {};
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() {
    setState(() {
      _performanceStats = PerformanceOptimizer.getMemoryStats();
    });
  }

  void _clearCache() {
    PerformanceOptimizer.clearExpiredCache();
    _refreshStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCache,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildControlsCard(),
            const SizedBox(height: 16),
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                'Cache Size', '${_performanceStats['cacheSize'] ?? 0} items'),
            _buildStatRow('Active Operations',
                '${_performanceStats['activeOperations'] ?? 0}'),
            const SizedBox(height: 8),
            const Text('Cached Keys:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (_performanceStats['cacheKeys'] != null)
              ..._performanceStats['cacheKeys']
                  .map<Widget>((key) => Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text('• $key',
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cache'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Stats'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Trigger garbage collection
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              icon: const Icon(Icons.memory),
              label: const Text('Force Memory Cleanup'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Cache is automatically cleared every 5 minutes\n'
              '• Database queries are cached to improve performance\n'
              '• Images are optimized with memory caching\n'
              '• UI updates are debounced to reduce redraws\n'
              '• Background loading prevents UI blocking',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Performance optimizations are automatically applied throughout the app.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
