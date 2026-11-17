import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One lesson inside a module. `type` decides how the player shows it:
/// video | text | pdf | audio | image | link
class Lesson {
  final String title;
  final String type;
  final String body;
  final String url;
  final int minutes;

  const Lesson({
    required this.title,
    this.type = 'text',
    this.body = '',
    this.url = '',
    this.minutes = 10,
  });

  factory Lesson.fromMap(Map<String, dynamic> m) => Lesson(
        title: (m['title'] ?? '') as String,
        type: (m['type'] ?? 'text') as String,
        body: (m['body'] ?? '') as String,
        url: (m['url'] ?? '') as String,
        minutes: ((m['minutes'] ?? 10) as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type,
        'body': body,
        'url': url,
        'minutes': minutes,
      };
}

class CourseModule {
  final String title;
  final List<Lesson> lessons;

  const CourseModule({required this.title, required this.lessons});

  factory CourseModule.fromMap(Map<String, dynamic> m) => CourseModule(
        title: (m['title'] ?? '') as String,
        lessons: ((m['lessons'] ?? const []) as List)
            .map((l) => Lesson.fromMap(Map<String, dynamic>.from(l as Map)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'lessons': lessons.map((l) => l.toMap()).toList(),
      };
}

/// Key used to remember a completed lesson: "moduleIndex-lessonIndex".
String lessonKey(int module, int lesson) => '$module-$lesson';

/// One assessment question.
/// type: single | truefalse | multiple | short
class Question {
  final String type;
  final String text;
  final List<String> options; // for single / truefalse / multiple
  final List<int> correct; // indexes of the correct options
  final List<String> accepted; // for short answers: accepted keywords
  final String explanation;

  const Question({
    required this.type,
    required this.text,
    this.options = const [],
    this.correct = const [],
    this.accepted = const [],
    this.explanation = '',
  });

  factory Question.single(String text, List<String> options, int correct,
          {String explanation = ''}) =>
      Question(
        type: 'single',
        text: text,
        options: options,
        correct: [correct],
        explanation: explanation,
      );

  factory Question.trueFalse(String text, bool answer,
          {String explanation = ''}) =>
      Question(
        type: 'truefalse',
        text: text,
        options: const ['True', 'False'],
        correct: [answer ? 0 : 1],
        explanation: explanation,
      );

  factory Question.multiple(String text, List<String> options, List<int> correct,
          {String explanation = ''}) =>
      Question(
        type: 'multiple',
        text: text,
        options: options,
        correct: correct,
        explanation: explanation,
      );

  factory Question.short(String text, List<String> accepted,
          {String explanation = ''}) =>
      Question(
        type: 'short',
        text: text,
        accepted: accepted,
        explanation: explanation,
      );

  factory Question.fromMap(Map<String, dynamic> m) => Question(
        type: (m['type'] ?? 'single') as String,
        text: (m['text'] ?? '') as String,
        options: List<String>.from(m['options'] ?? const []),
        correct: List<int>.from(
            ((m['correct'] ?? const []) as List).map((e) => (e as num).toInt())),
        accepted: List<String>.from(m['accepted'] ?? const []),
        explanation: (m['explanation'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'text': text,
        'options': options,
        'correct': correct,
        'accepted': accepted,
        'explanation': explanation,
      };

  /// True when the learner's answer is right.
  bool isCorrect({Set<int> picked = const {}, String typed = ''}) {
    if (type == 'short') {
      final t = typed.trim().toLowerCase();
      if (t.isEmpty) return false;
      return accepted.any((a) => t.contains(a.toLowerCase()));
    }
    return picked.length == correct.length && picked.containsAll(correct);
  }

  /// Human readable correct answer, for the review screen.
  String get correctText {
    if (type == 'short') return accepted.isEmpty ? '' : accepted.first;
    return correct.map((i) => options[i]).join(', ');
  }
}

class Assessment {
  final int passingScore; // percent
  final List<Question> questions;

  const Assessment({this.passingScore = 60, required this.questions});

  factory Assessment.fromMap(Map<String, dynamic> m) => Assessment(
        passingScore: ((m['passingScore'] ?? 60) as num).toInt(),
        questions: ((m['questions'] ?? const []) as List)
            .map((q) => Question.fromMap(Map<String, dynamic>.from(q as Map)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'passingScore': passingScore,
        'questions': questions.map((q) => q.toMap()).toList(),
      };
}

/// An issued certificate (doc id = certificate ID, e.g. MTA-2026-K7QX2M).
class CertificateRecord {
  final String id;
  final String uid;
  final String learnerName;
  final String courseId;
  final String courseTitle;
  final String instructor;
  final DateTime issuedAt;

  const CertificateRecord({
    required this.id,
    required this.uid,
    required this.learnerName,
    required this.courseId,
    required this.courseTitle,
    required this.instructor,
    required this.issuedAt,
  });

  factory CertificateRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return CertificateRecord(
      id: doc.id,
      uid: (d['uid'] ?? '') as String,
      learnerName: (d['learnerName'] ?? '') as String,
      courseId: (d['courseId'] ?? '') as String,
      courseTitle: (d['courseTitle'] ?? '') as String,
      instructor: (d['instructor'] ?? 'MT Alchemy') as String,
      issuedAt: (d['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final String about;
  final String instructor;
  final String level;
  final double durationHours;
  final double price;
  final String status; // draft | published | archived
  final bool featured;
  final String image; // asset path
  final String accent; // purple | blue | yellow | green
  final bool certificate;
  final String audience;
  final List<String> objectives;
  final List<String> requirements;
  final List<CourseModule> modules;
  final Assessment? assessment;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.about = '',
    this.instructor = 'MT Alchemy',
    this.level = 'Beginner',
    this.durationHours = 0,
    this.price = 0,
    this.status = 'published',
    this.featured = false,
    this.image = 'assets/images/leadership_discussion.png',
    this.accent = 'purple',
    this.certificate = true,
    this.audience = '',
    this.objectives = const [],
    this.requirements = const [],
    this.modules = const [],
    this.assessment,
  });

  int get moduleCount => modules.length;
  int get lessonCount =>
      modules.fold<int>(0, (sum, m) => sum + m.lessons.length);

  /// Total minutes of the lessons whose keys are in [keys].
  int minutesFor(Iterable<String> keys) {
    final set = keys.toSet();
    var total = 0;
    for (var m = 0; m < modules.length; m++) {
      for (var l = 0; l < modules[m].lessons.length; l++) {
        if (set.contains(lessonKey(m, l))) total += modules[m].lessons[l].minutes;
      }
    }
    return total;
  }

  String get priceLabel =>
      price <= 0 ? 'Free' : 'RM ${price.toStringAsFixed(0)}';

  Color get accentColor {
    switch (accent) {
      case 'blue':
        return AppTheme.deepBlue;
      case 'yellow':
        return AppTheme.softYellow;
      case 'green':
        return const Color(0xFF4C7A6B);
      default:
        return AppTheme.purple;
    }
  }

  bool get darkText => accent == 'yellow';

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Course(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      description: (d['description'] ?? '') as String,
      about: (d['about'] ?? '') as String,
      instructor: (d['instructor'] ?? 'MT Alchemy') as String,
      level: (d['level'] ?? 'Beginner') as String,
      durationHours: ((d['durationHours'] ?? 0) as num).toDouble(),
      price: ((d['price'] ?? 0) as num).toDouble(),
      status: (d['status'] ?? 'draft') as String,
      featured: (d['featured'] ?? false) as bool,
      image: (d['image'] ?? 'assets/images/leadership_discussion.png') as String,
      accent: (d['accent'] ?? 'purple') as String,
      certificate: (d['certificate'] ?? true) as bool,
      audience: (d['audience'] ?? '') as String,
      objectives: List<String>.from(d['objectives'] ?? const []),
      requirements: List<String>.from(d['requirements'] ?? const []),
      modules: ((d['modules'] ?? const []) as List)
          .map((m) => CourseModule.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      assessment: d['assessment'] == null
          ? null
          : Assessment.fromMap(Map<String, dynamic>.from(d['assessment'] as Map)),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'description': description,
        'about': about,
        'instructor': instructor,
        'level': level,
        'durationHours': durationHours,
        'price': price,
        'status': status,
        'featured': featured,
        'image': image,
        'accent': accent,
        'certificate': certificate,
        'audience': audience,
        'objectives': objectives,
        'requirements': requirements,
        'modules': modules.map((m) => m.toMap()).toList(),
        if (assessment != null) 'assessment': assessment!.toMap(),
      };
}

/// A learner's enrolment in one course (doc id = "<uid>_<courseId>").
class Enrolment {
  final String id;
  final String uid;
  final String courseId;
  final String courseTitle;
  final String status; // in_progress | completed
  final int progress; // 0-100
  final List<String> completed; // lesson keys
  final int lastModule;
  final int lastLesson;
  final double learningHours;
  final bool passed;
  final int bestScore;
  final int attempts;
  final String certificateId;

  const Enrolment({
    required this.id,
    required this.uid,
    required this.courseId,
    required this.courseTitle,
    required this.status,
    required this.progress,
    required this.completed,
    required this.lastModule,
    required this.lastLesson,
    required this.learningHours,
    this.passed = false,
    this.bestScore = 0,
    this.attempts = 0,
    this.certificateId = '',
  });

  factory Enrolment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Enrolment(
      id: doc.id,
      uid: (d['uid'] ?? '') as String,
      courseId: (d['courseId'] ?? '') as String,
      courseTitle: (d['courseTitle'] ?? '') as String,
      status: (d['status'] ?? 'in_progress') as String,
      progress: ((d['progress'] ?? 0) as num).toInt(),
      completed: List<String>.from(d['completedLessons'] ?? const []),
      lastModule: ((d['lastModule'] ?? 0) as num).toInt(),
      lastLesson: ((d['lastLesson'] ?? 0) as num).toInt(),
      learningHours: ((d['learningHours'] ?? 0) as num).toDouble(),
      passed: (d['passed'] ?? false) as bool,
      bestScore: ((d['bestScore'] ?? 0) as num).toInt(),
      attempts: ((d['attempts'] ?? 0) as num).toInt(),
      certificateId: (d['certificateId'] ?? '') as String,
    );
  }
}
