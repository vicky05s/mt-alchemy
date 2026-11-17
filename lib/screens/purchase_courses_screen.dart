import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../employer/employer_models.dart';
import '../employer/employer_service.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../learning/payment_dialog.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';

/// Employers buy seats on a course for their team (brief: "purchase
/// learning programmes for employees" and "manage organization purchases").
class PurchaseCoursesScreen extends StatefulWidget {
  const PurchaseCoursesScreen({super.key});

  @override
  State<PurchaseCoursesScreen> createState() => _PurchaseCoursesScreenState();
}

class _PurchaseCoursesScreenState extends State<PurchaseCoursesScreen> {
  late final String _orgId;
  late final Stream<List<Course>> _courses;
  late final Stream<List<LicenseRecord>> _licenses;
  late final Stream<List<AssignmentRecord>> _assignments;
  final Map<String, int> _seats = {}; // courseId -> chosen seats
  String? _busyCourse;

  @override
  void initState() {
    super.initState();
    _orgId = context.read<AuthProvider>().user?.uid ?? '';
    _courses = CourseService.instance.publishedCourses();
    _licenses = EmployerService.instance.licenses(_orgId);
    _assignments = EmployerService.instance.assignments(_orgId);
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _buy(Course course) async {
    final seats = _seats[course.id] ?? 5;
    final amount = course.price * seats;
    var paid = 0.0;

    if (amount > 0) {
      final result = await showSimulatedPayment(
        context,
        title: '${course.title} × $seats seats',
        amount: amount,
      );
      if (!mounted) return;
      switch (result) {
        case PaymentResult.failed:
          _snack('Payment failed. You have not been charged.');
          return;
        case PaymentResult.pending:
          _snack('Payment pending. Seats are added once it is confirmed.');
          return;
        case PaymentResult.cancelled:
          return;
        case PaymentResult.successful:
          paid = amount;
      }
    }

    setState(() => _busyCourse = course.id);
    try {
      await EmployerService.instance.purchaseLicense(
        orgId: _orgId,
        course: course,
        seats: seats,
        amountPaid: paid,
      );
      _snack('$seats seats added for ${course.title}. You can now assign them.');
    } catch (e) {
      debugPrint('Purchase failed: $e');
      _snack('Could not complete the purchase. Check the Firestore rules.');
    }
    if (mounted) setState(() => _busyCourse = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Purchase Courses',
                    style: TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 30,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                    'Buy seats for your team, then assign them to employees.',
                    style: TextStyle(color: AppTheme.greyText)),
                const SizedBox(height: 20),
                _myLicenses(),
                const SizedBox(height: 20),
                DashCard(
                  title: 'Available courses',
                  child: StreamBuilder<List<Course>>(
                    stream: _courses,
                    builder: (context, snap) {
                      final courses = snap.data ?? const <Course>[];
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (courses.isEmpty) {
                        return const Text(
                            'No courses are published yet.',
                            style: TextStyle(color: AppTheme.greyText));
                      }
                      return Column(
                        children: [for (final c in courses) _courseRow(c)],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _myLicenses() {
    return DashCard(
      title: 'Your purchased courses',
      child: StreamBuilder<List<LicenseRecord>>(
        stream: _licenses,
        builder: (context, licSnap) {
          return StreamBuilder<List<AssignmentRecord>>(
            stream: _assignments,
            builder: (context, asSnap) {
              final licenses = licSnap.data ?? const <LicenseRecord>[];
              final assignments = asSnap.data ?? const <AssignmentRecord>[];
              if (licenses.isEmpty) {
                return const Text(
                    'You have not bought any courses yet. Choose one below.',
                    style: TextStyle(color: AppTheme.greyText));
              }
              return Column(
                children: [
                  for (final l in licenses)
                    Builder(builder: (context) {
                      final used = assignments
                          .where((a) => a.courseId == l.courseId)
                          .length;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.school_outlined,
                            color: AppTheme.purple),
                        title: Text(l.courseTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${l.seats} seats · $used assigned · ${l.seats - used} left · paid ${money(l.amountPaid)}'),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _courseRow(Course c) {
    final seats = _seats[c.id] ?? 5;
    final busy = _busyCourse == c.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          SizedBox(
            width: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        color: AppTheme.deepBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text('${c.category} · ${c.moduleCount} modules · ${money(c.price)} per seat',
                    style: const TextStyle(
                        color: AppTheme.greyText, fontSize: 12)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE4E0E9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: seats > 1
                      ? () => setState(() => _seats[c.id] = seats - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$seats seats',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                IconButton(
                  onPressed: () => setState(() => _seats[c.id] = seats + 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Text(money(c.price * seats),
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          ElevatedButton.icon(
            onPressed: busy ? null : () => _buy(c),
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
            label: Text(busy ? 'Buying…' : 'Buy seats'),
          ),
        ],
      ),
    );
  }
}
