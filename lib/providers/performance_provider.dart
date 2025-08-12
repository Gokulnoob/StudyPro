import 'package:flutter/foundation.dart';
import '../services/performance_optimizer.dart';

/// Provider for managing app-wide performance optimizations and metrics
class PerformanceProvider extends ChangeNotifier {
  static final PerformanceProvider _instance = PerformanceProvider._internal();
  factory PerformanceProvider() => _instance;
  PerformanceProvider._internal();

  bool _isPerformanceMonitoringEnabled = false;
  bool _isMemoryOptimizationEnabled = true;
  bool _isImageCacheOptimizationEnabled = true;
  bool _isListOptimizationEnabled = true;

  final Map<String, int> _screenBuildCounts = {};
  final Map<String, DateTime> _screenLastAccessed = {};
  final Map<String, Duration> _screenLoadTimes = {};

  // Performance settings
  bool get isPerformanceMonitoringEnabled => _isPerformanceMonitoringEnabled;
  bool get isMemoryOptimizationEnabled => _isMemoryOptimizationEnabled;
  bool get isImageCacheOptimizationEnabled => _isImageCacheOptimizationEnabled;
  bool get isListOptimizationEnabled => _isListOptimizationEnabled;

  // Performance metrics
  Map<String, int> get screenBuildCounts =>
      Map.unmodifiable(_screenBuildCounts);
  Map<String, DateTime> get screenLastAccessed =>
      Map.unmodifiable(_screenLastAccessed);
  Map<String, Duration> get screenLoadTimes =>
      Map.unmodifiable(_screenLoadTimes);

  /// Enable/disable performance monitoring
  void setPerformanceMonitoring(bool enabled) {
    if (_isPerformanceMonitoringEnabled != enabled) {
      _isPerformanceMonitoringEnabled = enabled;
      notifyListeners();
    }
  }

  /// Enable/disable memory optimization
  void setMemoryOptimization(bool enabled) {
    if (_isMemoryOptimizationEnabled != enabled) {
      _isMemoryOptimizationEnabled = enabled;
      if (enabled) {
        PerformanceOptimizer.clearExpiredCache();
      }
      notifyListeners();
    }
  }

  /// Enable/disable image cache optimization
  void setImageCacheOptimization(bool enabled) {
    if (_isImageCacheOptimizationEnabled != enabled) {
      _isImageCacheOptimizationEnabled = enabled;
      notifyListeners();
    }
  }

  /// Enable/disable list optimization
  void setListOptimization(bool enabled) {
    if (_isListOptimizationEnabled != enabled) {
      _isListOptimizationEnabled = enabled;
      notifyListeners();
    }
  }

  /// Track screen build count
  void trackScreenBuild(String screenName) {
    if (!_isPerformanceMonitoringEnabled) return;

    _screenBuildCounts[screenName] = (_screenBuildCounts[screenName] ?? 0) + 1;
    notifyListeners();
  }

  /// Track screen access
  void trackScreenAccess(String screenName) {
    if (!_isPerformanceMonitoringEnabled) return;

    _screenLastAccessed[screenName] = DateTime.now();
    notifyListeners();
  }

  /// Track screen load time
  void trackScreenLoadTime(String screenName, Duration loadTime) {
    if (!_isPerformanceMonitoringEnabled) return;

    _screenLoadTimes[screenName] = loadTime;
    notifyListeners();
  }

  /// Get memory usage information
  Future<Map<String, dynamic>> getMemoryUsage() async {
    final memoryStats = PerformanceOptimizer.getMemoryStats();
    return {
      'cache_size': memoryStats['cacheSize'],
      'active_operations': memoryStats['activeOperations'],
      'cache_keys': memoryStats['cacheKeys'],
    };
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final totalBuilds =
        _screenBuildCounts.values.fold(0, (sum, count) => sum + count);
    final avgLoadTime = _screenLoadTimes.values.isEmpty
        ? Duration.zero
        : Duration(
            microseconds: _screenLoadTimes.values
                    .map((d) => d.inMicroseconds)
                    .fold(0, (sum, duration) => sum + duration) ~/
                _screenLoadTimes.length);

    return {
      'total_builds': totalBuilds,
      'average_load_time': avgLoadTime,
      'monitored_screens': _screenBuildCounts.length,
      'memory_optimization_enabled': _isMemoryOptimizationEnabled,
      'image_cache_optimization_enabled': _isImageCacheOptimizationEnabled,
      'list_optimization_enabled': _isListOptimizationEnabled,
    };
  }

  /// Clear performance data
  void clearPerformanceData() {
    _screenBuildCounts.clear();
    _screenLastAccessed.clear();
    _screenLoadTimes.clear();
    PerformanceOptimizer.clearExpiredCache();
    notifyListeners();
  }

  /// Optimize app performance
  Future<void> optimizePerformance() async {
    if (_isMemoryOptimizationEnabled) {
      PerformanceOptimizer.clearExpiredCache();
    }

    notifyListeners();
  }

  /// Get optimization recommendations
  List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];

    // Check for screens with high build counts
    final highBuildScreens = _screenBuildCounts.entries
        .where((entry) => entry.value > 10)
        .map((entry) => entry.key)
        .toList();

    if (highBuildScreens.isNotEmpty) {
      recommendations.add(
          'Consider optimizing screens with high rebuild counts: ${highBuildScreens.join(", ")}');
    }

    // Check for slow loading screens
    final slowScreens = _screenLoadTimes.entries
        .where((entry) => entry.value.inMilliseconds > 500)
        .map((entry) => entry.key)
        .toList();

    if (slowScreens.isNotEmpty) {
      recommendations.add(
          'Consider optimizing slow loading screens: ${slowScreens.join(", ")}');
    }

    // Check memory usage
    final memoryStats = PerformanceOptimizer.getMemoryStats();
    final cacheSize = memoryStats['cacheSize'] as int;
    if (cacheSize > 80) {
      // 80% of cache limit
      recommendations
          .add('Consider reducing cache size (current: $cacheSize items)');
    }

    return recommendations;
  }
}
