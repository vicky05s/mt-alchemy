import 'package:flutter/material.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/page_sections.dart';
import '../widgets/testimonials_section.dart';
import 'courses_screen.dart';

/// About MT Alchemy (brief Page 2): Who We Are, Vision, Mission, Our
/// Approach, Why Emotional Intelligence Matters, Our Impact, Founder, Team.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _para(String text) => Text(
        text,
        style: const TextStyle(
            color: AppTheme.greyText, fontSize: 16, height: 1.8),
      );

  Widget _card(IconData icon, String title, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppTheme.deepBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(text,
              style: const TextStyle(color: AppTheme.greyText, height: 1.7)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      children: [
        PageHero(
          eyebrow: 'OUR STORY',
          title: 'Elevate your value: master human intelligence in a rapidly evolving AI-driven world.',
          subtitle:
              'MT Alchemy is a people-development consultancy working with individuals, teams and organisations, taking a human-centered approach to development.',
          actions: [
            heroButton('Explore Learning', () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoursesScreen())),
                icon: Icons.school_outlined),
          ],
        ),
        const SectionHeading(eyebrow: 'Who we are', title: 'A human-centered approach'),
        _para(
            'MT Alchemy works with individuals, teams and organisations to build the human skills that matter most: emotional intelligence, leadership, communication, team effectiveness and workplace well-being.'),
        const SizedBox(height: 28),
        ResponsiveGrid(
          maxColumns: 2,
          children: [
            _card(Icons.visibility_outlined, 'Our Vision',
                'Workplaces and communities where people grow with awareness, empathy and purpose.',
                const Color(0xFFE9E0F5)),
            _card(Icons.flag_outlined, 'Our Mission',
                'To develop emotionally intelligent people, leaders and teams through practical, human-centered learning.',
                AppTheme.softYellow),
          ],
        ),
        const SectionHeading(eyebrow: 'Our approach', title: 'How we work'),
        ResponsiveGrid(
          children: const [
            FeatureCard(
                icon: Icons.hearing_outlined,
                title: 'Listen first',
                text: 'We start by understanding your people and your context.'),
            FeatureCard(
                icon: Icons.handyman_outlined,
                title: 'Practical learning',
                text: 'Activities and reflection that connect to everyday work.'),
            FeatureCard(
                icon: Icons.trending_up,
                title: 'Lasting change',
                text: 'Habits and follow-through that continue after the session.'),
          ],
        ),
        const SectionHeading(
            eyebrow: 'Why it matters', title: 'Why emotional intelligence matters'),
        _para(
            'As technology takes on more routine tasks, human skills such as self-awareness, empathy, communication and resilience become more valuable. Emotionally intelligent people and teams handle pressure, conflict and change better, and build trust.'),
        const SectionHeading(eyebrow: 'Our impact', title: 'Impact so far'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Row(
            children: [
              Text(participantsImpacted,
                  style: TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 44,
                      fontWeight: FontWeight.w900)),
              SizedBox(width: 18),
              Expanded(
                child: Text('participants impacted through MT Alchemy programmes.',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 16)),
              ),
            ],
          ),
        ),
        const SectionHeading(eyebrow: 'Founder', title: 'Meet the founder'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                    color: AppTheme.deepBlue, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('MT',
                    style: TextStyle(
                        color: AppTheme.softYellow,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(founderName,
                        style: TextStyle(
                            color: AppTheme.deepBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(founderTitle,
                        style: TextStyle(
                            color: AppTheme.purple, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const Text(
                      'Mabel leads MT Alchemy\'s work with individuals, teams and organisations, bringing a human-centered approach to people development.',
                      style: TextStyle(color: AppTheme.greyText, height: 1.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (teamMembers.isNotEmpty) ...[
          const SectionHeading(eyebrow: 'Our team', title: 'The people behind MT Alchemy'),
          ResponsiveGrid(
            children: [
              for (final m in teamMembers)
                FeatureCard(icon: Icons.person_outline, title: m.$1, text: m.$2),
            ],
          ),
        ],
        const TestimonialsSection(),
        CtaBand(
          title: "Let's build a thriving workplace together.",
          text: 'Talk to us about your goals.',
          label: 'Contact us',
          onPressed: () => openEnquiry(context, source: 'about'),
        ),
      ],
    );
  }
}
