import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_group_provider.dart';
import '../../models/study_group.dart';

class JoinStudyGroupScreen extends StatefulWidget {
  const JoinStudyGroupScreen({super.key});

  @override
  State<JoinStudyGroupScreen> createState() => _JoinStudyGroupScreenState();
}

class _JoinStudyGroupScreenState extends State<JoinStudyGroupScreen> {
  final _searchController = TextEditingController();
  final _codeController = TextEditingController();
  String _searchQuery = '';
  String _selectedSubject = 'All';
  bool _showOnlineOnly = false;

  final List<String> _subjects = [
    'All',
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

  @override
  void dispose() {
    _searchController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Study Group'),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFiltersSection(),
          Expanded(child: _buildGroupsList()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search groups by name or subject...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'Enter group code',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _joinByCode,
                child: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Subject: '),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedSubject,
                  isExpanded: true,
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
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _showOnlineOnly,
                onChanged: (value) {
                  setState(() {
                    _showOnlineOnly = value!;
                  });
                },
              ),
              const Text('Online groups only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return Consumer<StudyGroupProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var availableGroups =
            provider.studyGroups.where((group) => !group.isJoined).toList();

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          availableGroups = availableGroups
              .where((group) =>
                  group.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  group.subject
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  group.description
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (_selectedSubject != 'All') {
          availableGroups = availableGroups
              .where((group) => group.subject == _selectedSubject)
              .toList();
        }

        if (_showOnlineOnly) {
          availableGroups =
              availableGroups.where((group) => group.isOnline).toList();
        }

        if (availableGroups.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadStudyGroups();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (availableGroups.isNotEmpty) ...[
                Text(
                  'Available Groups (${availableGroups.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
              ],
              ...availableGroups.map((group) => _buildGroupCard(group)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupCard(StudyGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: group.isOnline ? Colors.green : Colors.blue,
                  child: Icon(
                    group.isOnline ? Icons.cloud : Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!group.isPrivate)
                            const Icon(Icons.public,
                                size: 16, color: Colors.green)
                          else
                            const Icon(Icons.lock,
                                size: 16, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.subject,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              group.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount}/${group.maxMembers} members',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  group.meetingSchedule ?? 'No schedule',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (group.hasActiveSession) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Live',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (group.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: group.tags.take(3).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _viewGroupDetails(group),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details'),
                ),
                ElevatedButton.icon(
                  onPressed: group.memberCount >= group.maxMembers
                      ? null
                      : () => _requestToJoin(group),
                  icon: Icon(group.isPrivate ? Icons.send : Icons.group_add),
                  label: Text(group.isPrivate ? 'Request' : 'Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No groups found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Group'),
            ),
          ],
        ),
      ),
    );
  }

  void _joinByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group code')),
      );
      return;
    }

    try {
      final provider = Provider.of<StudyGroupProvider>(context, listen: false);
      await provider.joinStudyGroupByCode(code);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the group!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining group: $e')),
        );
      }
    }
  }

  void _requestToJoin(StudyGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.isPrivate ? 'Request to Join' : 'Join Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Do you want to ${group.isPrivate ? 'request to join' : 'join'} "${group.name}"?'),
            const SizedBox(height: 8),
            Text(
              'Subject: ${group.subject}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Members: ${group.memberCount}/${group.maxMembers}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (group.isPrivate) ...[
              const SizedBox(height: 8),
              const Text(
                'Your request will be sent to the group admin for approval.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(group.isPrivate ? 'Send Request' : 'Join'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider =
            Provider.of<StudyGroupProvider>(context, listen: false);
        await provider.joinStudyGroup(group.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(group.isPrivate
                  ? 'Request sent successfully!'
                  : 'Joined ${group.name} successfully!'),
            ),
          );

          if (!group.isPrivate) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _viewGroupDetails(StudyGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          group.isOnline ? Colors.green : Colors.blue,
                      child: Icon(
                        group.isOnline ? Icons.cloud : Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            group.subject,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(group.description),
                const SizedBox(height: 20),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Type', group.isOnline ? 'Online' : 'In-person'),
                _buildDetailRow(
                    'Privacy', group.isPrivate ? 'Private' : 'Public'),
                _buildDetailRow(
                    'Members', '${group.memberCount}/${group.maxMembers}'),
                _buildDetailRow(
                    'Schedule', group.meetingSchedule ?? 'No schedule'),
                _buildDetailRow('Created', _formatDate(group.createdAt)),
                if (group.tags.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.tags.map((tag) {
                      return Chip(label: Text(tag));
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _requestToJoin(group);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                      group.isPrivate ? 'Send Join Request' : 'Join Group'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}
