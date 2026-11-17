import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'course_models.dart';

/// Builds a landscape A4 certificate PDF (plain ASCII text only, so the
/// built-in PDF font renders everything correctly).
Future<Uint8List> buildCertificatePdf(
  CertificateRecord cert,
  String verifyUrl,
) async {
  const navy = PdfColor.fromInt(0xFF172A4D);
  const purple = PdfColor.fromInt(0xFF7657A6);
  const gold = PdfColor.fromInt(0xFFF4D35E);
  const grey = PdfColor.fromInt(0xFF667085);

  final doc = pw.Document(title: 'Certificate ${cert.id}', author: 'MT Alchemy');

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: gold, width: 6),
        ),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: navy, width: 2),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('MT ALCHEMY',
                  style: pw.TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 4)),
              pw.SizedBox(height: 18),
              pw.Text('CERTIFICATE OF COMPLETION',
                  style: pw.TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.5)),
              pw.SizedBox(height: 18),
              pw.Text('This certificate is proudly presented to',
                  style: const pw.TextStyle(color: grey, fontSize: 13)),
              pw.SizedBox(height: 10),
              pw.Text(cert.learnerName,
                  style: pw.TextStyle(
                      color: purple,
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('for successfully completing the course',
                  style: const pw.TextStyle(color: grey, fontSize: 13)),
              pw.SizedBox(height: 8),
              pw.Text(cert.courseTitle,
                  style: pw.TextStyle(
                      color: navy,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(children: [
                    pw.Text(formatDate(cert.issuedAt),
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text('Date of completion',
                        style: const pw.TextStyle(color: grey, fontSize: 10)),
                  ]),
                  pw.Column(children: [
                    pw.Text(cert.instructor,
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text('Trainer / Instructor',
                        style: const pw.TextStyle(color: grey, fontSize: 10)),
                  ]),
                  pw.Column(children: [
                    pw.Text(cert.id,
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text('Certificate ID',
                        style: const pw.TextStyle(color: grey, fontSize: 10)),
                  ]),
                  pw.Column(children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: verifyUrl,
                      width: 70,
                      height: 70,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text('Scan to verify',
                        style: const pw.TextStyle(color: grey, fontSize: 10)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return doc.save();
}
