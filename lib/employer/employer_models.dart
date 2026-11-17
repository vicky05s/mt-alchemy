import 'package:cloud_firestore/cloud_firestore.dart';

/// An employee added by an employer (collection `employees`).
class EmployeeRecord {
  final String id;
  final String organizationId; // the employer's uid
  final String name;
  final String email; // stored lowercase
  final String department;
  final String jobRole;
  final String status; // Invited | Active

  const EmployeeRecord({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.email,
    required this.department,
    required this.jobRole,
    required this.status,
  });

  factory EmployeeRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return EmployeeRecord(
      id: doc.id,
      organizationId: (d['organizationId'] ?? '') as String,
      name: (d['name'] ?? '') as String,
      email: (d['email'] ?? '') as String,
      department: (d['department'] ?? '') as String,
      jobRole: (d['jobRole'] ?? '') as String,
      status: (d['status'] ?? 'Invited') as String,
    );
  }
}

/// A course assigned to one employee (collection `assignments`).
class AssignmentRecord {
  final String id;
  final String organizationId;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String department;
  final String courseId;
  final String courseTitle;
  final DateTime? deadline;
  final String status; // pending | in_progress | completed
  final int progress; // 0-100
  final int score; // best assessment score, 0 if none
  final double learningHours;
  final DateTime assignedAt;

  const AssignmentRecord({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.department,
    required this.courseId,
    required this.courseTitle,
    required this.deadline,
    required this.status,
    required this.progress,
    required this.score,
    required this.learningHours,
    required this.assignedAt,
  });

  bool get completed => status == 'completed';
  bool get overdue =>
      !completed && deadline != null && deadline!.isBefore(DateTime.now());

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Not started';
    }
  }

  factory AssignmentRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return AssignmentRecord(
      id: doc.id,
      organizationId: (d['organizationId'] ?? '') as String,
      employeeId: (d['employeeId'] ?? '') as String,
      employeeName: (d['employeeName'] ?? '') as String,
      employeeEmail: (d['employeeEmail'] ?? '') as String,
      department: (d['department'] ?? '') as String,
      courseId: (d['courseId'] ?? '') as String,
      courseTitle: (d['courseTitle'] ?? '') as String,
      deadline: (d['deadline'] as Timestamp?)?.toDate(),
      status: (d['status'] ?? 'pending') as String,
      progress: ((d['progress'] ?? 0) as num).toInt(),
      score: ((d['score'] ?? 0) as num).toInt(),
      learningHours: ((d['learningHours'] ?? 0) as num).toDouble(),
      assignedAt: (d['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Seats an organisation bought for a course (collection `licenses`).
class LicenseRecord {
  final String id;
  final String courseId;
  final String courseTitle;
  final int seats;
  final double pricePerSeat;
  final double amountPaid;
  final DateTime purchasedAt;

  const LicenseRecord({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.seats,
    required this.pricePerSeat,
    required this.amountPaid,
    required this.purchasedAt,
  });

  factory LicenseRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return LicenseRecord(
      id: doc.id,
      courseId: (d['courseId'] ?? '') as String,
      courseTitle: (d['courseTitle'] ?? '') as String,
      seats: ((d['seats'] ?? 0) as num).toInt(),
      pricePerSeat: ((d['pricePerSeat'] ?? 0) as num).toDouble(),
      amountPaid: ((d['amountPaid'] ?? 0) as num).toDouble(),
      purchasedAt: (d['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// A message for an employee, e.g. "A course was assigned to you".
class NotificationRecord {
  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory NotificationRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return NotificationRecord(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      body: (d['body'] ?? '') as String,
      read: (d['read'] ?? false) as bool,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
