
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Certificate'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Certificate
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.softYellow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.deepBlue,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: AppTheme.purple,
                          size: 56,
                        ),
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
                        const SizedBox(height: 24),
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
                        const SizedBox(height: 24),
                        Text(
                          'This sample certificate is presented to',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Alex Morgan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.purple,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'for completing the prototype course',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Leadership Development',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.deepBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Demonstrating commitment to learning, '
                              'leadership growth and professional development.',
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1.6),
                        ),
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 36,
                          runSpacing: 20,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '09 October 2026',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Sample Issue Date',
                                  style: TextStyle(
                                    color: AppTheme.greyText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'MT-PROTOTYPE-001',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Sample Certificate ID',
                                  style: TextStyle(
                                    color: AppTheme.greyText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'SAMPLE — NOT AN OFFICIAL CREDENTIAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.deepBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons below the certificate, not fixed over it
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 220,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                                (route) => route.isFirst,
                          );
                        },
                        child: const Text('Back to Home'),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Certificate download is a prototype feature.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
