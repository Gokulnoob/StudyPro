import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_group_provider.dart';
import '../../models/study_group.dart';

class CreateStudyGroupScreen extends StatefulWidget {
  const CreateStudyGroupScreen({super.key});

  @override
  State<CreateStudyGroupScreen> createState() => _CreateStudyGroupScreenState();
}

class _CreateStudyGroupScreenState extends State<CreateStudyGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  String _selectedSubject = 'Computer Science';
  bool _isOnline = true;
  int _maxMembers = 10;
  String _privacy = 'Public';
  List<String> _tags = [];
  String _meetingSchedule = 'Weekly';
  TimeOfDay _preferredTime = const TimeOfDay(hour: 18, minute: 0);

  final List<String> _subjects = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Literature',
    'History',
    'Economics',
    'Psychology',
    'Art',
    'Music',
    'Other',
  ];

  final List<String> _availableTags = [
    'Beginner Friendly',
    'Advanced',
    'Exam Prep',
    'Project Based',
    'Discussion Heavy',
    'Problem Solving',
    'Research',
    'Homework Help',
    'Certification',
    'Career Focused',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Group'),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildScheduleSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildPreviewCard(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _createGroup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Study Group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                hintText: 'e.g., Data Structures Study Group',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
              ),
              items: _subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'What will you study together?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Online Group'),
              subtitle: const Text('Members can join virtually'),
              value: _isOnline,
              onChanged: (value) {
                setState(() {
                  _isOnline = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Privacy'),
              subtitle: Text(_privacy == 'Public'
                  ? 'Anyone can find and join'
                  : 'Invite only'),
              trailing: DropdownButton<String>(
                value: _privacy,
                items: ['Public', 'Private'].map((privacy) {
                  return DropdownMenuItem(
                    value: privacy,
                    child: Text(privacy),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _privacy = value!;
                  });
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Maximum Members'),
              subtitle: Text('$_maxMembers members'),
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _maxMembers.toDouble(),
                  min: 2,
                  max: 50,
                  divisions: 48,
                  onChanged: (value) {
                    setState(() {
                      _maxMembers = value.round();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _meetingSchedule,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: ['Daily', 'Weekly', 'Bi-weekly', 'Monthly', 'As needed']
                  .map((schedule) {
                return DropdownMenuItem(
                  value: schedule,
                  child: Text(schedule),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _meetingSchedule = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Preferred Time'),
              subtitle: Text(_preferredTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help others find your group',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _isOnline ? Colors.green : Colors.blue,
                child: Icon(
                  _isOnline ? Icons.cloud : Icons.location_on,
                  color: Colors.white,
                ),
              ),
              title: Text(
                _nameController.text.isEmpty
                    ? 'Group Name'
                    : _nameController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedSubject),
                  const SizedBox(height: 4),
                  Text(
                    _descriptionController.text.isEmpty
                        ? 'Group description will appear here'
                        : _descriptionController.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: _tags.take(3).map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 10),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_privacy == 'Public' ? Icons.public : Icons.lock),
                  Text(
                    _privacy,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
    );

    if (time != null) {
      setState(() {
        _preferredTime = time;
      });
    }
  }

  void _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<StudyGroupProvider>(context, listen: false);

    final studyGroup = StudyGroup(
      name: _nameController.text,
      subject: _selectedSubject,
      description: _descriptionController.text,
      createdBy: 'Current User', // TODO: Replace with actual user ID
      createdAt: DateTime.now(),
      members: ['Current User'], // TODO: Replace with actual user ID
      isOnline: _isOnline,
      tags: _tags,
      maxMembers: _maxMembers,
      isPrivate: _privacy == 'Private',
      meetingSchedule: _meetingSchedule,
    );

    try {
      await provider.createStudyGroup(studyGroup);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study group created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }
}
