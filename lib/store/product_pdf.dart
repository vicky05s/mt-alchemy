import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds the file a buyer downloads for a digital product.
/// DEMO: this generates a licensed sample PDF. When MT Alchemy has real files,
/// upload them to Firebase Storage and download those instead.
Future<Uint8List> buildProductPdf({
  required String productName,
  required String licensedTo,
  required String orderNumber,
}) async {
  const navy = PdfColor.fromInt(0xFF172A4D);
  const grey = PdfColor.fromInt(0xFF667085);

  final doc = pw.Document(title: productName, author: 'MT Alchemy');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('MT ALCHEMY',
              style: pw.TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 3)),
          pw.SizedBox(height: 40),
          pw.Text(productName,
              style: pw.TextStyle(
                  color: navy, fontSize: 30, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Sample digital resource (demo file)',
              style: const pw.TextStyle(color: grey, fontSize: 14)),
          pw.SizedBox(height: 40),
          pw.Text(
              'This is a placeholder for the real resource. In the live platform, '
              'MT Alchemy uploads the actual workbook, guide or recording and '
              'buyers download it from their Digital Library.',
              style: const pw.TextStyle(fontSize: 13, lineSpacing: 4)),
          pw.Spacer(),
          pw.Divider(color: grey),
          pw.Text('Licensed to: $licensedTo',
              style: const pw.TextStyle(color: grey, fontSize: 11)),
          pw.Text('Order: $orderNumber',
              style: const pw.TextStyle(color: grey, fontSize: 11)),
          pw.Text('For personal use only. Do not share or redistribute.',
              style: const pw.TextStyle(color: grey, fontSize: 11)),
        ],
      ),
    ),
  );
  return doc.save();
}
