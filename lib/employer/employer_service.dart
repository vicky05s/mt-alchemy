import 'package:cloud_firestore/cloud_firestore.dart';

import '../learning/course_models.dart';
import 'employer_models.dart';

/// All Firestore access for the employer journey.
///
/// How employees are linked: an employer adds an employee by e-mail. When
/// that person registers (or logs in) with the same e-mail, the courses
/// assigned to that e-mail appear on their own dashboard automatically.
class EmployerService {
  EmployerService._();
  static final EmployerService instance = EmployerService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _employees =>
      _db.collection('employees');
  CollectionReference<Map<String, dynamic>> get _assignments =>
      _db.collection('assignments');
  CollectionReference<Map<String, dynamic>> get _licenses =>
      _db.collection('licenses');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  // --------------------------------------------------------------- employer
  Stream<List<EmployeeRecord>> employees(String orgId) {
    return _employees
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map((s) {
      final list = s.docs.map(EmployeeRecord.fromDoc).toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Stream<List<AssignmentRecord>> assignments(String orgId) {
    return _assignments
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map((s) => s.docs.map(AssignmentRecord.fromDoc).toList());
  }

  Stream<List<LicenseRecord>> licenses(String orgId) {
    return _licenses
        .where('organizationId', isEqualTo: orgId)
        .snapshots()
        .map((s) {
      final list = s.docs.map(LicenseRecord.fromDoc).toList();
      list.sort((a, b) => a.courseTitle.compareTo(b.courseTitle));
      return list;
    });
  }

  Future<void> addEmployee({
    required String orgId,
    required String name,
    required String email,
    required String department,
    required String jobRole,
  }) {
    return _employees.add({
      'organizationId': orgId,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'department': department.trim(),
      'jobRole': jobRole.trim(),
      'status': 'Invited',
      'uid': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEmployee(
    String id, {
    required String name,
    required String department,
    required String jobRole,
  }) {
    return _employees.doc(id).update({
      'name': name.trim(),
      'department': department.trim(),
      'jobRole': jobRole.trim(),
    });
  }

  /// Removes the employee and their assignments.
  Future<void> removeEmployee(String orgId, String employeeId) async {
    final batch = _db.batch();
    final theirs = await _assignments
        .where('organizationId', isEqualTo: orgId)
        .where('employeeId', isEqualTo: employeeId)
        .get();
    for (final d in theirs.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_employees.doc(employeeId));
    await batch.commit();
  }

  /// Buys [seats] places on a course for the organisation.
  Future<void> purchaseLicense({
    required String orgId,
    required Course course,
    required int seats,
    required double amountPaid,
  }) {
    return _licenses.doc('${orgId}_${course.id}').set({
      'organizationId': orgId,
      'courseId': course.id,
      'courseTitle': course.title,
      'pricePerSeat': course.price,
      'seats': FieldValue.increment(seats),
      'amountPaid': FieldValue.increment(amountPaid),
      'purchasedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Assigns a course to the chosen employees and notifies each of them.
  Future<void> assignCourse({
    required String orgId,
    required String orgName,
    required String courseId,
    required String courseTitle,
    required List<EmployeeRecord> employees,
    required DateTime deadline,
  }) async {
    final batch = _db.batch();
    final due = Timestamp.fromDate(deadline);

    for (final e in employees) {
      batch.set(_assignments.doc('${orgId}_${e.id}_$courseId'), {
        'organizationId': orgId,
        'employeeId': e.id,
        'employeeName': e.name,
        'employeeEmail': e.email,
        'department': e.department,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'deadline': due,
        'status': 'pending',
        'progress': 0,
        'score': 0,
        'learningHours': 0,
        'assignedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_notifications.doc(), {
        'recipientEmail': e.email,
        'title': 'New course assigned',
        'body':
            '$orgName assigned you "$courseTitle". Please complete it by ${formatDate(deadline)}.',
        'courseId': courseId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // --------------------------------------------------------------- employee
  Stream<List<AssignmentRecord>> assignmentsForEmployee(String email) {
    return _assignments
        .where('employeeEmail', isEqualTo: email.toLowerCase())
        .snapshots()
        .map((s) {
      final list = s.docs.map(AssignmentRecord.fromDoc).toList();
      list.sort((a, b) {
        final da = a.deadline ?? DateTime(2100);
        final db = b.deadline ?? DateTime(2100);
        return da.compareTo(db);
      });
      return list;
    });
  }

  Stream<List<NotificationRecord>> notificationsFor(String email) {
    return _notifications
        .where('recipientEmail', isEqualTo: email.toLowerCase())
        .snapshots()
        .map((s) {
      final list = s.docs.map(NotificationRecord.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> markRead(String notificationId) {
    return _notifications.doc(notificationId).update({'read': true});
  }

  /// Marks the employee record(s) for this e-mail as Active.
  Future<void> linkAccount(String uid, String email) async {
    try {
      final snap = await _employees
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      for (final d in snap.docs) {
        if (d.data()['uid'] != uid) {
          await d.reference.update({'uid': uid, 'status': 'Active'});
        }
      }
    } catch (_) {
      // Not an employee of anyone, or rules not published yet. Safe to ignore.
    }
  }
}
