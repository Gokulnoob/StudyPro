import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Memory-optimized cache with LRU eviction policy
class MemoryCache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  MemoryCache(this._maxSize);

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recently used)
    }
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= _maxSize) {
      // Remove least recently used item
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  void clear() {
    _cache.clear();
  }

  int get size => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;
}

/// Performance monitoring and optimization helper
class PerformanceOptimizer {
  static final Map<String, DateTime> _operationTimes = {};
  static final MemoryCache<String, dynamic> _cache = MemoryCache(100);

  /// Start timing an operation
  static void startOperation(String operationName) {
    _operationTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and log if it's slow
  static void endOperation(String operationName, {int slowThresholdMs = 100}) {
    final startTime = _operationTimes.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      if (duration.inMilliseconds > slowThresholdMs) {
        debugPrint(
            '⚠️ Slow operation: $operationName took ${duration.inMilliseconds}ms');
      }
    }
  }

  /// Cache a value with automatic expiration
  static void cacheValue(String key, dynamic value, {Duration? expiration}) {
    final cacheKey = expiration != null
        ? '${key}_${DateTime.now().add(expiration).millisecondsSinceEpoch}'
        : key;
    _cache.put(cacheKey, value);
  }

  /// Get cached value if not expired
  static T? getCachedValue<T>(String key) {
    // Check for exact key first
    var value = _cache.get(key);
    if (value != null) return value as T;

    // Check for expiring keys
    for (final cacheKey in _cache._cache.keys) {
      if (cacheKey.startsWith(key + '_')) {
        final timestampStr = cacheKey.split('_').last;
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null &&
            DateTime.now().millisecondsSinceEpoch < timestamp) {
          return _cache.get(cacheKey) as T;
        }
      }
    }
    return null;
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];

    for (final key in _cache._cache.keys) {
      if (key.contains('_')) {
        final timestampStr = key.split('_').last;
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null && now >= timestamp) {
          expiredKeys.add(key);
        }
      }
    }

    for (final key in expiredKeys) {
      _cache._cache.remove(key);
    }
  }

  /// Get memory usage statistics
  static Map<String, dynamic> getMemoryStats() {
    return {
      'cacheSize': _cache.size,
      'activeOperations': _operationTimes.length,
      'cacheKeys': _cache._cache.keys.toList(),
    };
  }
}

/// Debouncer for expensive operations
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
