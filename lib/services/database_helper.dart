import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/job_application.dart';
import '../models/mood_entry.dart';
import '../models/study_group.dart';
import 'permission_helper.dart';
import 'performance_optimizer.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Check permissions first on mobile devices
    await _checkPermissions();

    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions = await PermissionHelper.checkStoragePermissions();
      if (!hasPermissions) {
        debugPrint('Storage permissions not granted, requesting...');
        await PermissionHelper.requestStoragePermissions();
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'studypro.db');
      debugPrint('Database path: $path');

      return await openDatabase(
        path,
        version: 2, // Increment version to trigger database update
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop and recreate tables to fix schema issues
      await db.execute('DROP TABLE IF EXISTS study_groups');
      await db.execute('DROP TABLE IF EXISTS mood_entries');
      await db.execute('DROP TABLE IF EXISTS job_applications');
      await db.execute('DROP TABLE IF EXISTS study_sessions');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create job applications table
    await db.execute('''
      CREATE TABLE job_applications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        position TEXT NOT NULL,
        status TEXT NOT NULL,
        applicationDate TEXT NOT NULL,
        deadline TEXT,
        notes TEXT,
        contactEmail TEXT,
        jobUrl TEXT,
        salary TEXT,
        location TEXT
      )
    ''');

    // Create mood entries table
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        moodLevel INTEGER NOT NULL,
        mood INTEGER NOT NULL,
        notes TEXT,
        activities TEXT,
        factors TEXT,
        sleepHours INTEGER,
        stressLevel INTEGER,
        energyLevel INTEGER
      )
    ''');

    // Create study groups table
    await db.execute('''
      CREATE TABLE study_groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        subject TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        members TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        meetingLink TEXT,
        nextSession TEXT,
        isOnline INTEGER NOT NULL DEFAULT 1,
        location TEXT,
        maxMembers INTEGER NOT NULL DEFAULT 10,
        isPrivate INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        meetingSchedule TEXT
      )
    ''');

    // Create study sessions table
    await db.execute('''
      CREATE TABLE study_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        scheduledDate TEXT NOT NULL,
        notes TEXT,
        attendees TEXT NOT NULL,
        FOREIGN KEY (groupId) REFERENCES study_groups (id)
      )
    ''');
  }

  // Job Application CRUD operations
  Future<int> insertJobApplication(JobApplication application) async {
    final db = await database;
    return await db.insert('job_applications', application.toMap());
  }

  Future<List<JobApplication>> getJobApplications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('job_applications');
    return List.generate(maps.length, (i) {
      return JobApplication.fromMap(maps[i]);
    });
  }

  Future<void> updateJobApplication(JobApplication application) async {
    final db = await database;
    await db.update(
      'job_applications',
      application.toMap(),
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  Future<void> deleteJobApplication(int id) async {
    final db = await database;
    await db.delete(
      'job_applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mood Entry CRUD operations
  Future<int> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    final map = entry.toMap();
    debugPrint('Inserting mood entry: $map');
    final id = await db.insert('mood_entries', map);
    debugPrint('Inserted mood entry with ID: $id');
    return id;
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('mood_entries', orderBy: 'date DESC');
    debugPrint('Retrieved ${maps.length} mood entries from database');
    return List.generate(maps.length, (i) {
      return MoodEntry.fromMap(maps[i]);
    });
  }

  Future<List<MoodEntry>> getMoodEntriesForDateRange(
      String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) {
      return MoodEntry.fromMap(maps[i]);
    });
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteMoodEntry(int id) async {
    final db = await database;
    await db.delete(
      'mood_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Study Group CRUD operations
  Future<int> insertStudyGroup(StudyGroup group) async {
    PerformanceOptimizer.startOperation('insertStudyGroup');
    try {
      final db = await database;
      final map = group.toMap();
      debugPrint('Inserting study group: ${group.name}');

      final result = await db.insert('study_groups', map);
      debugPrint('Study group inserted with ID: $result');

      PerformanceOptimizer.endOperation('insertStudyGroup');
      return result;
    } catch (e) {
      debugPrint('Error inserting study group: $e');
      PerformanceOptimizer.endOperation('insertStudyGroup');
      rethrow;
    }
  }

  Future<List<StudyGroup>> getStudyGroups() async {
    PerformanceOptimizer.startOperation('getStudyGroups');

    // Check cache first
    final cachedGroups =
        PerformanceOptimizer.getCachedValue<List<StudyGroup>>('study_groups');
    if (cachedGroups != null) {
      debugPrint('Retrieved ${cachedGroups.length} study groups from cache');
      PerformanceOptimizer.endOperation('getStudyGroups');
      return cachedGroups;
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('study_groups');
      debugPrint('Retrieved ${maps.length} study groups from database');

      final groups = List.generate(maps.length, (i) {
        return StudyGroup.fromMap(maps[i]);
      });

      // Cache the result for 5 minutes
      PerformanceOptimizer.cacheValue('study_groups', groups,
          expiration: const Duration(minutes: 5));

      PerformanceOptimizer.endOperation('getStudyGroups');
      return groups;
    } catch (e) {
      debugPrint('Error retrieving study groups: $e');
      PerformanceOptimizer.endOperation('getStudyGroups');
      return []; // Return empty list on error
    }
  }

  Future<void> updateStudyGroup(StudyGroup group) async {
    final db = await database;
    await db.update(
      'study_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteStudyGroup(int id) async {
    final db = await database;
    await db.delete(
      'study_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Study Session CRUD operations
  Future<int> insertStudySession(StudySession session) async {
    final db = await database;
    return await db.insert('study_sessions', session.toMap());
  }

  Future<List<StudySession>> getStudySessionsForGroup(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'scheduledDate DESC',
    );
    return List.generate(maps.length, (i) {
      return StudySession.fromMap(maps[i]);
    });
  }

  Future<void> updateStudySession(StudySession session) async {
    final db = await database;
    await db.update(
      'study_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteStudySession(int id) async {
    final db = await database;
    await db.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
