import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../employer/employer_models.dart';
import '../employer/employer_service.dart';
import '../learning/course_models.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';
import 'employees_screen.dart';
import 'purchase_courses_screen.dart';

/// Corporate Course Assignment (brief Page 16):
/// Course -> Employees -> Deadline -> Assign. Employees are notified.
class AssignCourseScreen extends StatefulWidget {
  const AssignCourseScreen({super.key});

  @override
  State<AssignCourseScreen> createState() => _AssignCourseScreenState();
}

class _AssignCourseScreenState extends State<AssignCourseScreen> {
  late final String _orgId;
  late final String _orgName;
  late final Stream<List<LicenseRecord>> _licenses;
  late final Stream<List<EmployeeRecord>> _employees;
  late final Stream<List<AssignmentRecord>> _assignments;

  String? _courseId;
  DateTime? _deadline;
  final Set<String> _selected = {}; // employee ids
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _orgId = user?.uid ?? '';
    _orgName = '${user?.extra['organizationName'] ?? user?.name ?? 'Your employer'}';
    _licenses = EmployerService.instance.licenses(_orgId);
    _employees = EmployerService.instance.employees(_orgId);
    _assignments = EmployerService.instance.assignments(_orgId);
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _assign({
    required LicenseRecord license,
    required List<EmployeeRecord> chosen,
    required int seatsLeft,
  }) async {
    if (chosen.isEmpty) {
      _snack('Select at least one employee.');
      return;
    }
    if (_deadline == null) {
      _snack('Choose a deadline.');
      return;
    }
    if (chosen.length > seatsLeft) {
      _snack('You only have $seatsLeft seats left. Buy more seats first.');
      return;
    }

    setState(() => _busy = true);
    try {
      await EmployerService.instance.assignCourse(
        orgId: _orgId,
        orgName: _orgName,
        courseId: license.courseId,
        courseTitle: license.courseTitle,
        employees: chosen,
        deadline: _deadline!,
      );
      if (!mounted) return;
      setState(() => _selected.clear());
      _snack(
          'Assigned to ${chosen.length} ${chosen.length == 1 ? 'employee' : 'employees'}. They have been notified.');
    } catch (e) {
      debugPrint('Assign failed: $e');
      if (mounted) _snack('Could not assign the course. Check the Firestore rules.');
    }
    if (mounted) setState(() => _busy = false);
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: StreamBuilder<List<LicenseRecord>>(
              stream: _licenses,
              builder: (context, licSnap) {
                return StreamBuilder<List<EmployeeRecord>>(
                  stream: _employees,
                  builder: (context, empSnap) {
                    return StreamBuilder<List<AssignmentRecord>>(
                      stream: _assignments,
                      builder: (context, asSnap) {
                        if (licSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final licenses = licSnap.data ?? const <LicenseRecord>[];
                        final employees = empSnap.data ?? const <EmployeeRecord>[];
                        final assignments = asSnap.data ?? const <AssignmentRecord>[];
                        return _content(licenses, employees, assignments);
                      },
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

  Widget _content(
    List<LicenseRecord> licenses,
    List<EmployeeRecord> employees,
    List<AssignmentRecord> assignments,
  ) {
    final title = const Text('Assign a Course',
        style: TextStyle(
            color: AppTheme.deepBlue, fontSize: 30, fontWeight: FontWeight.w800));

    if (licenses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 20),
          DashCard(
            title: 'Buy a course first',
            child: EmptyState(
              icon: Icons.shopping_cart_outlined,
              message:
                  'You need to purchase seats on a course before you can assign it to employees.',
              actionLabel: 'Purchase Courses',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PurchaseCoursesScreen()),
              ),
            ),
          ),
        ],
      );
    }

    final license = licenses.firstWhere(
      (l) => l.courseId == _courseId,
      orElse: () => licenses.first,
    );
    final assignedHere = assignments
        .where((a) => a.courseId == license.courseId)
        .map((a) => a.employeeId)
        .toSet();
    final seatsLeft = license.seats - assignedHere.length;
    final eligible = employees.where((e) => !assignedHere.contains(e.id)).toList();
    final chosen = employees.where((e) => _selected.contains(e.id)).toList();

    // group by department
    final byDept = <String, List<EmployeeRecord>>{};
    for (final e in employees) {
      byDept.putIfAbsent(e.department.isEmpty ? 'No department' : e.department, () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 20),
        DashCard(
          title: '1. Choose a course',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(license.courseId),
                initialValue: license.courseId,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (final l in licenses)
                    DropdownMenuItem(value: l.courseId, child: Text(l.courseTitle)),
                ],
                onChanged: (v) => setState(() {
                  _courseId = v;
                  _selected.clear();
                }),
              ),
              const SizedBox(height: 10),
              Text(
                '${license.seats} seats bought · ${assignedHere.length} assigned · $seatsLeft left',
                style: TextStyle(
                  color: seatsLeft > 0 ? AppTheme.greyText : const Color(0xFFD92D20),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (seatsLeft <= 0)
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PurchaseCoursesScreen()),
                  ),
                  child: const Text('Buy more seats'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashCard(
          title: '2. Choose employees',
          child: employees.isEmpty
              ? EmptyState(
                  icon: Icons.group_add_outlined,
                  message: 'Add employees first.',
                  actionLabel: 'Add Employee',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeesScreen()),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in byDept.entries) ...[
                      Builder(builder: (context) {
                        final free = entry.value
                            .where((e) => !assignedHere.contains(e.id))
                            .toList();
                        final allSelected = free.isNotEmpty &&
                            free.every((e) => _selected.contains(e.id));
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          activeColor: AppTheme.deepBlue,
                          value: allSelected,
                          onChanged: free.isEmpty
                              ? null
                              : (v) => setState(() {
                                    for (final e in free) {
                                      v == true
                                          ? _selected.add(e.id)
                                          : _selected.remove(e.id);
                                    }
                                  }),
                          title: Text('${entry.key} (${entry.value.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.deepBlue)),
                        );
                      }),
                      for (final e in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            activeColor: AppTheme.deepBlue,
                            value: _selected.contains(e.id) ||
                                assignedHere.contains(e.id),
                            onChanged: assignedHere.contains(e.id)
                                ? null
                                : (v) => setState(() {
                                      v == true
                                          ? _selected.add(e.id)
                                          : _selected.remove(e.id);
                                    }),
                            title: Text(e.name),
                            subtitle: Text(
                              assignedHere.contains(e.id)
                                  ? 'Already assigned'
                                  : e.email,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 6),
                    Text('${chosen.length} selected · ${eligible.length} available',
                        style: const TextStyle(color: AppTheme.greyText)),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        DashCard(
          title: '3. Set a deadline',
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDeadline,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(_deadline == null
                    ? 'Choose date'
                    : formatDate(_deadline!)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy
                ? null
                : () => _assign(
                      license: license,
                      chosen: chosen,
                      seatsLeft: seatsLeft,
                    ),
            icon: const Icon(Icons.assignment_ind_outlined),
            label: Text(_busy ? 'Assigning…' : 'Assign Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
