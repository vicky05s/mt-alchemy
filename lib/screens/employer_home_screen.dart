import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../auth/role_gate.dart';
import '../enquiries/enquiry_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';
import 'assign_course_screen.dart';
import 'employees_screen.dart';
import 'purchase_courses_screen.dart';
import 'reports_screen.dart';

typedef _Snap = AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>;

/// Home / dashboard for Employer accounts (brief Page 14).
/// Numbers come from Firestore: `employees` and `assignments`
/// where organizationId == the employer's uid.
class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _employees;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _assignments;
  late final Stream<List<EnquiryRecord>> _enquiries;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    final db = FirebaseFirestore.instance;
    _employees = db
        .collection('employees')
        .where('organizationId', isEqualTo: uid)
        .snapshots();
    _assignments = db
        .collection('assignments')
        .where('organizationId', isEqualTo: uid)
        .snapshots();
    _enquiries = EnquiryService.instance.mine(uid);
  }

  List<Map<String, dynamic>> _docs(_Snap snap) {
    if (snap.hasError) debugPrint('Dashboard query error: ${snap.error}');
    return snap.data?.docs.map((d) => d.data()).toList() ?? [];
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  static const _who = [UserRole.employer, UserRole.admin];

  void _openEmployees() =>
      _open(const RoleGate(allowed: _who, child: EmployeesScreen()));
  void _openAssign() =>
      _open(const RoleGate(allowed: _who, child: AssignCourseScreen()));
  void _openReports() =>
      _open(const RoleGate(allowed: _who, child: ReportsScreen()));
  void _openPurchase() =>
      _open(const RoleGate(allowed: _who, child: PurchaseCoursesScreen()));

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final org = '${user?.extra['organizationName'] ?? 'Your organisation'}';
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
              stream: _employees,
              builder: (context, empSnap) {
                final employees = _docs(empSnap);
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _assignments,
                  builder: (context, asSnap) {
                    final assignments = _docs(asSnap);
                    final completed = assignments
                        .where((a) => a['status'] == 'completed')
                        .length;
                    final pending = assignments
                        .where((a) => a['status'] == 'pending')
                        .length;
                    final active = assignments
                        .where((a) => a['status'] == 'in_progress')
                        .map((a) => a['employeeId'])
                        .toSet()
                        .length;
                    final rate = assignments.isEmpty
                        ? 0
                        : (completed / assignments.length * 100).round();
                    final hours = assignments.fold<double>(
                      0,
                      (sum, a) => sum + ((a['learningHours'] ?? 0) as num),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _banner(org, first),
                        const SizedBox(height: 20),
                        StatGrid(children: [
                          StatCard(
                            icon: Icons.groups_rounded,
                            value: '${employees.length}',
                            label: 'Total employees',
                          ),
                          StatCard(
                            icon: Icons.bolt_rounded,
                            value: '$active',
                            label: 'Active learners',
                            color: AppTheme.deepBlue,
                          ),
                          StatCard(
                            icon: Icons.assignment_outlined,
                            value: '${assignments.length}',
                            label: 'Courses assigned',
                            color: const Color(0xFFD99A00),
                          ),
                          StatCard(
                            icon: Icons.pie_chart_outline_rounded,
                            value: '$rate%',
                            label: 'Completion rate',
                            color: const Color(0xFF4C7A6B),
                          ),
                          StatCard(
                            icon: Icons.workspace_premium_outlined,
                            value: '$completed',
                            label: 'Certificates earned',
                          ),
                          StatCard(
                            icon: Icons.schedule_rounded,
                            value: hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1),
                            label: 'Learning hours',
                            color: AppTheme.deepBlue,
                          ),
                          StatCard(
                            icon: Icons.hourglass_bottom_rounded,
                            value: '$pending',
                            label: 'Pending assignments',
                            color: const Color(0xFFD99A00),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _quickActions(),
                        const SizedBox(height: 16),
                        _enquiriesCard(),
                        _employeeTable(employees),
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _banner(String org, String first) {
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
            'EMPLOYER DASHBOARD',
            style: TextStyle(
              color: AppTheme.softYellow,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            org,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome, $first. Develop your people and strengthen your organisation.',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _enquiriesCard() {
    return StreamBuilder<List<EnquiryRecord>>(
      stream: _enquiries,
      builder: (context, snap) {
        final items = (snap.data ?? const <EnquiryRecord>[]).take(5).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DashCard(
            title: 'Your Enquiries',
            child: Column(
              children: [
                for (final e in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.mail_outline,
                        color: AppTheme.purple),
                    title: Text(e.service.isEmpty ? e.enquiryType : e.service),
                    subtitle: Text(e.message,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: StatusChip(enquiryStatusLabel(e.status)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActions() {
    Widget action(IconData icon, String label, VoidCallback onTap) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.deepBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      );
    }

    return DashCard(
      title: 'Quick Actions',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          action(Icons.person_add_alt_1_outlined, 'Add Employee', _openEmployees),
          action(Icons.assignment_ind_outlined, 'Assign Course', _openAssign),
          action(Icons.bar_chart_rounded, 'View Reports', _openReports),
          action(Icons.shopping_cart_outlined, 'Purchase Courses',
              _openPurchase),
        ],
      ),
    );
  }

  Widget _employeeTable(List<Map<String, dynamic>> employees) {
    return DashCard(
      title: 'Employee Learning Status',
      trailing: TextButton(
        onPressed: _openEmployees,
        child: const Text('Manage employees'),
      ),
      child: employees.isEmpty
          ? EmptyState(
              icon: Icons.group_add_outlined,
              message:
                  'No employees yet. Add your first employee to start assigning courses.',
              actionLabel: 'Add Employee',
              onAction: _openEmployees,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Employee')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Status')),
                ],
                rows: [
                  for (final e in employees.take(8))
                    DataRow(cells: [
                      DataCell(Text('${e['name'] ?? '—'}')),
                      DataCell(Text('${e['department'] ?? '—'}')),
                      DataCell(Text('${e['status'] ?? 'Invited'}')),
                    ]),
                ],
              ),
            ),
    );
  }
}
