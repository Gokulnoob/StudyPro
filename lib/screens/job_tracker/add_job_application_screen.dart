import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_application.dart';

class AddJobApplicationScreen extends StatefulWidget {
  const AddJobApplicationScreen({super.key});

  @override
  State<AddJobApplicationScreen> createState() =>
      _AddJobApplicationScreenState();
}

class _AddJobApplicationScreenState extends State<AddJobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _jobUrlController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedStatus = JobApplicationStatus.applied;
  DateTime _applicationDate = DateTime.now();
  DateTime? _deadline;

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _notesController.dispose();
    _contactEmailController.dispose();
    _jobUrlController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Job Application'),
        actions: [
          TextButton(
            onPressed: _saveApplication,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: JobApplicationStatus.allStatuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Dates
              Text(
                'Dates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Application Date'),
                subtitle:
                    Text(DateFormat('MMM dd, yyyy').format(_applicationDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _applicationDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _applicationDate = date;
                    });
                  }
                },
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline (Optional)'),
                subtitle: Text(_deadline != null
                    ? DateFormat('MMM dd, yyyy').format(_deadline!)
                    : 'No deadline set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ??
                        DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _deadline = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Additional Details
              Text(
                'Additional Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary/Range',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _jobUrlController,
                decoration: const InputDecoration(
                  labelText: 'Job URL',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _saveApplication() async {
    if (_formKey.currentState?.validate() ?? false) {
      final application = JobApplication(
        company: _companyController.text,
        position: _positionController.text,
        status: _selectedStatus,
        applicationDate: DateFormat('yyyy-MM-dd').format(_applicationDate),
        deadline: _deadline != null
            ? DateFormat('yyyy-MM-dd').format(_deadline!)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        contactEmail: _contactEmailController.text.isNotEmpty
            ? _contactEmailController.text
            : null,
        jobUrl:
            _jobUrlController.text.isNotEmpty ? _jobUrlController.text : null,
        salary:
            _salaryController.text.isNotEmpty ? _salaryController.text : null,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
      );

      try {
        await Provider.of<JobApplicationProvider>(context, listen: false)
            .addApplication(application);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Job application added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding application: $e')),
          );
        }
      }
    }
  }
}
