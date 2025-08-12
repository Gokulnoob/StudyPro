import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/study_group.dart';
import '../../providers/study_group_provider.dart';
import 'enhanced_chat_screen.dart';
import 'whiteboard_screen.dart';
import 'voice_call_screen.dart';
import 'group_management_screen.dart';

class StudyGroupDetailScreen extends StatelessWidget {
  final StudyGroup studyGroup;

  const StudyGroupDetailScreen({
    super.key,
    required this.studyGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(studyGroup.name),
        actions: [
          if (!studyGroup.isMember)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () => _joinGroup(context),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Group'),
                ),
              ),
              if (studyGroup.isMember) ...[
                const PopupMenuItem(
                  value: 'leave',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Leave Group'),
                  ),
                ),
              ],
              if (studyGroup.isOwner) ...[
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Group'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete Group'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            if (studyGroup.isMember) ...[
              _buildCollaborativeFeatures(context),
              const SizedBox(height: 16),
            ],
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildMembersSection(context),
            const SizedBox(height: 16),
            _buildUpcomingSessionsSection(),
            const SizedBox(height: 16),
            _buildResourcesSection(),
            const SizedBox(height: 16),
            _buildRecentActivitySection(),
          ],
        ),
      ),
      floatingActionButton: studyGroup.isMember
          ? FloatingActionButton.extended(
              onPressed: () => _scheduleSession(context),
              icon: const Icon(Icons.add),
              label: const Text('Schedule Session'),
            )
          : null,
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    studyGroup.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studyGroup.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studyGroup.subject,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: studyGroup.isOnline ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    studyGroup.isOnline ? 'Online' : 'In-Person',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              studyGroup.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.group,
                    'Members',
                    '${studyGroup.memberCount}/${studyGroup.maxMembers}',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.event,
                    'Created',
                    DateFormat('MMM dd, yyyy').format(studyGroup.createdAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on,
                    'Location',
                    studyGroup.isOnline
                        ? 'Online'
                        : studyGroup.location ?? 'TBD',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.schedule,
                    'Next Session',
                    studyGroup.nextSession != null
                        ? DateFormat('MMM dd, HH:mm')
                            .format(studyGroup.nextSession!)
                        : 'Not scheduled',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _viewAllMembers(context),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    studyGroup.memberCount > 5 ? 5 : studyGroup.memberCount,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            'M${index + 1}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member ${index + 1}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (studyGroup.isMember)
                  TextButton.icon(
                    onPressed: () => _scheduleSession(null),
                    icon: const Icon(Icons.add),
                    label: const Text('Schedule'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            studyGroup.nextSession != null
                ? _buildSessionTile(
                    'Next Study Session',
                    studyGroup.nextSession!,
                    'Join session when it starts',
                  )
                : Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No upcoming sessions',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        if (studyGroup.isMember)
                          TextButton(
                            onPressed: () => _scheduleSession(null),
                            child: const Text('Schedule a session'),
                          ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(String title, DateTime dateTime, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.event, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, MMM dd, yyyy at HH:mm').format(dateTime)),
          Text(subtitle),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigate to session details
      },
    );
  }

  Widget _buildResourcesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shared Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            studyGroup.resources.isNotEmpty
                ? Column(
                    children: studyGroup.resources.map((resource) {
                      return ListTile(
                        leading: Icon(_getResourceIcon(resource.type)),
                        title: Text(resource.title),
                        subtitle: Text(resource.description),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openResource(resource.url),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No shared resources yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        if (studyGroup.isMember)
                          TextButton(
                            onPressed: () => _addResource(null),
                            child: const Text('Add a resource'),
                          ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Mock recent activity
            Column(
              children: [
                _buildActivityTile(
                  Icons.person_add,
                  'New member joined',
                  'Member 3 joined the group',
                  '2 hours ago',
                ),
                _buildActivityTile(
                  Icons.event,
                  'Session completed',
                  'Study session: Chapter 5 Review',
                  '1 day ago',
                ),
                _buildActivityTile(
                  Icons.attachment,
                  'Resource added',
                  'Practice Problems Set 3.pdf',
                  '2 days ago',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborativeFeatures(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collaborative Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureButton(
                    context,
                    Icons.chat,
                    'Chat',
                    'Real-time messaging',
                    Colors.blue,
                    () => _openChat(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFeatureButton(
                    context,
                    Icons.draw,
                    'Whiteboard',
                    'Collaborative board',
                    Colors.green,
                    () => _openWhiteboard(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureButton(
                    context,
                    Icons.videocam,
                    'Video Call',
                    'Join voice/video',
                    Colors.orange,
                    () => _openVideoCall(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFeatureButton(
                    context,
                    Icons.settings,
                    'Manage',
                    'Group settings',
                    Colors.purple,
                    () => _openGroupManagement(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    IconData icon,
    String title,
    String subtitle,
    String time,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.play_circle;
      case 'link':
        return Icons.link;
      case 'document':
        return Icons.description;
      default:
        return Icons.attachment;
    }
  }

  void _joinGroup(BuildContext context) {
    final provider = Provider.of<StudyGroupProvider>(context, listen: false);
    provider.joinGroup(studyGroup.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully joined the group!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'share':
        _shareGroup();
        break;
      case 'leave':
        _leaveGroup(context);
        break;
      case 'edit':
        _editGroup(context);
        break;
      case 'delete':
        _deleteGroup(context);
        break;
    }
  }

  void _shareGroup() {
    // Implement sharing functionality
  }

  void _leaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<StudyGroupProvider>(context, listen: false);
              provider.leaveGroup(studyGroup.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _editGroup(BuildContext context) {
    // Navigate to edit group screen
  }

  void _deleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<StudyGroupProvider>(context, listen: false);
              provider.deleteGroup(studyGroup.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _scheduleSession(BuildContext? context) {
    // Navigate to schedule session screen
  }

  void _viewAllMembers(BuildContext context) {
    // Navigate to all members screen
  }

  void _openResource(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _addResource(BuildContext? context) {
    // Navigate to add resource screen
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EnhancedStudyGroupChatScreen(studyGroup: studyGroup),
      ),
    );
  }

  void _openWhiteboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhiteboardScreen(studyGroup: studyGroup),
      ),
    );
  }

  void _openVideoCall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(studyGroup: studyGroup),
      ),
    );
  }

  void _openGroupManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupManagementScreen(group: studyGroup),
      ),
    );
  }
}
