import '../models/mood_entry.dart';
import '../models/study_group.dart';
import '../models/job_application.dart';
import '../services/database_helper.dart';

class DataInitializer {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<void> initializeSampleData() async {
    try {
      // Check if data already exists
      final existingMoods = await _databaseHelper.getMoodEntries();
      final existingGroups = await _databaseHelper.getStudyGroups();
      final existingJobs = await _databaseHelper.getJobApplications();

      // Add sample mood entries if none exist
      if (existingMoods.isEmpty) {
        final sampleMoods = [
          MoodEntry(
            date: DateTime.now().subtract(const Duration(days: 2)),
            moodLevel: 4,
            mood: Mood.good,
            notes: 'Had a great study session today!',
            activities: ['studying', 'exercise'],
            factors: ['good sleep', 'healthy food'],
            sleepHours: 8,
            stressLevel: 2,
            energyLevel: 4,
          ),
          MoodEntry(
            date: DateTime.now().subtract(const Duration(days: 1)),
            moodLevel: 3,
            mood: Mood.okay,
            notes: 'Average day, got some work done.',
            activities: ['reading', 'watching TV'],
            factors: ['work stress'],
            sleepHours: 7,
            stressLevel: 3,
            energyLevel: 3,
          ),
          MoodEntry(
            date: DateTime.now(),
            moodLevel: 5,
            mood: Mood.excellent,
            notes: 'Feeling fantastic! Aced my exam!',
            activities: ['studying', 'celebrating'],
            factors: ['achievement', 'good friends'],
            sleepHours: 8,
            stressLevel: 1,
            energyLevel: 5,
          ),
        ];

        for (final mood in sampleMoods) {
          await _databaseHelper.insertMoodEntry(mood);
        }
      }

      // Add sample study groups if none exist
      if (existingGroups.isEmpty) {
        final sampleGroups = [
          StudyGroup(
            name: 'Computer Science Study Group',
            description: 'Weekly study sessions for CS topics',
            subject: 'Computer Science',
            createdBy: 'Sample User',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
            members: ['Sample User', 'Alice', 'Bob'],
            isOnline: true,
            maxMembers: 10,
            tags: ['algorithms', 'data structures'],
            meetingSchedule: 'Every Wednesday 7 PM',
            resources: [
              StudyResource(
                title: 'Algorithm Cheat Sheet',
                description: 'Quick reference for common algorithms',
                url: 'https://example.com/algorithms.pdf',
                type: 'pdf',
                sharedBy: 'Sample User',
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
              ),
              StudyResource(
                title: 'Data Structures Guide',
                description: 'Complete guide to data structures',
                url: 'https://example.com/data-structures.pdf',
                type: 'pdf',
                sharedBy: 'Alice',
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
          ),
          StudyGroup(
            name: 'Math Study Circle',
            description: 'Collaborative math problem solving',
            subject: 'Mathematics',
            createdBy: 'Sample User',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            members: ['Sample User', 'Carol', 'Dave'],
            isOnline: false,
            location: 'Library Room 203',
            maxMembers: 6,
            tags: ['calculus', 'algebra'],
            meetingSchedule: 'Tuesdays and Fridays 2 PM',
            resources: [
              StudyResource(
                title: 'Calculus Practice Problems',
                description: 'Practice problems for calculus',
                url: 'https://example.com/calculus.pdf',
                type: 'pdf',
                sharedBy: 'Carol',
                createdAt: DateTime.now().subtract(const Duration(days: 3)),
              ),
            ],
          ),
        ];

        for (final group in sampleGroups) {
          await _databaseHelper.insertStudyGroup(group);
        }
      }

      // Add sample job applications if none exist
      if (existingJobs.isEmpty) {
        final sampleJobs = [
          JobApplication(
            company: 'Tech Solutions Inc.',
            position: 'Software Developer',
            status: 'Applied',
            applicationDate: DateTime.now()
                .subtract(const Duration(days: 10))
                .toIso8601String(),
            deadline:
                DateTime.now().add(const Duration(days: 5)).toIso8601String(),
            notes: 'Submitted application through their website',
            contactEmail: 'hr@techsolutions.com',
            location: 'Remote',
          ),
          JobApplication(
            company: 'Data Corp',
            position: 'Data Analyst',
            status: 'Interview',
            applicationDate: DateTime.now()
                .subtract(const Duration(days: 15))
                .toIso8601String(),
            deadline:
                DateTime.now().add(const Duration(days: 2)).toIso8601String(),
            notes: 'Phone interview scheduled for next week',
            contactEmail: 'careers@datacorp.com',
            location: 'New York, NY',
          ),
          JobApplication(
            company: 'StartupX',
            position: 'Junior Developer',
            status: 'Rejected',
            applicationDate: DateTime.now()
                .subtract(const Duration(days: 20))
                .toIso8601String(),
            notes: 'Good experience, will try again next year',
            contactEmail: 'jobs@startupx.com',
            location: 'San Francisco, CA',
          ),
        ];

        for (final job in sampleJobs) {
          await _databaseHelper.insertJobApplication(job);
        }
      }
    } catch (e) {
      print('Error initializing sample data: $e');
      // Continue without sample data
    }
  }
}
