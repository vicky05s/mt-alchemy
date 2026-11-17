import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../learning/certificate_pdf.dart';
import '../learning/certificate_utils.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../theme/app_theme.dart';

/// Shows a learner's certificate: name, course, date, ID, instructor and a
/// QR code that opens the public verification page. Can be downloaded as PDF.
class CertificateScreen extends StatelessWidget {
  final String certificateId;
  const CertificateScreen({super.key, required this.certificateId});

  Future<void> _download(BuildContext context, CertificateRecord cert) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await buildCertificatePdf(cert, verifyUrlFor(cert.id));
      await Printing.sharePdf(bytes: bytes, filename: 'Certificate-${cert.id}.pdf');
    } catch (e) {
      debugPrint('Certificate PDF failed: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create the PDF. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: AppBar(title: const Text('Course Certificate')),
      body: StreamBuilder<CertificateRecord?>(
        stream: CourseService.instance.certificate(certificateId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cert = snap.data;
          if (snap.hasError || cert == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This certificate could not be found.'),
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _certificate(context, cert),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 240,
                          child: OutlinedButton(
                            onPressed: () => Navigator.popUntil(
                                context, (route) => route.isFirst),
                            child: const Text('Back to Dashboard'),
                          ),
                        ),
                        SizedBox(
                          width: 240,
                          child: ElevatedButton.icon(
                            onPressed: () => _download(context, cert),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Download Certificate'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _certificate(BuildContext context, CertificateRecord cert) {
    Widget fact(String value, String label) => Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(color: AppTheme.greyText, fontSize: 12)),
          ],
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.softYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.deepBlue, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium,
                color: AppTheme.purple, size: 56),
            const SizedBox(height: 14),
            const Text(
              'MT ALCHEMY',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'CERTIFICATE OF COMPLETION',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 22),
            Text('This certificate is proudly presented to',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              cert.learnerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.purple,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text('for successfully completing the course',
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              cert.courseTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 36,
              runSpacing: 20,
              children: [
                fact(formatDate(cert.issuedAt), 'Date of completion'),
                fact(cert.instructor, 'Trainer / Instructor'),
                fact(cert.id, 'Certificate ID'),
                Column(
                  children: [
                    QrImageView(
                      data: verifyUrlFor(cert.id),
                      size: 96,
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    const Text('Scan to verify',
                        style: TextStyle(
                            color: AppTheme.greyText, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
