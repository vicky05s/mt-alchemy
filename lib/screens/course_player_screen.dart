import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../learning/lesson_view.dart';
import '../theme/app_theme.dart';
import 'assessment_screen.dart';
import 'certificate_screen.dart';

/// Course player. Loads the course and the learner's enrolment from Firestore
/// and saves progress as the learner completes lessons.
class CoursePlayerScreen extends StatefulWidget {
  final String courseId;
  const CoursePlayerScreen({super.key, required this.courseId});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  late final Stream<Course?> _course;
  Stream<Enrolment?>? _enrolment;
  int _module = 0;
  int _lesson = 0;
  bool _positioned = false; // set the start position only once

  @override
  void initState() {
    super.initState();
    _course = CourseService.instance.course(widget.courseId);
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      _enrolment = CourseService.instance.enrolment(uid, widget.courseId);
    }
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  // ------------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final isStaff = context
        .watch<AuthProvider>()
        .hasRole([UserRole.admin, UserRole.trainer]);

    return StreamBuilder<Course?>(
      stream: _course,
      builder: (context, courseSnap) {
        if (courseSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final course = courseSnap.data;
        if (course == null || course.modules.isEmpty) {
          return _simple('This course has no content yet.');
        }
        if (_enrolment == null) {
          return _simple('Please sign in to open this course.');
        }

        return StreamBuilder<Enrolment?>(
          stream: _enrolment,
          builder: (context, enSnap) {
            if (enSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            final enrolment = enSnap.data;
            if (enrolment == null && !isStaff) {
              return _simple(
                  'You are not enrolled in this course yet. Open the course page and tap Enrol.');
            }

            if (!_positioned) {
              if (enrolment != null) {
                _module = enrolment.lastModule.clamp(0, course.modules.length - 1);
                _lesson = enrolment.lastLesson
                    .clamp(0, course.modules[_module].lessons.length - 1);
              }
              _positioned = true;
            }
            return _player(course, enrolment);
          },
        );
      },
    );
  }

  Scaffold _simple(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Player')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _player(Course course, Enrolment? enrolment) {
    final done = enrolment?.completed.toSet() ?? <String>{};
    final total = course.lessonCount;
    final percent = total == 0 ? 0 : ((done.length / total) * 100).round();
    final module = course.modules[_module];
    final lesson = module.lessons[_lesson];
    final isDone = done.contains(lessonKey(_module, _lesson));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Progress $percent%',
                style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (desktop)
                SizedBox(width: 340, child: _sidebar(course, enrolment, done, percent)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(desktop ? 40 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!desktop) _mobileModuleSelector(course, enrolment),
                      if (enrolment == null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                              'Staff preview: your progress is not saved.'),
                        ),
                      Text(
                        'MODULE ${_module + 1} · LESSON ${_lesson + 1} OF ${module.lessons.length}',
                        style: const TextStyle(
                          color: AppTheme.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEDEAF4),
                          color: AppTheme.purple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Course Progress: $percent%',
                          style: const TextStyle(
                              color: AppTheme.greyText, fontSize: 12)),
                      const SizedBox(height: 24),
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 14),
                      LessonContent(
                        lesson: lesson,
                        posterImage: course.image,
                        tall: desktop,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _previous(course, enrolment),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _toggleComplete(course, enrolment),
                              icon: Icon(isDone
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline),
                              label: Text(isDone ? 'Completed' : 'Mark Complete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDone ? const Color(0xFF4C7A6B) : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _next(course, enrolment),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (percent == 100) _quizCard(course, enrolment),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------- sidebar
  Widget _sidebar(
      Course course, Enrolment? enrolment, Set<String> done, int percent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'COURSE CONTENT',
              style: TextStyle(
                color: AppTheme.purple,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: course.modules.length,
              itemBuilder: (context, mi) {
                final module = course.modules[mi];
                final moduleDone = module.lessons.isNotEmpty &&
                    List.generate(module.lessons.length,
                            (li) => done.contains(lessonKey(mi, li)))
                        .every((x) => x);
                return ExpansionTile(
                  key: PageStorageKey('module-$mi'),
                  initiallyExpanded: mi == _module,
                  leading: Icon(
                    moduleDone
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: moduleDone
                        ? const Color(0xFF4C7A6B)
                        : AppTheme.greyText,
                    size: 20,
                  ),
                  title: Text('Module ${mi + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(module.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  children: [
                    for (var li = 0; li < module.lessons.length; li++)
                      ListTile(
                        selected: mi == _module && li == _lesson,
                        selectedTileColor:
                            AppTheme.softYellow.withValues(alpha: 0.25),
                        leading: Icon(
                          done.contains(lessonKey(mi, li))
                              ? Icons.check_circle
                              : (mi == _module && li == _lesson
                                  ? Icons.play_circle
                                  : Icons.radio_button_unchecked),
                          color: done.contains(lessonKey(mi, li))
                              ? const Color(0xFF4C7A6B)
                              : (mi == _module && li == _lesson
                                  ? AppTheme.purple
                                  : AppTheme.greyText),
                        ),
                        title: Text(
                          module.lessons[li].title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: mi == _module && li == _lesson
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        onTap: () => _goTo(course, enrolment, mi, li),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileModuleSelector(Course course, Enrolment? enrolment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _module,
          isExpanded: true,
          items: [
            for (var i = 0; i < course.modules.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text('Module ${i + 1}: ${course.modules[i].title}',
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) _goTo(course, enrolment, v, 0);
          },
        ),
      ),
    );
  }

  Widget _quizCard(Course course, Enrolment? enrolment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.purple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.quiz_outlined, color: AppTheme.softYellow, size: 32),
          const SizedBox(height: 14),
          const Text(
            'All lessons complete. Ready for the assessment?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the course assessment to test your understanding and earn your certificate.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AssessmentScreen(course: course, enrolment: enrolment),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softYellow,
              foregroundColor: AppTheme.deepBlue,
            ),
            child: Text(enrolment?.passed == true
                ? 'Retake Assessment'
                : 'Start Assessment'),
          ),
          if (enrolment != null &&
              enrolment.passed &&
              enrolment.certificateId.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CertificateScreen(certificateId: enrolment.certificateId),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              icon: const Icon(Icons.workspace_premium),
              label: Text('View Certificate (best score ${enrolment.bestScore}%)'),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- actions
  Future<void> _save(Course course, Enrolment enrolment, List<String> done,
      {int? module, int? lesson}) {
    return CourseService.instance.saveProgress(
      id: enrolment.id,
      completed: done,
      totalLessons: course.lessonCount,
      lastModule: module ?? _module,
      lastLesson: lesson ?? _lesson,
      learningHours: course.minutesFor(done) / 60.0,
    );
  }

  Future<void> _toggleComplete(Course course, Enrolment? enrolment) async {
    if (enrolment == null) {
      _snack('Preview mode: progress is not saved.');
      return;
    }
    final done = enrolment.completed.toSet();
    final key = lessonKey(_module, _lesson);
    if (!done.add(key)) done.remove(key);
    try {
      await _save(course, enrolment, done.toList());
    } catch (e) {
      debugPrint('Save progress failed: $e');
      if (mounted) _snack('Could not save your progress. Please try again.');
    }
  }

  void _goTo(Course course, Enrolment? enrolment, int module, int lesson) {
    setState(() {
      _module = module;
      _lesson = lesson;
    });
    if (enrolment != null) {
      _save(course, enrolment, enrolment.completed, module: module, lesson: lesson)
          .catchError((Object e) => debugPrint('Save position failed: $e'));
    }
  }

  void _next(Course course, Enrolment? enrolment) {
    final lessons = course.modules[_module].lessons;
    if (_lesson < lessons.length - 1) {
      _goTo(course, enrolment, _module, _lesson + 1);
    } else if (_module < course.modules.length - 1) {
      _goTo(course, enrolment, _module + 1, 0);
    } else {
      _snack('You have reached the end of the course.');
    }
  }

  void _previous(Course course, Enrolment? enrolment) {
    if (_lesson > 0) {
      _goTo(course, enrolment, _module, _lesson - 1);
    } else if (_module > 0) {
      final prev = _module - 1;
      _goTo(course, enrolment, prev, course.modules[prev].lessons.length - 1);
    } else {
      _snack('You are already at the first lesson.');
    }
  }
}
