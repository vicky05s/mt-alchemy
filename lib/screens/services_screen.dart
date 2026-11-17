import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/page_sections.dart';
import 'individual_coaching_screen.dart';
import 'organizations_screen.dart';

/// Services directory (brief Page 3): six categories, each with a write-up,
/// who it is for, key objectives and an Enquiry button.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      children: [
        PageHero(
          eyebrow: 'MT ALCHEMY SERVICES',
          title: 'Learning that moves people forward.',
          subtitle:
              'Explore how MT Alchemy supports individuals, teams and organisations.',
          actions: [
            heroButton('Get a Free Consultation', () => openEnquiry(
                  context,
                  type: 'Corporate Training',
                  service: 'Free consultation',
                  message: 'I would like a free consultation.',
                  source: 'services',
                )),
          ],
        ),
        const SectionHeading(eyebrow: 'Who it is for', title: 'Choose your path'),
        ResponsiveGrid(
          maxColumns: 2,
          children: [
            FeatureCard(
              icon: Icons.person_outline,
              title: 'For Individuals',
              text: 'One-to-one coaching for career, relationships and personal growth.',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const IndividualCoachingScreen())),
            ),
            FeatureCard(
              icon: Icons.business_outlined,
              title: 'For Organizations',
              text: 'Build emotionally intelligent leaders and resilient workplace cultures.',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrganizationsScreen())),
            ),
          ],
        ),
        const SectionHeading(
          eyebrow: 'Service directory',
          title: 'What we offer',
          subtitle: 'Tap a service to see who it is for and what it covers.',
        ),
        for (final s in serviceCategories) _ServiceTile(service: s),
        CtaBand(
          title: 'Need help choosing?',
          text: 'Tell us what you or your organisation would like to develop and we will guide you.',
          label: 'Get a Free Consultation',
          onPressed: () => openEnquiry(
            context,
            type: 'Corporate Training',
            service: 'Free consultation',
            source: 'services',
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceCategory service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(service.icon, color: AppTheme.purple),
          ),
          title: Text(service.title,
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
          subtitle: Text(service.summary,
              style: const TextStyle(color: AppTheme.greyText, height: 1.4)),
          children: [
            const Text('Who it is for',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(service.audience,
                style: const TextStyle(color: AppTheme.greyText, height: 1.5)),
            const SizedBox(height: 14),
            const Text('Key objectives',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            for (final o in service.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 18, color: AppTheme.purple),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(o,
                            style: const TextStyle(
                                color: AppTheme.greyText, height: 1.4))),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => openEnquiry(
                context,
                type: service.enquiryType,
                service: service.title,
                message: 'I would like to enquire about: ${service.title}.',
                source: 'services',
              ),
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Enquire about this service'),
            ),
          ],
        ),
      ),
    );
  }
}
