import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'site_content.dart';

/// One-page programme brochure (plain ASCII only).
Future<Uint8List> buildBrochurePdf(Programme p) async {
  const navy = PdfColor.fromInt(0xFF172A4D);
  const purple = PdfColor.fromInt(0xFF7657A6);
  const grey = PdfColor.fromInt(0xFF667085);

  pw.Widget bullets(List<String> items) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final i in items)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('-  $i', style: const pw.TextStyle(fontSize: 12)),
            ),
        ],
      );

  pw.Widget label(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
        child: pw.Text(t.toUpperCase(),
            style: pw.TextStyle(
                color: purple,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.2)),
      );

  final doc = pw.Document(title: p.title, author: 'MT Alchemy');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(44),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('MT ALCHEMY',
              style: pw.TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 3)),
          pw.SizedBox(height: 26),
          pw.Text(p.type.toUpperCase(),
              style: const pw.TextStyle(color: grey, fontSize: 10)),
          pw.SizedBox(height: 6),
          pw.Text(p.title,
              style: pw.TextStyle(
                  color: navy, fontSize: 26, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(p.description,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 3)),
          label('Learning objectives'),
          bullets(p.objectives),
          label('Who it is for'),
          pw.Text(p.audience, style: const pw.TextStyle(fontSize: 12)),
          label('Programme details'),
          bullets([
            'Duration: ${p.duration}',
            'Participants: ${p.participants}',
            'Delivery: ${p.delivery}',
            'Trainer: ${p.trainer}',
            'Price: ${p.price == null ? "Request a quote" : "RM ${p.price!.toStringAsFixed(0)} per person"}',
          ]),
          label('Modules'),
          bullets(p.modules),
          pw.Spacer(),
          pw.Divider(color: grey),
          pw.Text('To enquire, use the Contact page on the MT Alchemy website.',
              style: const pw.TextStyle(color: grey, fontSize: 10)),
        ],
      ),
    ),
  );
  return doc.save();
}
