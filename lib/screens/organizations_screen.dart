import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/page_sections.dart';
import '../widgets/testimonials_section.dart';
import 'corporate_programmes_screen.dart';
import 'services_screen.dart';

/// Main corporate landing page (brief Page 5) and the start of Journey E:
/// Organizations -> select service -> submit enquiry.
class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key});

  void _talk(BuildContext context, {String? service}) => openEnquiry(
        context,
        type: 'Corporate Training',
        service: service ?? 'Talk to MT Alchemy',
        message: service == null
            ? null
            : 'I would like to enquire about: $service.',
        source: 'organizations',
      );

  @override
  Widget build(BuildContext context) {
    return PageShell(
      children: [
        PageHero(
          eyebrow: 'FOR ORGANIZATIONS',
          title: 'Build emotionally intelligent leaders and resilient workplace cultures.',
          subtitle:
              'People-centred development that helps your teams communicate, lead and thrive.',
          actions: [
            heroButton('Talk to MT Alchemy', () => _talk(context),
                icon: Icons.chat_bubble_outline),
            heroOutlineButton(
                'View corporate programmes',
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CorporateProgrammesScreen()))),
          ],
        ),
        const SectionHeading(
          eyebrow: 'Organizational challenges',
          title: 'Does any of this sound familiar?',
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in organizationalChallenges)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 18, color: AppTheme.purple),
                    const SizedBox(width: 8),
                    Text(c,
                        style: const TextStyle(
                            color: AppTheme.deepBlue,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
        const SectionHeading(
          eyebrow: 'Solutions',
          title: 'How we help',
          subtitle: 'Tap a solution to start an enquiry.',
        ),
        ResponsiveGrid(
          maxColumns: 4,
          children: [
            for (final s in organizationalSolutions)
              FeatureCard(
                icon: s.$2,
                title: s.$1,
                onTap: () => _talk(context, service: s.$1),
              ),
          ],
        ),
        const SectionHeading(eyebrow: 'Impact', title: 'Real people, real change'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Text(participantsImpacted,
                  style: TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 44,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 18),
              const Expanded(
                child: Text('participants impacted through MT Alchemy programmes.',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 16)),
              ),
            ],
          ),
        ),
        const TestimonialsSection(),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: TextButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ServicesScreen())),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('See all services'),
            ),
          ),
        ),
        CtaBand(
          title: "Let's build a thriving workplace together.",
          text: 'Tell us about your organisation and we will arrange a consultation.',
          label: 'Talk to MT Alchemy',
          onPressed: () => _talk(context),
        ),
      ],
    );
  }
}
