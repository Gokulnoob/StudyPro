import 'package:flutter/foundation.dart';
import '../models/job_application.dart';
import '../services/database_helper.dart';

class JobApplicationProvider with ChangeNotifier {
  List<JobApplication> _applications = [];
  bool _isLoading = false;

  List<JobApplication> get applications => _applications;
  bool get isLoading => _isLoading;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  JobApplicationProvider() {
    // Don't automatically load on creation to avoid initialization issues
    // loadApplications();
  }

  Future<void> loadApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await _databaseHelper.getJobApplications();
    } catch (e) {
      debugPrint('Error loading applications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addApplication(JobApplication application) async {
    try {
      await _databaseHelper.insertJobApplication(application);
      await loadApplications();
    } catch (e) {
      debugPrint('Error adding application: $e');
    }
  }

  Future<void> updateApplication(JobApplication application) async {
    try {
      await _databaseHelper.updateJobApplication(application);
      await loadApplications();
    } catch (e) {
      debugPrint('Error updating application: $e');
    }
  }

  Future<void> deleteApplication(int id) async {
    try {
      await _databaseHelper.deleteJobApplication(id);
      await loadApplications();
    } catch (e) {
      debugPrint('Error deleting application: $e');
    }
  }

  List<JobApplication> getApplicationsByStatus(String status) {
    return _applications.where((app) => app.status == status).toList();
  }

  int get totalApplications => _applications.length;

  int get pendingApplications => _applications
      .where((app) => app.status == JobApplicationStatus.pending)
      .length;

  int get interviewApplications => _applications
      .where((app) => app.status == JobApplicationStatus.interview)
      .length;

  int get offerApplications => _applications
      .where((app) => app.status == JobApplicationStatus.offer)
      .length;

  int get rejectedApplications => _applications
      .where((app) => app.status == JobApplicationStatus.rejected)
      .length;
}
