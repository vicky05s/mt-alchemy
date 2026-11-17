import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'page_sections.dart';

/// Shows real testimonials from Firestore (collection `testimonials`, with
/// fields quote, author, role, published=true). Hidden when there are none,
/// so no fake quotes are ever shown. Add them in the Firebase console for now.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('testimonials')
          .where('published', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
                eyebrow: 'Testimonials', title: 'What people say'),
            ResponsiveGrid(
              maxColumns: 2,
              children: [
                for (final d in docs)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppTheme.purple, size: 30),
                        const SizedBox(height: 8),
                        Text('${d.data()['quote'] ?? ''}',
                            style: const TextStyle(height: 1.6)),
                        const SizedBox(height: 12),
                        Text('${d.data()['author'] ?? ''}',
                            style: const TextStyle(
                                color: AppTheme.deepBlue,
                                fontWeight: FontWeight.w800)),
                        if ('${d.data()['role'] ?? ''}'.isNotEmpty)
                          Text('${d.data()['role']}',
                              style: const TextStyle(
                                  color: AppTheme.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
