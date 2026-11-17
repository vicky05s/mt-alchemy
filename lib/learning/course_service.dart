import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'course_models.dart';
import 'seed_courses.dart';

/// All Firestore access for courses and enrolments lives here.
class CourseService {
  CourseService._();
  static final CourseService instance = CourseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');
  CollectionReference<Map<String, dynamic>> get _enrolments =>
      _db.collection('enrolments');

  // ------------------------------------------------------------------ courses
  Stream<List<Course>> publishedCourses() {
    return _courses
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((s) {
      final list = s.docs.map(Course.fromDoc).toList();
      list.sort((a, b) => a.title.compareTo(b.title));
      return list;
    });
  }

  Stream<Course?> course(String id) {
    return _courses
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? Course.fromDoc(d) : null);
  }

  Future<Course?> getCourse(String id) async {
    final d = await _courses.doc(id).get();
    return d.exists ? Course.fromDoc(d) : null;
  }

  /// Admin/trainer only (enforced by Firestore rules). Safe to run twice.
  Future<void> loadSampleCourses() async {
    final batch = _db.batch();
    for (final c in sampleCourses()) {
      batch.set(_courses.doc(c.id), c.toMap());
    }
    await batch.commit();
  }

  // --------------------------------------------------------------- enrolments
  String enrolmentId(String uid, String courseId) => '${uid}_$courseId';

  Stream<Enrolment?> enrolment(String uid, String courseId) {
    return _enrolments
        .doc(enrolmentId(uid, courseId))
        .snapshots()
        .map((d) => d.exists ? Enrolment.fromDoc(d) : null);
  }

  Future<void> enrol(Course course, String uid, {double amountPaid = 0}) {
    return _enrolments.doc(enrolmentId(uid, course.id)).set({
      'uid': uid,
      'courseId': course.id,
      'courseTitle': course.title,
      'status': 'in_progress',
      'progress': 0,
      'completedLessons': <String>[],
      'lastModule': 0,
      'lastLesson': 0,
      'learningHours': 0,
      'amountPaid': amountPaid,
      'paymentStatus': amountPaid > 0 ? 'paid' : 'free',
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Opens an employer-assigned course: creates the learner's enrolment on
  /// first use (the employer already paid, so there is no checkout).
  Future<void> enrolFromAssignment(Course course, String uid) async {
    final ref = _enrolments.doc(enrolmentId(uid, course.id));
    final existing = await ref.get();
    if (existing.exists) return;
    await ref.set({
      'uid': uid,
      'courseId': course.id,
      'courseTitle': course.title,
      'status': 'in_progress',
      'progress': 0,
      'completedLessons': <String>[],
      'lastModule': 0,
      'lastLesson': 0,
      'learningHours': 0,
      'amountPaid': 0,
      'paymentStatus': 'employer_paid',
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Keeps the employer's assignment record in step with the learner's
  /// own progress (only does anything for employer-assigned courses).
  Future<void> _syncAssignments({
    required String courseId,
    int? progress,
    double? hours,
    int? score,
    bool passed = false,
  }) async {
    final email = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    if (email == null) return;
    try {
      final snap = await _db
          .collection('assignments')
          .where('employeeEmail', isEqualTo: email)
          .where('courseId', isEqualTo: courseId)
          .get();
      for (final d in snap.docs) {
        final data = d.data();
        if (data['status'] == 'completed') continue;
        final update = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (progress != null) update['progress'] = progress;
        if (hours != null) update['learningHours'] = hours;
        if (score != null) update['score'] = score;
        if (passed) {
          update['status'] = 'completed';
          update['progress'] = 100;
        } else if ((progress ?? 0) > 0 && data['status'] == 'pending') {
          update['status'] = 'in_progress';
        }
        await d.reference.update(update);
      }
    } catch (e) {
      debugPrint('Assignment sync skipped: $e');
    }
  }

  String? _courseIdOf(String enrolmentDocId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !enrolmentDocId.startsWith('${uid}_')) return null;
    return enrolmentDocId.substring(uid.length + 1);
  }

  Future<void> saveProgress({
    required String id,
    required List<String> completed,
    required int totalLessons,
    required int lastModule,
    required int lastLesson,
    required double learningHours,
  }) {
    final pct =
        totalLessons == 0 ? 0 : ((completed.length / totalLessons) * 100).round();
    return _enrolments.doc(id).update({
      'completedLessons': completed,
      'progress': pct,
      'lastModule': lastModule,
      'lastLesson': lastLesson,
      'learningHours': learningHours,
      'updatedAt': FieldValue.serverTimestamp(),
    }).then((_) {
      final courseId = _courseIdOf(id);
      if (courseId != null) {
        _syncAssignments(
            courseId: courseId, progress: pct, hours: learningHours);
      }
    });
  }

  // -------------------------------------------------------------- assessment
  /// Saves one assessment attempt on the learner's enrolment.
  Future<void> recordAttempt({
    required String enrolmentId,
    required int percent,
    required int bestPercent,
    required bool passed,
  }) {
    return _enrolments.doc(enrolmentId).update({
      'attempts': FieldValue.increment(1),
      'lastScore': percent,
      'bestScore': bestPercent,
      if (passed) ...{
        'passed': true,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      },
    }).then((_) {
      final courseId = _courseIdOf(enrolmentId);
      if (courseId != null) {
        _syncAssignments(
            courseId: courseId, score: bestPercent, passed: passed);
      }
    });
  }

  // ------------------------------------------------------------ certificates
  String _newCertificateId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final code = List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
    return 'MTA-${DateTime.now().year}-$code';
  }

  /// Returns the learner's certificate ID for this course, creating the
  /// certificate the first time (call only after the assessment is passed).
  Future<String> ensureCertificate({
    required Course course,
    required String uid,
    required String learnerName,
  }) async {
    final enrolmentRef = _enrolments.doc(enrolmentId(uid, course.id));
    final snap = await enrolmentRef.get();
    final existing = (snap.data()?['certificateId'] ?? '') as String;
    if (existing.isNotEmpty) return existing;

    final id = _newCertificateId();
    await _db.collection('certificates').doc(id).set({
      'uid': uid,
      'learnerName': learnerName,
      'courseId': course.id,
      'courseTitle': course.title,
      'instructor': course.instructor,
      'issuedAt': FieldValue.serverTimestamp(),
    });
    await enrolmentRef.update({'certificateId': id});
    return id;
  }

  Stream<CertificateRecord?> certificate(String id) {
    return _db
        .collection('certificates')
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? CertificateRecord.fromDoc(d) : null);
  }

  Future<CertificateRecord?> getCertificate(String id) async {
    final d = await _db.collection('certificates').doc(id).get();
    return d.exists ? CertificateRecord.fromDoc(d) : null;
  }
}
