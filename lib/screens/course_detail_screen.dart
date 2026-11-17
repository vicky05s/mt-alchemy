import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../learning/payment_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'course_player_screen.dart';
import 'login_screen.dart';

/// Course detail page for one course, loaded from Firestore by id.
class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final Stream<Course?> _course;
  Stream<Enrolment?>? _enrolment;
  bool _busy = false;

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

  void _openPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CoursePlayerScreen(courseId: widget.courseId)),
    );
  }

  Future<void> _enrol(Course course) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    var paid = 0.0;
    if (course.price > 0) {
      final result = await showSimulatedPayment(
        context,
        title: course.title,
        amount: course.price,
      );
      if (!mounted) return;
      switch (result) {
        case PaymentResult.failed:
          _snack('Payment failed. You have not been charged.');
          return;
        case PaymentResult.pending:
          _snack('Payment pending. You will get access once it is confirmed.');
          return;
        case PaymentResult.cancelled:
          return;
        case PaymentResult.successful:
          paid = course.price;
      }
    }

    setState(() => _busy = true);
    try {
      await CourseService.instance.enrol(course, uid, amountPaid: paid);
      if (!mounted) return;
      _snack('Payment successful. You are enrolled in ${course.title}.');
      _openPlayer();
    } catch (e) {
      debugPrint('Enrol failed: $e');
      if (mounted) _snack('Could not enrol. Please try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: const MainAppBar(),
      body: StreamBuilder<Course?>(
        stream: _course,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final course = snap.data;
          if (snap.hasError || course == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This course could not be found.'),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final enrolCard = _enrolSection(course);

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 48 : 18, vertical: 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1250),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(course, desktop),
                        const SizedBox(height: 24),
                        if (desktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _content(course)),
                              const SizedBox(width: 22),
                              SizedBox(width: 340, child: enrolCard),
                            ],
                          )
                        else ...[
                          enrolCard,
                          const SizedBox(height: 24),
                          _content(course),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------- sections
  Widget _hero(Course course, bool desktop) {
    return Container(
      height: desktop ? 350 : 430,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(course.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppTheme.deepBlue)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.deepBlue.withValues(alpha: 0.98),
                  AppTheme.deepBlue.withValues(alpha: 0.80),
                  AppTheme.deepBlue.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(desktop ? 34 : 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pill(
                        '${course.category.toUpperCase()}  •  ${course.moduleCount} MODULES'),
                    const SizedBox(height: 14),
                    Text(
                      course.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: desktop ? 42 : 34,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABOUT THIS COURSE',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          course.title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          course.about.isEmpty ? course.description : course.about,
          style: const TextStyle(
              color: AppTheme.greyText, fontSize: 14, height: 1.6),
        ),
        if (course.audience.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                  color: AppTheme.greyText, fontSize: 13, height: 1.5),
              children: [
                const TextSpan(
                  text: 'Who it is for: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: AppTheme.darkText),
                ),
                TextSpan(text: course.audience),
              ],
            ),
          ),
        ],
        if (course.objectives.isNotEmpty) ...[
          const SizedBox(height: 24),
          _listCard('WHAT YOU WILL DEVELOP', course.objectives),
        ],
        if (course.requirements.isNotEmpty) ...[
          const SizedBox(height: 16),
          _listCard('REQUIREMENTS', course.requirements),
        ],
        const SizedBox(height: 28),
        const Text(
          'COURSE CONTENT',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < course.modules.length; i++)
          _module(i + 1, course.modules[i]),
      ],
    );
  }

  Widget _listCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppTheme.purple, size: 14),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                          color: AppTheme.greyText, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _module(int number, CourseModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.deepBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        title: Text(
          module.title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${module.lessons.length} lessons',
          style: const TextStyle(color: AppTheme.greyText, fontSize: 10),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- enrol card
  Widget _enrolSection(Course course) {
    final auth = context.watch<AuthProvider>();

    Widget card(Widget action, {String? note}) =>
        _enrolCard(course, action, note);

    if (!auth.isLoggedIn) {
      return card(
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Text('Sign in to enrol'),
        ),
        note: 'Create a free account to enrol in this course.',
      );
    }

    if (auth.role != UserRole.individual) {
      final staff = auth.hasRole([UserRole.admin, UserRole.trainer]);
      return card(
        staff
            ? ElevatedButton(
                onPressed: _openPlayer,
                child: const Text('Preview Course'),
              )
            : const SizedBox.shrink(),
        note: staff
            ? 'Staff preview: progress is not saved.'
            : 'Employers buy programmes for their team from the Employer Dashboard.',
      );
    }

    return StreamBuilder<Enrolment?>(
      stream: _enrolment,
      builder: (context, snap) {
        final enrolment = snap.data;
        if (enrolment != null) {
          return card(
            ElevatedButton(
              onPressed: _openPlayer,
              child: Text(enrolment.progress == 0
                  ? 'Start Course'
                  : 'Continue Course (${enrolment.progress}%)'),
            ),
            note: 'You are enrolled in this course.',
          );
        }
        return card(
          ElevatedButton(
            onPressed: _busy ? null : () => _enrol(course),
            child: Text(_busy
                ? 'Enrolling…'
                : (course.price > 0
                    ? 'Enrol · ${course.priceLabel}'
                    : 'Enrol for Free')),
          ),
          note: course.price > 0
              ? 'Demo checkout: no real payment is taken.'
              : null,
        );
      },
    );
  }

  Widget _enrolCard(Course course, Widget action, String? note) {
    final hours = course.durationHours;
    final hoursText = hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE4E0E9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR NEXT STEP',
            style: TextStyle(
              color: AppTheme.purple,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            course.priceLabel,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 17),
          _infoRow(Icons.person_outline_rounded, 'Instructor: ${course.instructor}'),
          _infoRow(Icons.signal_cellular_alt_rounded, 'Level: ${course.level}'),
          _infoRow(Icons.schedule_rounded, '$hoursText hours · self-paced'),
          _infoRow(Icons.menu_book_rounded,
              '${course.moduleCount} modules · ${course.lessonCount} lessons'),
          _infoRow(Icons.quiz_outlined, 'Assessment included'),
          if (course.certificate)
            _infoRow(Icons.workspace_premium_outlined,
                'Certificate on completion'),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: action),
          if (note != null) ...[
            const SizedBox(height: 9),
            Center(
              child: Text(
                note,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.greyText, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.purple, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.softYellow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.deepBlue,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
