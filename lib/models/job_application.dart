class JobApplication {
  final int? id;
  final String company;
  final String position;
  final String status;
  final String applicationDate;
  final String? deadline;
  final String? notes;
  final String? contactEmail;
  final String? jobUrl;
  final String? salary;
  final String? location;

  JobApplication({
    this.id,
    required this.company,
    required this.position,
    required this.status,
    required this.applicationDate,
    this.deadline,
    this.notes,
    this.contactEmail,
    this.jobUrl,
    this.salary,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'status': status,
      'applicationDate': applicationDate,
      'deadline': deadline,
      'notes': notes,
      'contactEmail': contactEmail,
      'jobUrl': jobUrl,
      'salary': salary,
      'location': location,
    };
  }

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'],
      company: map['company'],
      position: map['position'],
      status: map['status'],
      applicationDate: map['applicationDate'],
      deadline: map['deadline'],
      notes: map['notes'],
      contactEmail: map['contactEmail'],
      jobUrl: map['jobUrl'],
      salary: map['salary'],
      location: map['location'],
    );
  }

  JobApplication copyWith({
    int? id,
    String? company,
    String? position,
    String? status,
    String? applicationDate,
    String? deadline,
    String? notes,
    String? contactEmail,
    String? jobUrl,
    String? salary,
    String? location,
  }) {
    return JobApplication(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      status: status ?? this.status,
      applicationDate: applicationDate ?? this.applicationDate,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      contactEmail: contactEmail ?? this.contactEmail,
      jobUrl: jobUrl ?? this.jobUrl,
      salary: salary ?? this.salary,
      location: location ?? this.location,
    );
  }
}

class JobApplicationStatus {
  static const String applied = 'Applied';
  static const String interview = 'Interview';
  static const String offer = 'Offer';
  static const String rejected = 'Rejected';
  static const String pending = 'Pending';

  static List<String> get allStatuses => [
        applied,
        interview,
        offer,
        rejected,
        pending,
      ];
}
