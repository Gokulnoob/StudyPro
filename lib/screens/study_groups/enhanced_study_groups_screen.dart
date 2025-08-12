import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/study_group_provider.dart';
import '../../models/study_group.dart';
import '../../widgets/optimized_widgets.dart';
import 'study_group_detail_screen.dart';
import 'create_study_group_screen.dart';
import 'join_study_group_screen.dart';

class EnhancedStudyGroupsScreen extends StatefulWidget {
  const EnhancedStudyGroupsScreen({super.key});

  @override
  State<EnhancedStudyGroupsScreen> createState() =>
      _EnhancedStudyGroupsScreenState();
}

class _EnhancedStudyGroupsScreenState extends State<EnhancedStudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedSubject = 'All';
  bool _showOnlineOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load study groups when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StudyGroupProvider>(context, listen: false);
      provider.loadStudyGroups();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh study groups when the screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<StudyGroupProvider>(context, listen: false);
        provider.loadStudyGroups();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'My Groups'),
            Tab(icon: Icon(Icons.explore), text: 'Discover'),
            Tab(icon: Icon(Icons.schedule), text: 'Sessions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchBottomSheet,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'create':
                  _navigateToCreateGroup();
                  break;
                case 'join':
                  _navigateToJoinGroup();
                  break;
                case 'settings':
                  _showSettingsBottomSheet();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Create Group'),
                ),
              ),
              const PopupMenuItem(
                value: 'join',
                child: ListTile(
                  leading: Icon(Icons.group_add),
                  title: Text('Join Group'),
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroupsTab(),
          _buildDiscoverTab(),
          _buildSessionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGroup,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyGroupsTab() {
    return Consumer<StudyGroupProvider>(
      builder: (context, provider, child) {
        debugPrint(
            'Building MyGroupsTab - Total groups: ${provider.studyGroups.length}');

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final myGroups =
            provider.studyGroups.where((group) => group.isMember).toList();

        debugPrint('My groups count: ${myGroups.length}');
        for (var group in myGroups) {
          debugPrint('My group: ${group.name} (isMember: ${group.isMember})');
        }

        if (myGroups.isEmpty) {
          return _buildEmptyState(
            'No study groups yet',
            'Create or join your first study group to start collaborating',
            Icons.group_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadStudyGroups();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildActiveSessionsCard(myGroups),
              const SizedBox(height: 16),
              Text(
                'My Study Groups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...myGroups
                  .map((group) => _buildGroupCard(group, isMyGroup: true)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<StudyGroupProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var availableGroups =
            provider.studyGroups.where((group) => !group.isMember).toList();

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

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadStudyGroups();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilterChips(),
              const SizedBox(height: 16),
              _buildFeaturedGroupsSection(availableGroups),
              const SizedBox(height: 16),
              Text(
                'All Available Groups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (availableGroups.isEmpty)
                _buildEmptyState(
                  'No groups found',
                  'Try adjusting your filters or create a new group',
                  Icons.search_off,
                )
              else
                ...availableGroups.map((group) => _buildGroupCard(group)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<StudyGroupProvider>(
      builder: (context, provider, child) {
        final upcomingSessions = provider.studySessions
            .where((s) => DateTime.now().isBefore(s.scheduledDate))
            .toList();
        final todaySessions = provider.studySessions
            .where((s) => s.scheduledDate.day == DateTime.now().day)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSessionOverview(),
            const SizedBox(height: 16),
            if (todaySessions.isNotEmpty) ...[
              Text(
                'Today\'s Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...todaySessions.map((session) => _buildSessionCard(session)),
              const SizedBox(height: 16),
            ],
            Text(
              'Upcoming Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (upcomingSessions.isEmpty)
              _buildEmptyState(
                'No upcoming sessions',
                'Schedule a study session with your groups',
                Icons.event_busy,
              )
            else
              ...upcomingSessions.map((session) => _buildSessionCard(session)),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return OptimizedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Start Session',
                    Icons.play_circle_fill,
                    Colors.green,
                    () => _startQuickSession(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    'Schedule',
                    Icons.schedule,
                    Colors.blue,
                    () => _scheduleSession(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    'Messages',
                    Icons.message,
                    Colors.orange,
                    () => _openMessages(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionsCard(List<StudyGroup> groups) {
    final activeSessions = groups
        .where((g) =>
            g.nextSession != null && g.nextSession!.isAfter(DateTime.now()))
        .toList();

    if (activeSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return OptimizedCard(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.live_tv, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Active Sessions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeSessions.map((group) => _buildActiveSessionTile(group)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionTile(StudyGroup group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(group.name),
          ),
          TextButton(
            onPressed: () => _joinSession(group),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final subjects = [
      'All',
      'Math',
      'Science',
      'Literature',
      'History',
      'Computer Science'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Subject: '),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: subjects.map((subject) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(subject),
                        selected: _selectedSubject == subject,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSubject = subject;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilterChip(
              label: const Text('Online Only'),
              selected: _showOnlineOnly,
              onSelected: (selected) {
                setState(() {
                  _showOnlineOnly = selected;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedGroupsSection(List<StudyGroup> groups) {
    if (groups.isEmpty) return const SizedBox.shrink();

    final featuredGroups = groups.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Groups',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: OptimizedListView<StudyGroup>(
            items: featuredGroups,
            itemBuilder: (context, group, index) {
              return _buildFeaturedGroupCard(group);
            },
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedGroupCard(StudyGroup group) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: OptimizedCard(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      group.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          group.subject,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${group.memberCount} members',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _joinGroup(group),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Join'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(StudyGroup group, {bool isMyGroup = false}) {
    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: group.isOnline ? Colors.green : Colors.blue,
          child: Icon(
            group.isOnline ? Icons.cloud : Icons.location_on,
            color: Colors.white,
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.subject),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount} members',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                if (group.nextSession != null) ...[
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Live',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: isMyGroup
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleGroupAction(group, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View')),
                  const PopupMenuItem(value: 'message', child: Text('Message')),
                  const PopupMenuItem(
                      value: 'schedule', child: Text('Schedule Session')),
                  const PopupMenuItem(
                      value: 'leave', child: Text('Leave Group')),
                ],
              )
            : ElevatedButton(
                onPressed: () => _joinGroup(group),
                child: const Text('Join'),
              ),
        onTap: () => _navigateToGroupDetail(group),
      ),
    );
  }

  Widget _buildSessionOverview() {
    return OptimizedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat('Total Hours', '24.5', Icons.timer),
                ),
                Expanded(
                  child: _buildOverviewStat(
                      'This Week', '5.2', Icons.calendar_today),
                ),
                Expanded(
                  child: _buildOverviewStat('Groups', '3', Icons.group),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(StudySession session) {
    final DateTime sessionDate = session.scheduledDate;
    final String formattedTime = DateFormat('HH:mm').format(sessionDate);

    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.event,
            color: Colors.white,
          ),
        ),
        title: Text(session.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${session.attendees.length} participants',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Smart Suggestions'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStudyGroupScreen(),
      ),
    );
  }

  void _navigateToJoinGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinStudyGroupScreen(),
      ),
    );
  }

  void _navigateToGroupDetail(StudyGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyGroupDetailScreen(studyGroup: group),
      ),
    );
  }

  void _joinGroup(StudyGroup group) async {
    final provider = Provider.of<StudyGroupProvider>(context, listen: false);
    await provider.joinGroup(group.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${group.name}')),
      );
    }
  }

  void _handleGroupAction(StudyGroup group, String action) {
    switch (action) {
      case 'view':
        _navigateToGroupDetail(group);
        break;
      case 'message':
        _openGroupMessages(group);
        break;
      case 'schedule':
        _scheduleGroupSession(group);
        break;
      case 'leave':
        _leaveGroup(group);
        break;
    }
  }

  void _startQuickSession() {
    // Implement quick session start
  }

  void _scheduleSession() {
    // Implement session scheduling
  }

  void _openMessages() {
    // Implement messages screen
  }

  void _joinSession(dynamic session) {
    // Implement session joining
  }

  void _openGroupMessages(StudyGroup group) {
    // Implement group messages
  }

  void _scheduleGroupSession(StudyGroup group) {
    // Implement group session scheduling
  }

  void _leaveGroup(StudyGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${group.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<StudyGroupProvider>(context, listen: false);
      await provider.leaveGroup(group.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Left ${group.name}')),
        );
      }
    }
  }
}
