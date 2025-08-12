import 'package:flutter/foundation.dart';
import '../models/study_group.dart';
import '../services/database_helper.dart';
import '../services/study_group_storage.dart';
import '../services/performance_optimizer.dart';

class StudyGroupProvider with ChangeNotifier {
  List<StudyGroup> _studyGroups = [];
  List<StudySession> _studySessions = [];
  bool _isLoading = false;
  DateTime? _lastLoadTime;
  final Debouncer _notifyDebouncer = Debouncer(milliseconds: 100);

  List<StudyGroup> get studyGroups => _studyGroups;
  List<StudySession> get studySessions => _studySessions;
  bool get isLoading => _isLoading;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  StudyGroupProvider() {
    // Removed automatic loading to prevent startup issues
    // Call loadStudyGroups() manually when needed
  }

  Future<void> loadStudyGroups({bool forceRefresh = false}) async {
    // Prevent excessive loading - throttle to once per minute unless forced
    if (!forceRefresh &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!).inMinutes < 1) {
      debugPrint('Study groups loaded recently, skipping reload');
      return;
    }

    PerformanceOptimizer.startOperation('loadStudyGroups');

    _isLoading = true;
    _notifyDebouncer.run(() => notifyListeners());

    try {
      // Try to load from SQLite database first
      _studyGroups = await _databaseHelper.getStudyGroups();
      debugPrint(
          'Loaded ${_studyGroups.length} study groups from SQLite database');

      // If SQLite fails or returns no data, try SharedPreferences
      if (_studyGroups.isEmpty) {
        _studyGroups = await StudyGroupStorage.getStudyGroups();
        debugPrint(
            'Loaded ${_studyGroups.length} study groups from SharedPreferences');
      }

      _lastLoadTime = DateTime.now();

      if (kDebugMode) {
        for (var group in _studyGroups) {
          debugPrint('Group: ${group.name} (ID: ${group.id})');
        }
      }
    } catch (e) {
      debugPrint('Error loading study groups from SQLite: $e');

      // Fallback to SharedPreferences
      try {
        _studyGroups = await StudyGroupStorage.getStudyGroups();
        debugPrint(
            'Fallback: Loaded ${_studyGroups.length} study groups from SharedPreferences');
      } catch (e2) {
        debugPrint('Error loading study groups from SharedPreferences: $e2');
        _studyGroups = [];
      }
    }

    _isLoading = false;
    PerformanceOptimizer.endOperation('loadStudyGroups');
    _notifyDebouncer.run(() => notifyListeners());
  }

  Future<void> addStudyGroup(StudyGroup group) async {
    try {
      await _databaseHelper.insertStudyGroup(group);
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error adding study group: $e');
    }
  }

  Future<void> updateStudyGroup(StudyGroup group) async {
    try {
      await _databaseHelper.updateStudyGroup(group);
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error updating study group: $e');
    }
  }

  Future<void> deleteStudyGroup(int id) async {
    try {
      await _databaseHelper.deleteStudyGroup(id);
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error deleting study group: $e');
    }
  }

  Future<void> loadStudySessionsForGroup(int groupId) async {
    try {
      _studySessions = await _databaseHelper.getStudySessionsForGroup(groupId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading study sessions: $e');
    }
  }

  Future<void> addStudySession(StudySession session) async {
    try {
      await _databaseHelper.insertStudySession(session);
      await loadStudySessionsForGroup(session.groupId);
    } catch (e) {
      debugPrint('Error adding study session: $e');
    }
  }

  Future<void> updateStudySession(StudySession session) async {
    try {
      await _databaseHelper.updateStudySession(session);
      await loadStudySessionsForGroup(session.groupId);
    } catch (e) {
      debugPrint('Error updating study session: $e');
    }
  }

  Future<void> deleteStudySession(int id, int groupId) async {
    try {
      await _databaseHelper.deleteStudySession(id);
      await loadStudySessionsForGroup(groupId);
    } catch (e) {
      debugPrint('Error deleting study session: $e');
    }
  }

  List<StudyGroup> get activeGroups =>
      _studyGroups.where((group) => group.isActive).toList();

  List<StudyGroup> getGroupsBySubject(String subject) {
    return _studyGroups
        .where((group) =>
            group.subject.toLowerCase().contains(subject.toLowerCase()))
        .toList();
  }

  StudyGroup? getGroupById(int id) {
    try {
      return _studyGroups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  List<StudyGroup> getGroupsCreatedByUser(String userId) {
    return _studyGroups.where((group) => group.createdBy == userId).toList();
  }

  List<StudyGroup> getGroupsForUser(String userId) {
    return _studyGroups
        .where((group) =>
            group.members.contains(userId) || group.createdBy == userId)
        .toList();
  }

  int get totalGroups => _studyGroups.length;
  int get activeGroupsCount => activeGroups.length;

  Future<void> joinGroup(int groupId) async {
    try {
      final group = getGroupById(groupId);
      if (group != null) {
        // In a real app, you would add the current user ID to the members list
        // For now, just refresh the groups to simulate the action
        await loadStudyGroups();
      }
    } catch (e) {
      debugPrint('Error joining group: $e');
    }
  }

  Future<void> leaveGroup(int groupId) async {
    try {
      final group = getGroupById(groupId);
      if (group != null) {
        // In a real app, you would remove the current user ID from the members list
        // For now, just refresh the groups to simulate the action
        await loadStudyGroups();
      }
    } catch (e) {
      debugPrint('Error leaving group: $e');
    }
  }

  Future<void> createStudyGroup(StudyGroup group) async {
    try {
      debugPrint('Creating study group: ${group.name}');

      // Try to save to SQLite database first
      int id = 0;
      try {
        id = await _databaseHelper.insertStudyGroup(group);
        debugPrint('Study group created in SQLite database with ID: $id');
      } catch (e) {
        debugPrint('Error saving to SQLite database: $e');
      }

      // Also save to SharedPreferences as backup
      try {
        await StudyGroupStorage.saveStudyGroup(group);
        debugPrint('Study group also saved to SharedPreferences');
      } catch (e) {
        debugPrint('Error saving to SharedPreferences: $e');
      }

      // Reload the study groups
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error creating study group: $e');
    }
  }

  Future<void> deleteGroup(int id) async {
    try {
      await _databaseHelper.deleteStudyGroup(id);
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error deleting study group: $e');
    }
  }

  Future<void> joinStudyGroup(int? groupId) async {
    if (groupId == null) return;
    try {
      final group = getGroupById(groupId);
      if (group != null) {
        // In a real app, you would add the current user ID to the members list
        // For now, just refresh the groups to simulate the action
        await loadStudyGroups();
      }
    } catch (e) {
      debugPrint('Error joining study group: $e');
    }
  }

  Future<void> joinStudyGroupByCode(String code) async {
    try {
      // In a real app, you would find the group by code and join it
      // For now, just refresh the groups to simulate the action
      await loadStudyGroups();
    } catch (e) {
      debugPrint('Error joining study group by code: $e');
    }
  }
}
