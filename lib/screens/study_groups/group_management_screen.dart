import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/study_group.dart';

class GroupManagementScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupManagementScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inviteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.group.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.folder), text: 'Resources'),
            Tab(icon: Icon(Icons.schedule), text: 'Sessions'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Invite Members'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Group'),
                  ],
                ),
              ),
              if (widget.group.isOwner)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Group', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(),
          _buildResourcesTab(),
          _buildSessionsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Member invitation card
        if (widget.group.isOwner) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite New Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inviteController,
                          decoration: const InputDecoration(
                            labelText: 'Email or Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_add),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _inviteMember,
                        child: const Text('Invite'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Group capacity: ${widget.group.memberCount}/${widget.group.maxMembers}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Members list
        const Text(
          'Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.group.members.map((member) => _buildMemberTile(member)),
      ],
    );
  }

  Widget _buildMemberTile(String member) {
    final isOwner = member == widget.group.createdBy;
    final isCurrentUser = member == 'current_user@example.com'; // Mock logic

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            member.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(member),
        subtitle: Row(
          children: [
            if (isOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Owner',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            if (isCurrentUser && !isOwner)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        trailing: widget.group.isOwner && !isOwner
            ? PopupMenuButton<String>(
                onSelected: (action) => _handleMemberAction(member, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'promote',
                    child: Text('Make Admin'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildResourcesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upload resources section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload File'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Upload Image'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _createFlashcardSet,
                  icon: const Icon(Icons.quiz),
                  label: const Text('Create Flashcard Set'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Resources list
        const Text(
          'Shared Resources',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (widget.group.resources.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No resources shared yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...widget.group.resources
              .map((resource) => _buildResourceTile(resource)),
      ],
    );
  }

  Widget _buildResourceTile(StudyResource resource) {
    IconData iconData;
    Color iconColor;

    switch (resource.type.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'image':
        iconData = Icons.image;
        iconColor = Colors.blue;
        break;
      case 'video':
        iconData = Icons.video_file;
        iconColor = Colors.purple;
        break;
      case 'flashcard':
        iconData = Icons.quiz;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(iconData, color: iconColor, size: 32),
        title: Text(resource.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resource.description.isNotEmpty) Text(resource.description),
            Text(
              'Shared by ${resource.sharedBy} • ${DateFormat('MMM dd, yyyy').format(resource.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleResourceAction(resource, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            if (resource.sharedBy == 'current_user@example.com' ||
                widget.group.isOwner)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _openResource(resource),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Schedule new session
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule Study Session',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _scheduleSession,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule New Session'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Upcoming sessions
        const Text(
          'Upcoming Sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (widget.group.nextSession != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: const Text('Next Study Session'),
              subtitle: Text(
                DateFormat('EEEE, MMM dd, yyyy at HH:mm')
                    .format(widget.group.nextSession!),
              ),
              trailing: IconButton(
                onPressed: _joinSession,
                icon: const Icon(Icons.play_arrow),
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.schedule, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No upcoming sessions',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Past sessions (mock data)
        const Text(
          'Recent Sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: const Text('Previous Session'),
            subtitle: Text(
              DateFormat('MMM dd, yyyy')
                  .format(DateTime.now().subtract(const Duration(days: 3))),
            ),
            trailing: const Text('2h 30m'),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Group information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Name', widget.group.name),
                _buildInfoRow('Subject', widget.group.subject),
                _buildInfoRow('Description', widget.group.description),
                _buildInfoRow('Created',
                    DateFormat('MMM dd, yyyy').format(widget.group.createdAt)),
                _buildInfoRow(
                    'Privacy', widget.group.isPrivate ? 'Private' : 'Public'),
                if (widget.group.isOwner) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _editGroupInfo,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Group Info'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Notification settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('New Messages'),
                  subtitle: const Text('Get notified of new chat messages'),
                  value: true,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Session Reminders'),
                  subtitle: const Text('Reminders for upcoming sessions'),
                  value: true,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('New Resources'),
                  subtitle:
                      const Text('Notifications when resources are shared'),
                  value: false,
                  onChanged: (value) {},
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Danger zone
        if (widget.group.isOwner)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _deleteGroup,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Group'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _leaveGroup,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Leave Group'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invite':
        _showInviteDialog();
        break;
      case 'share':
        _shareGroup();
        break;
      case 'delete':
        _deleteGroup();
        break;
    }
  }

  void _handleMemberAction(String member, String action) {
    switch (action) {
      case 'promote':
        _promoteMember(member);
        break;
      case 'remove':
        _removeMember(member);
        break;
    }
  }

  void _handleResourceAction(StudyResource resource, String action) {
    switch (action) {
      case 'download':
        _downloadResource(resource);
        break;
      case 'share':
        _shareResource(resource);
        break;
      case 'delete':
        _deleteResource(resource);
        break;
    }
  }

  void _inviteMember() {
    final email = _inviteController.text.trim();
    if (email.isNotEmpty) {
      // TODO: Implement actual invitation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to $email')),
      );
      _inviteController.clear();
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _inviteController,
              decoration: const InputDecoration(
                labelText: 'Email addresses (comma separated)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Or share group code:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('GROUP-CODE-123')),
                  IconButton(
                    onPressed: () {
                      // TODO: Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Code copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _inviteMember();
              Navigator.pop(context);
            },
            child: const Text('Send Invites'),
          ),
        ],
      ),
    );
  }

  void _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // TODO: Implement actual file upload
        final fileName = result.files.single.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploading $fileName...')),
        );

        // Mock upload delay
        await Future.delayed(const Duration(seconds: 2));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }

  void _uploadImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // TODO: Implement actual image upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );

        // Mock upload delay
        await Future.delayed(const Duration(seconds: 2));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _createFlashcardSet() {
    // TODO: Navigate to flashcard creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard creation coming soon!')),
    );
  }

  void _openResource(StudyResource resource) {
    // TODO: Implement resource opening logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${resource.title}...')),
    );
  }

  void _downloadResource(StudyResource resource) {
    // TODO: Implement download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${resource.title}...')),
    );
  }

  void _shareResource(StudyResource resource) {
    // TODO: Implement sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${resource.title}...')),
    );
  }

  void _deleteResource(StudyResource resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete "${resource.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement deletion logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resource deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _scheduleSession() {
    // TODO: Show session scheduling dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session scheduling coming soon!')),
    );
  }

  void _joinSession() {
    // TODO: Navigate to study session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joining session...')),
    );
  }

  void _editGroupInfo() {
    // TODO: Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit group info coming soon!')),
    );
  }

  void _promoteMember(String member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote Member'),
        content: Text('Promote $member to admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$member promoted to admin')),
              );
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }

  void _removeMember(String member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove $member from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$member removed from group')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _shareGroup() {
    // TODO: Implement group sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group link copied to clipboard')),
    );
  }

  void _deleteGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone and all data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to groups list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _leaveGroup() {
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
              Navigator.pop(context);
              Navigator.pop(context); // Go back to groups list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left group')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
