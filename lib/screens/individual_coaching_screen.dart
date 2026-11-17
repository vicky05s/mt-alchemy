import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/page_sections.dart';
import '../widgets/testimonials_section.dart';

/// Individual Coaching (brief Page 4).
class IndividualCoachingScreen extends StatelessWidget {
  const IndividualCoachingScreen({super.key});

  void _book(BuildContext context) => openEnquiry(
        context,
        type: 'Individual Coaching',
        service: 'Individual Coaching',
        message: 'I would like to book a coaching session.',
        source: 'coaching',
      );

  @override
  Widget build(BuildContext context) {
    return PageShell(
      children: [
        PageHero(
          eyebrow: 'INDIVIDUAL COACHING',
          title: 'Clarity, confidence and a plan for your next step.',
          subtitle:
              'One-to-one coaching to help you grow in your career, relationships and personal life.',
          actions: [
            heroButton('Book a Coaching Session', () => _book(context),
                icon: Icons.event_available_outlined),
          ],
        ),
        const SectionHeading(eyebrow: 'Who it is for', title: 'Is coaching right for you?'),
        const Text(
          'Individual coaching is for anyone who wants focused, confidential support to move forward, whether you are starting out, changing direction or growing in your role.',
          style: TextStyle(color: AppTheme.greyText, fontSize: 16, height: 1.7),
        ),
        const SectionHeading(eyebrow: 'Coaching focus', title: 'What we can work on'),
        ResponsiveGrid(
          maxColumns: 4,
          children: [
            for (final f in coachingFocus)
              FeatureCard(icon: f.$2, title: f.$1, text: f.$3),
          ],
        ),
        const SectionHeading(eyebrow: 'How it works', title: 'Four simple steps'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < coachingSteps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.softYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: AppTheme.deepBlue,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coachingSteps[i].$1,
                                style: const TextStyle(
                                    color: AppTheme.deepBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(coachingSteps[i].$2,
                                style: const TextStyle(
                                    color: AppTheme.greyText, height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SectionHeading(eyebrow: 'Available programmes', title: 'Ways to work together'),
        ResponsiveGrid(
          maxColumns: 3,
          children: [
            for (final p in coachingProgrammes)
              FeatureCard(
                icon: Icons.self_improvement_outlined,
                title: p.$1,
                text: '${p.$2}\nEnquire for details.',
                onTap: () => openEnquiry(
                  context,
                  type: 'Individual Coaching',
                  service: p.$1,
                  message: 'I would like to know more about: ${p.$1}.',
                  source: 'coaching',
                ),
              ),
          ],
        ),
        const SectionHeading(eyebrow: 'FAQs', title: 'Common questions'),
        for (final f in coachingFaqs)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(f.$1,
                    style: const TextStyle(
                        color: AppTheme.deepBlue, fontWeight: FontWeight.w700)),
                children: [
                  Text(f.$2,
                      style: const TextStyle(
                          color: AppTheme.greyText, height: 1.6)),
                ],
              ),
            ),
          ),
        const TestimonialsSection(),
        CtaBand(
          title: 'Ready to start?',
          text: 'Book a coaching session and tell us what you would like to work on.',
          label: 'Book a Coaching Session',
          onPressed: () => _book(context),
        ),
      ],
    );
  }
}
