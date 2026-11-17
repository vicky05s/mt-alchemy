import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../learning/course_models.dart';
import 'employer_models.dart';

String _csvCell(String v) {
  final needsQuotes = v.contains(',') || v.contains('"') || v.contains('\n');
  final escaped = v.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}

/// One row per employee assignment.
String buildReportCsv(List<AssignmentRecord> rows) {
  final lines = <String>[
    'Employee,Email,Department,Course,Deadline,Status,Progress %,Score %,Learning hours',
  ];
  for (final a in rows) {
    lines.add([
      a.employeeName,
      a.employeeEmail,
      a.department,
      a.courseTitle,
      a.deadline == null ? '' : formatDate(a.deadline!),
      a.statusLabel,
      '${a.progress}',
      a.score == 0 ? '' : '${a.score}',
      a.learningHours.toStringAsFixed(1),
    ].map(_csvCell).join(','));
  }
  return lines.join('\n');
}

/// Saves/downloads the CSV. (If `flutter analyze` complains about
/// `fileExtension`, your file_saver version is older: rename it to `ext`.)
Future<void> saveCsv(String csv, String baseName) async {
  await FileSaver.instance.saveFile(
    name: baseName,
    bytes: Uint8List.fromList(utf8.encode(csv)),
    fileExtension: 'csv',
    mimeType: MimeType.csv,
  );
}

/// A simple multi-page PDF report (plain ASCII only).
Future<Uint8List> buildReportPdf(
  String orgName,
  List<AssignmentRecord> rows,
) async {
  const navy = PdfColor.fromInt(0xFF172A4D);
  const grey = PdfColor.fromInt(0xFF667085);

  final total = rows.length;
  final done = rows.where((a) => a.completed).length;
  final rate = total == 0 ? 0 : ((done / total) * 100).round();
  final scored = rows.where((a) => a.score > 0).toList();
  final avg = scored.isEmpty
      ? 0
      : (scored.fold<int>(0, (s, a) => s + a.score) / scored.length).round();
  final hours = rows.fold<double>(0, (s, a) => s + a.learningHours);

  final doc = pw.Document(title: 'Learning report - $orgName', author: 'MT Alchemy');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text('MT ALCHEMY - Learning Report',
            style: pw.TextStyle(
                color: navy, fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('$orgName  |  Generated ${formatDate(DateTime.now())}',
            style: const pw.TextStyle(color: grey, fontSize: 11)),
        pw.SizedBox(height: 16),
        pw.Text(
            'Assignments: $total   |   Completed: $done ($rate%)   |   Average score: ${scored.isEmpty ? "-" : "$avg%"}   |   Learning hours: ${hours.toStringAsFixed(1)}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: navy),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headers: [
            'Employee', 'Department', 'Course', 'Deadline', 'Status',
            'Progress', 'Score', 'Hours',
          ],
          data: [
            for (final a in rows)
              [
                a.employeeName,
                a.department,
                a.courseTitle,
                a.deadline == null ? '-' : formatDate(a.deadline!),
                a.statusLabel,
                '${a.progress}%',
                a.score == 0 ? '-' : '${a.score}%',
                a.learningHours.toStringAsFixed(1),
              ],
          ],
        ),
      ],
    ),
  );
  return doc.save();
}
