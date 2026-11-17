import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../employer/employer_models.dart';
import '../employer/employer_service.dart';
import '../employer/report_export.dart';
import '../learning/course_models.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';

/// Corporate Learning Reports (brief Page 17).
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final String _orgName;
  late final Stream<List<AssignmentRecord>> _assignments;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _orgName = '${user?.extra['organizationName'] ?? user?.name ?? 'Organisation'}';
    _assignments = EmployerService.instance.assignments(user?.uid ?? '');
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _exportPdf(List<AssignmentRecord> rows) async {
    try {
      final bytes = await buildReportPdf(_orgName, rows);
      await Printing.sharePdf(bytes: bytes, filename: 'Learning-Report.pdf');
    } catch (e) {
      debugPrint('PDF export failed: $e');
      _snack('Could not create the PDF.');
    }
  }

  Future<void> _exportCsv(List<AssignmentRecord> rows) async {
    try {
      await saveCsv(buildReportCsv(rows), 'Learning-Report');
    } catch (e) {
      debugPrint('CSV export failed: $e');
      _snack('Could not create the CSV file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: StreamBuilder<List<AssignmentRecord>>(
        stream: _assignments,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = [...(snap.data ?? const <AssignmentRecord>[])]
            ..sort((a, b) => a.employeeName.compareTo(b.employeeName));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 10,
                      children: [
                        const Text('Learning Reports',
                            style: TextStyle(
                                color: AppTheme.deepBlue,
                                fontSize: 30,
                                fontWeight: FontWeight.w800)),
                        Wrap(
                          spacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: rows.isEmpty ? null : () => _exportPdf(rows),
                              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                              label: const Text('Export PDF'),
                            ),
                            ElevatedButton.icon(
                              onPressed: rows.isEmpty ? null : () => _exportCsv(rows),
                              icon: const Icon(Icons.table_chart_outlined, size: 18),
                              label: const Text('Export CSV'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (snap.hasError)
                      const Text(
                          'Reports could not be loaded. Check that the Firestore rules are published.')
                    else if (rows.isEmpty)
                      const DashCard(
                        title: 'No data yet',
                        child: Text(
                          'Assign a course to your employees. Their progress, scores and certificates will appear here.',
                          style: TextStyle(color: AppTheme.greyText, height: 1.5),
                        ),
                      )
                    else ...[
                      _overall(rows),
                      const SizedBox(height: 16),
                      _departments(rows),
                      const SizedBox(height: 16),
                      _individuals(rows),
                      const SizedBox(height: 16),
                      _certificates(rows),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _overall(List<AssignmentRecord> rows) {
    final done = rows.where((a) => a.completed).length;
    final rate = ((done / rows.length) * 100).round();
    final scored = rows.where((a) => a.score > 0).toList();
    final avg = scored.isEmpty
        ? '—'
        : '${(scored.fold<int>(0, (s, a) => s + a.score) / scored.length).round()}%';
    final hours = rows.fold<double>(0, (s, a) => s + a.learningHours);

    return StatGrid(children: [
      StatCard(
        icon: Icons.assignment_outlined,
        value: '${rows.length}',
        label: 'Enrolments (assigned)',
      ),
      StatCard(
        icon: Icons.pie_chart_outline_rounded,
        value: '$rate%',
        label: 'Completion rate',
        color: const Color(0xFF4C7A6B),
      ),
      StatCard(
        icon: Icons.grade_outlined,
        value: avg,
        label: 'Average score',
        color: const Color(0xFFD99A00),
      ),
      StatCard(
        icon: Icons.schedule_rounded,
        value: hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1),
        label: 'Learning hours',
        color: AppTheme.deepBlue,
      ),
    ]);
  }

  Widget _departments(List<AssignmentRecord> rows) {
    final groups = <String, List<AssignmentRecord>>{};
    for (final a in rows) {
      groups.putIfAbsent(a.department.isEmpty ? 'No department' : a.department, () => []).add(a);
    }

    return DashCard(
      title: 'Department Performance',
      child: Column(
        children: [
          for (final e in groups.entries)
            Builder(builder: (context) {
              final avgProgress =
                  e.value.fold<int>(0, (s, a) => s + a.progress) / e.value.length;
              final done = e.value.where((a) => a.completed).length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(e.key,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text('$done / ${e.value.length} completed · avg ${avgProgress.round()}%',
                            style: const TextStyle(
                                color: AppTheme.greyText, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: avgProgress / 100,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFEDEAF4),
                        color: AppTheme.purple,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _individuals(List<AssignmentRecord> rows) {
    return DashCard(
      title: 'Individual Performance',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Employee')),
            DataColumn(label: Text('Department')),
            DataColumn(label: Text('Course')),
            DataColumn(label: Text('Deadline')),
            DataColumn(label: Text('Progress')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('Status')),
          ],
          rows: [
            for (final a in rows)
              DataRow(cells: [
                DataCell(Text(a.employeeName)),
                DataCell(Text(a.department)),
                DataCell(Text(a.courseTitle)),
                DataCell(Text(
                  a.deadline == null ? '—' : formatDate(a.deadline!),
                  style: TextStyle(
                      color: a.overdue ? const Color(0xFFD92D20) : null,
                      fontWeight: a.overdue ? FontWeight.w700 : null),
                )),
                DataCell(Text('${a.progress}%')),
                DataCell(Text(a.score == 0 ? '—' : '${a.score}%')),
                DataCell(Text(a.overdue ? '${a.statusLabel} (overdue)' : a.statusLabel)),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _certificates(List<AssignmentRecord> rows) {
    final done = rows.where((a) => a.completed).toList();
    return DashCard(
      title: 'Certificates',
      child: done.isEmpty
          ? const Text('No one has completed a course yet.',
              style: TextStyle(color: AppTheme.greyText))
          : Column(
              children: [
                for (final a in done)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.workspace_premium_outlined,
                        color: AppTheme.purple),
                    title: Text('${a.employeeName} · ${a.courseTitle}'),
                    subtitle: Text(
                        'Score ${a.score == 0 ? '—' : '${a.score}%'} · ${a.department}'),
                  ),
              ],
            ),
    );
  }
}
