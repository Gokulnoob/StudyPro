import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/study_group.dart';

class StudyGroupStorage {
  static const String _keyStudyGroups = 'study_groups';
  static const String _keyNextId = 'next_study_group_id';

  static Future<void> saveStudyGroup(StudyGroup group) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing groups
      final existingGroups = await getStudyGroups();

      // Assign ID if not present
      StudyGroup groupToSave = group;
      if (group.id == null) {
        final nextId = await _getNextId();
        groupToSave = group.copyWith(id: nextId);
        await _incrementNextId();
      }

      // Add to list
      existingGroups.add(groupToSave);

      // Convert to JSON and save
      final groupsJson = existingGroups.map((g) => g.toJson()).toList();
      await prefs.setString(_keyStudyGroups, jsonEncode(groupsJson));

      debugPrint(
          'Study group saved to SharedPreferences: ${groupToSave.name} (ID: ${groupToSave.id})');
    } catch (e) {
      debugPrint('Error saving study group to SharedPreferences: $e');
    }
  }

  static Future<List<StudyGroup>> getStudyGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getString(_keyStudyGroups);

      if (groupsJson == null) {
        debugPrint('No study groups found in SharedPreferences');
        return [];
      }

      final List<dynamic> groupsList = jsonDecode(groupsJson);
      final groups =
          groupsList.map((json) => StudyGroup.fromJson(json)).toList();

      debugPrint(
          'Retrieved ${groups.length} study groups from SharedPreferences');
      return groups;
    } catch (e) {
      debugPrint('Error retrieving study groups from SharedPreferences: $e');
      return [];
    }
  }

  static Future<void> deleteStudyGroup(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingGroups = await getStudyGroups();

      existingGroups.removeWhere((group) => group.id == id);

      final groupsJson = existingGroups.map((g) => g.toJson()).toList();
      await prefs.setString(_keyStudyGroups, jsonEncode(groupsJson));

      debugPrint('Study group deleted from SharedPreferences: ID $id');
    } catch (e) {
      debugPrint('Error deleting study group from SharedPreferences: $e');
    }
  }

  static Future<void> updateStudyGroup(StudyGroup group) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingGroups = await getStudyGroups();

      final index = existingGroups.indexWhere((g) => g.id == group.id);
      if (index != -1) {
        existingGroups[index] = group;

        final groupsJson = existingGroups.map((g) => g.toJson()).toList();
        await prefs.setString(_keyStudyGroups, jsonEncode(groupsJson));

        debugPrint(
            'Study group updated in SharedPreferences: ${group.name} (ID: ${group.id})');
      }
    } catch (e) {
      debugPrint('Error updating study group in SharedPreferences: $e');
    }
  }

  static Future<int> _getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNextId) ?? 1;
  }

  static Future<void> _incrementNextId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = await _getNextId();
    await prefs.setInt(_keyNextId, nextId + 1);
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStudyGroups);
      await prefs.remove(_keyNextId);
      debugPrint('All study group data cleared from SharedPreferences');
    } catch (e) {
      debugPrint('Error clearing study group data: $e');
    }
  }
}
