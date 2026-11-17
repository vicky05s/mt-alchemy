import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../employer/employer_models.dart';
import '../employer/employer_service.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';
import 'certificate_screen.dart';
import 'course_player_screen.dart';
import 'courses_screen.dart';
import 'digital_library_screen.dart';
import 'my_orders_screen.dart';
import 'store_screen.dart';

typedef _Snap = AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>;

/// Home / dashboard for Individual Learners (brief Page 10).
/// Numbers come from Firestore: `enrolments` and `orders` where uid == me.
class LearnerHomeScreen extends StatefulWidget {
  const LearnerHomeScreen({super.key});

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _enrolments;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _orders;
  late final Stream<List<AssignmentRecord>> _assigned;
  late final Stream<List<NotificationRecord>> _notes;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    final uid = user?.uid ?? '';
    final email = (user?.email ?? '').toLowerCase();
    _assigned = EmployerService.instance.assignmentsForEmployee(email);
    _notes = EmployerService.instance.notificationsFor(email);
    // If an employer added this e-mail as an employee, mark them Active.
    EmployerService.instance.linkAccount(uid, email);
    final db = FirebaseFirestore.instance;
    _enrolments =
        db.collection('enrolments').where('uid', isEqualTo: uid).snapshots();
    _orders = db.collection('orders').where('uid', isEqualTo: uid).snapshots();
  }

  List<Map<String, dynamic>> _docs(_Snap snap) {
    if (snap.hasError) debugPrint('Dashboard query error: ${snap.error}');
    return snap.data?.docs.map((d) => d.data()).toList() ?? [];
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = (user?.name ?? '').trim();
    final first = name.isEmpty ? 'there' : name.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _enrolments,
              builder: (context, snap) {
                final enrolments = _docs(snap);
                final completed = enrolments
                    .where((e) => e['status'] == 'completed')
                    .toList();
                final inProgress = enrolments
                    .where((e) => e['status'] != 'completed')
                    .toList()
                  ..sort((a, b) => ((b['progress'] ?? 0) as num)
                      .compareTo((a['progress'] ?? 0) as num));
                final hours = enrolments.fold<double>(
                  0,
                  (sum, e) => sum + ((e['learningHours'] ?? 0) as num),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _banner(first),
                    const SizedBox(height: 20),
                    StatGrid(children: [
                      StatCard(
                        icon: Icons.menu_book_rounded,
                        value: '${enrolments.length}',
                        label: 'Courses enrolled',
                      ),
                      StatCard(
                        icon: Icons.timelapse_rounded,
                        value: '${inProgress.length}',
                        label: 'In progress',
                        color: AppTheme.deepBlue,
                      ),
                      StatCard(
                        icon: Icons.verified_rounded,
                        value: '${completed.length}',
                        label: 'Completed',
                        color: const Color(0xFF4C7A6B),
                      ),
                      StatCard(
                        icon: Icons.schedule_rounded,
                        value: hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1),
                        label: 'Learning hours',
                        color: const Color(0xFFD99A00),
                      ),
                    ]),
                    _notificationsCard(),
                    _assignedCard(),
                    const SizedBox(height: 20),
                    LayoutBuilder(builder: (context, c) {
                      final wide = c.maxWidth >= 800;
                      final cont = _continueCard(
                          inProgress.isEmpty ? null : inProgress.first);
                      final ach = _achievementsCard(completed, hours);
                      if (!wide) {
                        return Column(
                            children: [cont, const SizedBox(height: 16), ach]);
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: cont),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: ach),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    _ordersCard(),
                    const SizedBox(height: 16),
                    _profileCard(),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---- notifications from an employer -------------------------------------
  Widget _notificationsCard() {
    return StreamBuilder<List<NotificationRecord>>(
      stream: _notes,
      builder: (context, snap) {
        final unread = (snap.data ?? const <NotificationRecord>[])
            .where((n) => !n.read)
            .take(3)
            .toList();
        if (unread.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: DashCard(
            title: 'Notifications',
            child: Column(
              children: [
                for (final n in unread)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined,
                        color: AppTheme.purple),
                    title: Text(n.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(n.body),
                    trailing: TextButton(
                      onPressed: () =>
                          EmployerService.instance.markRead(n.id),
                      child: const Text('Dismiss'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- courses assigned by an employer ------------------------------------
  Widget _assignedCard() {
    return StreamBuilder<List<AssignmentRecord>>(
      stream: _assigned,
      builder: (context, snap) {
        final items = snap.data ?? const <AssignmentRecord>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: DashCard(
            title: 'Assigned by your employer',
            child: Column(
              children: [
                for (final a in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.courseTitle,
                                  style: const TextStyle(
                                      color: AppTheme.deepBlue,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text(
                                a.deadline == null
                                    ? 'No deadline'
                                    : 'Due ${formatDate(a.deadline!)}${a.overdue ? ' (overdue)' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: a.overdue
                                      ? const Color(0xFFD92D20)
                                      : AppTheme.greyText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: a.progress / 100,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFEDEAF4),
                                  color: AppTheme.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('${a.progress}%',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: a.completed ? null : () => _openAssigned(a),
                          child: Text(a.completed
                              ? 'Completed'
                              : (a.progress == 0 ? 'Start' : 'Continue')),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAssigned(AssignmentRecord a) async {
    final uid = context.read<AuthProvider>().user?.uid;
    final messenger = ScaffoldMessenger.of(context);
    if (uid == null) return;
    try {
      final course = await CourseService.instance.getCourse(a.courseId);
      if (course == null) {
        messenger.showSnackBar(
            const SnackBar(content: Text('This course is no longer available.')));
        return;
      }
      await CourseService.instance.enrolFromAssignment(course, uid);
      if (!mounted) return;
      _open(CoursePlayerScreen(courseId: a.courseId));
    } catch (e) {
      debugPrint('Open assigned course failed: $e');
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not open the course. Please try again.')));
    }
  }

  Widget _banner(String first) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MY LEARNING SPACE',
            style: TextStyle(
              color: AppTheme.softYellow,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome, $first',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn. Apply. Grow. Pick up where you left off or explore something new.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _open(const CoursesScreen()),
                icon: const Icon(Icons.school_outlined),
                label: const Text('Browse Courses'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.softYellow,
                  foregroundColor: AppTheme.deepBlue,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _open(const StoreScreen()),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Visit Store'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _continueCard(Map<String, dynamic>? active) {
    if (active == null) {
      return DashCard(
        title: 'Continue Learning',
        child: EmptyState(
          icon: Icons.play_circle_outline_rounded,
          message:
              "You haven't started a course yet. Enrol in one to see your progress here.",
          actionLabel: 'Browse Courses',
          onAction: () => _open(const CoursesScreen()),
        ),
      );
    }
    final progress = (((active['progress'] ?? 0) as num).toDouble())
        .clamp(0, 100)
        .toDouble();
    return DashCard(
      title: 'Continue Learning',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (active['courseTitle'] ?? 'Your course') as String,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFEDEAF4),
              color: AppTheme.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text('${progress.round()}% complete',
              style: const TextStyle(color: AppTheme.greyText)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => _open(
              CoursePlayerScreen(courseId: '${active['courseId'] ?? ''}'),
            ),
            child: const Text('Continue Course'),
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard(List<Map<String, dynamic>> completed, double hours) {
    return DashCard(
      title: 'Achievements',
      child: completed.isEmpty
          ? const Text(
              'Finish a course and pass its assessment to earn your first certificate.',
              style: TextStyle(color: AppTheme.greyText, height: 1.5),
            )
          : Column(
              children: [
                _line(Icons.workspace_premium_outlined, 'Certificates',
                    '${completed.length}'),
                _line(Icons.schedule_rounded, 'Learning hours',
                    hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)),
                const Divider(),
                for (final c in completed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.verified_outlined,
                        color: AppTheme.purple),
                    title: Text('${c['courseTitle'] ?? 'Course'}'),
                    trailing: TextButton(
                      onPressed: ((c['certificateId'] ?? '') as String).isEmpty
                          ? null
                          : () => _open(CertificateScreen(
                              certificateId: c['certificateId'] as String)),
                      child: const Text('View'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _line(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.deepBlue, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _ordersCard() {
    return DashCard(
      title: 'My Orders',
      trailing: Wrap(
        children: [
          TextButton(
            onPressed: () => _open(const DigitalLibraryScreen()),
            child: const Text('Digital Products'),
          ),
          TextButton(
            onPressed: () => _open(const MyOrdersScreen()),
            child: const Text('All orders'),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _orders,
        builder: (context, snap) {
          final orders = _docs(snap);
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No orders yet. Digital and physical products you buy '
                  'will show here with their status.',
              actionLabel: 'Visit Store',
              onAction: () => _open(const StoreScreen()),
            );
          }
          orders.sort((a, b) => ((b['createdAt'] as Timestamp?)
                      ?.millisecondsSinceEpoch ??
                  0)
              .compareTo(
                  (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
          return Column(
            children: [
              for (final o in orders.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shopping_bag_outlined,
                      color: AppTheme.purple),
                  title: Text('#${o['orderNumber'] ?? '—'}'),
                  subtitle: Text(
                      'RM ${((o['total'] ?? 0) as num).toStringAsFixed(2)}'),
                  trailing: Chip(
                    label: Text((o['status'] ?? 'Pending') as String),
                    backgroundColor: AppTheme.softYellow.withValues(alpha: 0.4),
                    side: BorderSide.none,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileCard() {
    final user = context.watch<AuthProvider>().user;
    final extra = user?.extra ?? const <String, dynamic>{};
    return DashCard(
      title: 'Profile',
      child: Column(
        children: [
          _line(Icons.person_outline, 'Name', user?.name ?? ''),
          _line(Icons.email_outlined, 'Email', user?.email ?? ''),
          _line(Icons.phone_outlined, 'Phone', '${extra['phone'] ?? '—'}'),
          _line(Icons.public, 'Country', '${extra['country'] ?? '—'}'),
        ],
      ),
    );
  }
}
