import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../models/study_group.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _testResults = '';

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _testResults = 'Running database tests...\n';
    });

    try {
      // Test 1: Create a test group
      final testGroup = StudyGroup(
        name: 'Test Group ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Test Description',
        subject: 'Test Subject',
        createdBy: 'Test User',
        createdAt: DateTime.now(),
        members: ['Test User'],
      );

      setState(() {
        _testResults += 'Creating test group: ${testGroup.name}\n';
      });

      // Test 2: Insert to database
      final id = await _dbHelper.insertStudyGroup(testGroup);
      setState(() {
        _testResults += 'Group created with ID: $id\n';
      });

      // Test 3: Retrieve all groups
      final groups = await _dbHelper.getStudyGroups();
      setState(() {
        _testResults += 'Total groups in database: ${groups.length}\n';
      });

      // Test 4: List all groups
      for (var group in groups) {
        setState(() {
          _testResults +=
              'Group: ${group.name} (ID: ${group.id}, isMember: ${group.isMember})\n';
        });
      }

      setState(() {
        _testResults += '\nTest completed successfully!\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runTests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Database Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
