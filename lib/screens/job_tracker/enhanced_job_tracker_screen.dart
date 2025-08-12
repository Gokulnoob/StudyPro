import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_application.dart';
import 'add_job_application_screen.dart';
import 'job_application_detail_screen.dart';
import 'job_analytics_screen.dart';

class EnhancedJobTrackerScreen extends StatefulWidget {
  const EnhancedJobTrackerScreen({super.key});

  @override
  State<EnhancedJobTrackerScreen> createState() =>
      _EnhancedJobTrackerScreenState();
}

class _EnhancedJobTrackerScreenState extends State<EnhancedJobTrackerScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _sortBy = 'Date';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Job Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobAnalyticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddJobApplicationScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Applied'),
            Tab(text: 'Interview'),
            Tab(text: 'Offer'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search companies or positions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter and Sort Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['Date', 'Company', 'Position', 'Status']
                            .map((sort) => DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showFilterDialog();
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Applications List
          Expanded(
            child: Consumer<JobApplicationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredApplications = _getFilteredApplications(provider);

                if (filteredApplications.isEmpty) {
                  return _buildEmptyState();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApplicationsList(filteredApplications),
                    _buildApplicationsList(
                        provider.getApplicationsByStatus('Applied')),
                    _buildApplicationsList(
                        provider.getApplicationsByStatus('Interview')),
                    _buildApplicationsList(
                        provider.getApplicationsByStatus('Offer')),
                    _buildApplicationsList(
                        provider.getApplicationsByStatus('Rejected')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddJobApplicationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Application'),
      ),
    );
  }

  List<JobApplication> _getFilteredApplications(
      JobApplicationProvider provider) {
    var applications = provider.applications;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      applications = applications
          .where((app) =>
              app.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              app.position.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Company':
        applications.sort((a, b) => a.company.compareTo(b.company));
        break;
      case 'Position':
        applications.sort((a, b) => a.position.compareTo(b.position));
        break;
      case 'Status':
        applications.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'Date':
      default:
        applications
            .sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
        break;
    }

    return applications;
  }

  Widget _buildApplicationsList(List<JobApplication> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<JobApplicationProvider>(context, listen: false)
            .loadApplications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return EnhancedJobApplicationCard(
            application: application,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobApplicationDetailScreen(
                    application: application,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No applications found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your job applications today!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddJobApplicationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Application'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Applications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show only urgent'),
              value: false, // Implement filter state
              onChanged: (value) {
                // Implement filter logic
              },
            ),
            CheckboxListTile(
              title: const Text('Recently applied'),
              value: false,
              onChanged: (value) {
                // Implement filter logic
              },
            ),
            CheckboxListTile(
              title: const Text('Has deadline'),
              value: false,
              onChanged: (value) {
                // Implement filter logic
              },
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
              Navigator.pop(context);
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class EnhancedJobApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;

  const EnhancedJobApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = _isUrgent(application);
    final daysSinceApplication = _getDaysSinceApplication(application);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUrgent ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                isUrgent ? Border.all(color: Colors.orange, width: 2) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.position,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            application.company,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusChip(application.status),
                        if (isUrgent) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Row
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _buildDetailItem(
                      Icons.calendar_today,
                      'Applied $daysSinceApplication days ago',
                      Colors.grey[600]!,
                    ),
                    if (application.location != null)
                      _buildDetailItem(
                        Icons.location_on,
                        application.location!,
                        Colors.grey[600]!,
                      ),
                    if (application.salary != null)
                      _buildDetailItem(
                        Icons.attach_money,
                        application.salary!,
                        Colors.green[600]!,
                      ),
                    if (application.deadline != null)
                      _buildDetailItem(
                        Icons.schedule,
                        'Deadline: ${DateFormat('MMM dd').format(DateTime.parse(application.deadline!))}',
                        _isDeadlineClose(application.deadline!)
                            ? Colors.red[600]!
                            : Colors.grey[600]!,
                      ),
                  ],
                ),

                // Action Buttons
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (application.jobUrl != null)
                      TextButton.icon(
                        onPressed: () => _launchURL(application.jobUrl!),
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('View Job'),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showQuickActions(context, application),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),

                // Progress Indicator for Interview Status
                if (application.status == 'Interview') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Interview scheduled',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData? icon;

    switch (status) {
      case 'Applied':
        color = Colors.blue;
        icon = Icons.send;
        break;
      case 'Interview':
        color = Colors.orange;
        icon = Icons.person;
        break;
      case 'Offer':
        color = Colors.green;
        icon = Icons.star;
        break;
      case 'Rejected':
        color = Colors.red;
        icon = Icons.close;
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isUrgent(JobApplication application) {
    if (application.deadline == null) return false;

    final deadline = DateTime.parse(application.deadline!);
    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;

    return daysUntilDeadline <= 3 && daysUntilDeadline >= 0;
  }

  bool _isDeadlineClose(String deadline) {
    final deadlineDate = DateTime.parse(deadline);
    final now = DateTime.now();
    final daysUntilDeadline = deadlineDate.difference(now).inDays;

    return daysUntilDeadline <= 7 && daysUntilDeadline >= 0;
  }

  int _getDaysSinceApplication(JobApplication application) {
    final applicationDate = DateTime.parse(application.applicationDate);
    final now = DateTime.now();
    return now.difference(applicationDate).inDays;
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showQuickActions(BuildContext context, JobApplication application) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Application'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Follow-up'),
              onTap: () {
                Navigator.pop(context);
                // Send follow-up email
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
