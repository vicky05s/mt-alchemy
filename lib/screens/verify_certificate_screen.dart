import 'package:flutter/material.dart';

import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Public page opened by scanning a certificate's QR code
/// (…/?verify=<certificate id>). No login needed.
class VerifyCertificateScreen extends StatelessWidget {
  final String certificateId;
  const VerifyCertificateScreen({super.key, required this.certificateId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: AppBar(title: const Text('Certificate Verification')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FutureBuilder<CertificateRecord?>(
              future: CourseService.instance.getCertificate(certificateId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final cert = snap.data;
                final valid = !snap.hasError && cert != null;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: valid
                          ? const Color(0xFF4C7A6B)
                          : const Color(0xFFFDA29B),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        valid ? Icons.verified_rounded : Icons.error_outline,
                        size: 64,
                        color: valid
                            ? const Color(0xFF4C7A6B)
                            : const Color(0xFFD92D20),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        valid ? 'Valid certificate' : 'Certificate not found',
                        style: const TextStyle(
                          color: AppTheme.deepBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (valid) ...[
                        _row('Issued to', cert.learnerName),
                        _row('Course', cert.courseTitle),
                        _row('Trainer / Instructor', cert.instructor),
                        _row('Date of completion', formatDate(cert.issuedAt)),
                        _row('Certificate ID', cert.id),
                      ] else
                        Text(
                          'We could not find a certificate with ID "$certificateId". '
                          'Please check the code and try again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.greyText, height: 1.5),
                        ),
                      const SizedBox(height: 22),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        ),
                        child: const Text('Visit MT Alchemy'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(color: AppTheme.greyText)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
