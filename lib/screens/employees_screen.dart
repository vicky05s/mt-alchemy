import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../auth/auth_widgets.dart' show Validators;
import '../employer/employer_models.dart';
import '../employer/employer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';

/// Employee Management (brief Page 15): add, edit, remove employees and see
/// each person's learning status.
class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  static const _departments = [
    'Human Resources', 'Finance', 'Sales', 'Management', 'Operations',
    'IT', 'Marketing',
  ];

  late final String _orgId;
  late final Stream<List<EmployeeRecord>> _employees;
  late final Stream<List<AssignmentRecord>> _assignments;

  @override
  void initState() {
    super.initState();
    _orgId = context.read<AuthProvider>().user?.uid ?? '';
    _employees = EmployerService.instance.employees(_orgId);
    _assignments = EmployerService.instance.assignments(_orgId);
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _showForm({
    EmployeeRecord? existing,
    required List<EmployeeRecord> all,
  }) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?.name ?? '');
    final email = TextEditingController(text: existing?.email ?? '');
    final dept = TextEditingController(text: existing?.department ?? '');
    final role = TextEditingController(text: existing?.jobRole ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add employee' : 'Edit employee'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: email,
                      enabled: existing == null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Work email'),
                      validator: (v) {
                        final r = Validators.email(v);
                        if (r != null) return r;
                        final dup = all.any((e) =>
                            e.email == v!.trim().toLowerCase() &&
                            e.id != existing?.id);
                        return dup ? 'This email is already added' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dept,
                      decoration: const InputDecoration(labelText: 'Department'),
                      validator: (v) => Validators.required(v, 'Department'),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final d in _departments)
                          ActionChip(
                            label: Text(d, style: const TextStyle(fontSize: 12)),
                            onPressed: () => setLocal(() => dept.text = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: role,
                      decoration: const InputDecoration(labelText: 'Job role'),
                    ),
                    if (existing == null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.softYellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'To start learning, the employee registers as an '
                          'Individual using this same email. Courses you '
                          'assign then appear on their dashboard '
                          'automatically.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: Text(existing == null ? 'Add employee' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      try {
        if (existing == null) {
          await EmployerService.instance.addEmployee(
            orgId: _orgId,
            name: name.text,
            email: email.text,
            department: dept.text,
            jobRole: role.text,
          );
          _snack('${name.text.trim()} was added.');
        } else {
          await EmployerService.instance.updateEmployee(
            existing.id,
            name: name.text,
            department: dept.text,
            jobRole: role.text,
          );
          _snack('Employee updated.');
        }
      } catch (e) {
        debugPrint('Employee save failed: $e');
        _snack('Could not save. Check that the Firestore rules are published.');
      }
    }
    name.dispose();
    email.dispose();
    dept.dispose();
    role.dispose();
  }

  Future<void> _remove(EmployeeRecord e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove employee?'),
        content: Text(
            '${e.name} and their course assignments will be removed from your organisation.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await EmployerService.instance.removeEmployee(_orgId, e.id);
      _snack('${e.name} was removed.');
    } catch (err) {
      debugPrint('Remove failed: $err');
      _snack('Could not remove the employee.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: StreamBuilder<List<EmployeeRecord>>(
        stream: _employees,
        builder: (context, empSnap) {
          return StreamBuilder<List<AssignmentRecord>>(
            stream: _assignments,
            builder: (context, asSnap) {
              if (empSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final employees = empSnap.data ?? const <EmployeeRecord>[];
              final assignments = asSnap.data ?? const <AssignmentRecord>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Employee Management',
                                  style: TextStyle(
                                      color: AppTheme.deepBlue,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800)),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showForm(all: employees),
                              icon: const Icon(Icons.person_add_alt_1_outlined,
                                  size: 18),
                              label: const Text('Add Employee'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                            'Add your people, then assign them courses.',
                            style: TextStyle(color: AppTheme.greyText)),
                        const SizedBox(height: 20),
                        if (empSnap.hasError)
                          const Text(
                              'Employees could not be loaded. Check that the Firestore rules are published.')
                        else
                          DashCard(
                            title: '${employees.length} '
                                '${employees.length == 1 ? 'employee' : 'employees'}',
                            child: employees.isEmpty
                                ? EmptyState(
                                    icon: Icons.group_add_outlined,
                                    message:
                                        'No employees yet. Add your first employee to get started.',
                                    actionLabel: 'Add Employee',
                                    onAction: () => _showForm(all: employees),
                                  )
                                : _table(employees, assignments),
                          ),
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

  Widget _table(List<EmployeeRecord> employees, List<AssignmentRecord> all) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Employee')),
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Course')),
          DataColumn(label: Text('Progress')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: [
          for (final e in employees) _row(e, all.where((a) => a.employeeId == e.id).toList(), employees),
        ],
      ),
    );
  }

  DataRow _row(EmployeeRecord e, List<AssignmentRecord> mine, List<EmployeeRecord> all) {
    String course = 'No course yet';
    String progress = '—';
    String status = e.status == 'Active' ? 'Active' : 'Invited';

    if (mine.isNotEmpty) {
      course = mine.first.courseTitle +
          (mine.length > 1 ? '  (+${mine.length - 1})' : '');
      final avg =
          (mine.fold<int>(0, (s, a) => s + a.progress) / mine.length).round();
      progress = '$avg%';
      if (mine.every((a) => a.completed)) {
        status = 'Completed';
      } else if (mine.any((a) => a.progress > 0)) {
        status = 'In Progress';
      } else {
        status = 'Assigned';
      }
    }

    return DataRow(cells: [
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(e.email,
              style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
        ],
      )),
      DataCell(Text(e.department)),
      DataCell(Text(e.jobRole.isEmpty ? '—' : e.jobRole)),
      DataCell(Text(course)),
      DataCell(Text(progress)),
      DataCell(Text(status)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => _showForm(existing: e, all: all),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => _remove(e),
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      )),
    ]);
  }
}
