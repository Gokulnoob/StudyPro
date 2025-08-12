import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/database_helper.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  MoodProvider() {
    // Removed automatic loading to prevent startup issues
    // Call loadMoodEntries() manually when needed
  }

  Future<void> loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodEntries = await _databaseHelper.getMoodEntries();
      debugPrint('Loaded ${_moodEntries.length} mood entries from database');
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      final id = await _databaseHelper.insertMoodEntry(entry);
      debugPrint('Added mood entry with ID: $id');
      await loadMoodEntries();
      debugPrint('After adding, total entries: ${_moodEntries.length}');
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
    }
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    try {
      await _databaseHelper.updateMoodEntry(entry);
      await loadMoodEntries();
    } catch (e) {
      debugPrint('Error updating mood entry: $e');
    }
  }

  Future<void> deleteMoodEntry(int id) async {
    try {
      await _databaseHelper.deleteMoodEntry(id);
      await loadMoodEntries();
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    }
  }

  MoodEntry? getTodaysMoodEntry() {
    final today = DateTime.now();
    try {
      return _moodEntries.firstWhere((entry) =>
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day);
    } catch (e) {
      return null;
    }
  }

  List<MoodEntry> getWeeklyMoodEntries() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _moodEntries.where((entry) {
      return entry.date.isAfter(weekAgo) ||
          entry.date.isAtSameMomentAs(weekAgo);
    }).toList();
  }

  List<MoodEntry> getMonthlyMoodEntries() {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return _moodEntries.where((entry) {
      return entry.date.isAfter(monthAgo) ||
          entry.date.isAtSameMomentAs(monthAgo);
    }).toList();
  }

  double get averageMoodLevel {
    if (_moodEntries.isEmpty) return 0.0;
    double sum = _moodEntries.fold(0.0, (sum, entry) => sum + entry.moodLevel);
    return sum / _moodEntries.length;
  }

  double get weeklyAverageMoodLevel {
    final weeklyEntries = getWeeklyMoodEntries();
    if (weeklyEntries.isEmpty) return 0.0;
    double sum = weeklyEntries.fold(0.0, (sum, entry) => sum + entry.moodLevel);
    return sum / weeklyEntries.length;
  }

  Map<int, int> get moodDistribution {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var entry in _moodEntries) {
      distribution[entry.moodLevel] = (distribution[entry.moodLevel] ?? 0) + 1;
    }
    return distribution;
  }

  bool get hasTodaysEntry {
    return getTodaysMoodEntry() != null;
  }

  int get streakDays {
    if (_moodEntries.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      bool hasEntry = _moodEntries.any((entry) =>
          entry.date.year == currentDate.year &&
          entry.date.month == currentDate.month &&
          entry.date.day == currentDate.day);

      if (hasEntry) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
