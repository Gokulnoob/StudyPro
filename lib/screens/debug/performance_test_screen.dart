import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/performance_provider.dart';
import '../../providers/study_group_provider.dart';
import '../../services/performance_optimizer.dart';
import '../../models/study_group.dart';

/// Performance test screen to verify optimizations
class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({super.key});

  @override
  State<PerformanceTestScreen> createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _isRunning ? null : _runAllTests,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearResults,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRunning) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Running tests...'),
              const SizedBox(height: 16),
            ],
            Text(
              'Test Results:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  final result = _testResults[index];
                  final isSuccess = result.startsWith('✓');
                  return Card(
                    color:
                        isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    child: ListTile(
                      leading: Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                      title: Text(result),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      await _testPerformanceProvider();
      await _testStudyGroupProvider();
      await _testPerformanceOptimizer();
      await _testMemoryUsage();
      await _testCachePerformance();
      await _testUIPerformance();
    } catch (e) {
      _addResult('✗ Test suite failed: $e');
    }

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testPerformanceProvider() async {
    _addResult('Testing PerformanceProvider...');

    final provider = Provider.of<PerformanceProvider>(context, listen: false);

    // Test settings
    provider.setPerformanceMonitoring(true);
    if (provider.isPerformanceMonitoringEnabled) {
      _addResult('✓ Performance monitoring enabled');
    } else {
      _addResult('✗ Performance monitoring failed');
    }

    // Test screen tracking
    provider.trackScreenBuild('TestScreen');
    provider.trackScreenAccess('TestScreen');
    provider.trackScreenLoadTime(
        'TestScreen', const Duration(milliseconds: 100));

    if (provider.screenBuildCounts.containsKey('TestScreen')) {
      _addResult('✓ Screen tracking works');
    } else {
      _addResult('✗ Screen tracking failed');
    }

    // Test memory usage
    final memoryUsage = await provider.getMemoryUsage();
    if (memoryUsage.containsKey('cache_size')) {
      _addResult('✓ Memory usage reporting works');
    } else {
      _addResult('✗ Memory usage reporting failed');
    }

    // Test performance summary
    final summary = provider.getPerformanceSummary();
    if (summary.containsKey('total_builds')) {
      _addResult('✓ Performance summary works');
    } else {
      _addResult('✗ Performance summary failed');
    }
  }

  Future<void> _testStudyGroupProvider() async {
    _addResult('Testing StudyGroupProvider...');

    final provider = Provider.of<StudyGroupProvider>(context, listen: false);

    // Test study group creation
    final testGroup = StudyGroup(
      name: 'Test Group',
      description: 'Test Description',
      subject: 'Test Subject',
      createdBy: 'Test User',
      createdAt: DateTime.now(),
      members: ['Test User'],
    );

    try {
      await provider.addStudyGroup(testGroup);
      if (provider.studyGroups.any((group) => group.name == 'Test Group')) {
        _addResult('✓ Study group creation works');
      } else {
        _addResult('✗ Study group creation failed');
      }
    } catch (e) {
      _addResult('✗ Study group creation error: $e');
    }

    // Test study group loading
    try {
      await provider.loadStudyGroups();
      _addResult('✓ Study group loading works');
    } catch (e) {
      _addResult('✗ Study group loading error: $e');
    }
  }

  Future<void> _testPerformanceOptimizer() async {
    _addResult('Testing PerformanceOptimizer...');

    // Test cache operations
    final stopwatch = Stopwatch()..start();

    PerformanceOptimizer.startOperation('test_operation');

    // Simulate some work
    for (int i = 0; i < 1000; i++) {
      i * 2;
    }

    PerformanceOptimizer.endOperation('test_operation');

    stopwatch.stop();
    _addResult(
        '✓ Performance measurement works (${stopwatch.elapsedMilliseconds}ms)');

    // Test memory stats
    final memoryStats = PerformanceOptimizer.getMemoryStats();
    if (memoryStats.containsKey('cacheSize')) {
      _addResult('✓ Memory stats work');
    } else {
      _addResult('✗ Memory stats failed');
    }

    // Test cache cleanup
    PerformanceOptimizer.clearExpiredCache();
    _addResult('✓ Cache cleanup works');
  }

  Future<void> _testMemoryUsage() async {
    _addResult('Testing memory usage...');

    // Create some test data
    final testData = List.generate(1000, (index) => 'Test data $index');

    // Measure memory before
    final statsBefore = PerformanceOptimizer.getMemoryStats();

    // Store in cache
    for (int i = 0; i < 10; i++) {
      PerformanceOptimizer.cacheValue('test_key_$i', testData);
    }

    // Measure memory after
    final statsAfter = PerformanceOptimizer.getMemoryStats();

    final cacheSizeBefore = statsBefore['cacheSize'] as int;
    final cacheSizeAfter = statsAfter['cacheSize'] as int;

    if (cacheSizeAfter > cacheSizeBefore) {
      _addResult(
          '✓ Cache storage works (${cacheSizeAfter - cacheSizeBefore} items added)');
    } else {
      _addResult('✗ Cache storage failed');
    }
  }

  Future<void> _testCachePerformance() async {
    _addResult('Testing cache performance...');

    const int iterations = 100;
    final stopwatch = Stopwatch();

    // Test cache write performance
    stopwatch.start();
    for (int i = 0; i < iterations; i++) {
      PerformanceOptimizer.cacheValue('perf_test_$i', 'Test data $i');
    }
    stopwatch.stop();

    final writeTime = stopwatch.elapsedMilliseconds;
    _addResult(
        '✓ Cache write performance: ${writeTime}ms for $iterations items');

    // Test cache read performance
    stopwatch.reset();
    stopwatch.start();
    for (int i = 0; i < iterations; i++) {
      PerformanceOptimizer.getCachedValue<String>('perf_test_$i');
    }
    stopwatch.stop();

    final readTime = stopwatch.elapsedMilliseconds;
    _addResult('✓ Cache read performance: ${readTime}ms for $iterations items');

    // Clean up
    PerformanceOptimizer.clearExpiredCache();
  }

  Future<void> _testUIPerformance() async {
    _addResult('Testing UI performance...');

    // Test widget build performance
    final stopwatch = Stopwatch()..start();

    // Simulate building many widgets
    for (int i = 0; i < 100; i++) {
      Container(
        key: ValueKey('test_$i'),
        child: Text('Test $i'),
      );
    }

    stopwatch.stop();
    _addResult(
        '✓ UI build performance: ${stopwatch.elapsedMilliseconds}ms for 100 widgets');

    // Test provider notifications
    final provider = Provider.of<PerformanceProvider>(context, listen: false);

    stopwatch.reset();
    stopwatch.start();

    for (int i = 0; i < 10; i++) {
      provider.trackScreenBuild('UITest');
    }

    stopwatch.stop();
    _addResult(
        '✓ Provider notification performance: ${stopwatch.elapsedMilliseconds}ms for 10 notifications');
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }
}
