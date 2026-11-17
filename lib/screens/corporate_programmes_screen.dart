import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../content/brochure_pdf.dart';
import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/page_sections.dart';

/// Programme catalogue (brief Page 6). Public programmes have a fixed price;
/// corporate programmes are "Request a Quote".
class CorporateProgrammesScreen extends StatelessWidget {
  const CorporateProgrammesScreen({super.key});

  Future<void> _brochure(BuildContext context, Programme p) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await buildBrochurePdf(p);
      await Printing.sharePdf(bytes: bytes, filename: '${p.id}-brochure.pdf');
    } catch (e) {
      debugPrint('Brochure failed: $e');
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not create the brochure.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      children: [
        const PageHero(
          eyebrow: 'PROGRAMMES',
          title: 'Programmes for your people.',
          subtitle:
              'Choose a ready-made public programme, or ask for a corporate programme tailored to your team. Programmes can adapt to diverse workforce and team demographics under customization.',
        ),
        const SectionHeading(eyebrow: 'Browse', title: 'Available programmes'),
        for (final p in programmes) _card(context, p),
        CtaBand(
          title: 'Need something different?',
          text: 'We design customised programmes around your goals and workforce.',
          label: 'Request a custom programme',
          onPressed: () => openEnquiry(
            context,
            type: 'Corporate Training',
            service: 'Customized Programmes',
            source: 'programmes',
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, Programme p) {
    Widget fact(IconData icon, String label, String value) => SizedBox(
          width: 230,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppTheme.purple),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppTheme.greyText, fontSize: 11)),
                    Text(value,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p.isPublic
                      ? AppTheme.deepBlue.withValues(alpha: 0.08)
                      : AppTheme.softYellow.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(p.type,
                    style: const TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
              Text(
                p.price == null
                    ? 'Request a Quote'
                    : 'RM ${p.price!.toStringAsFixed(0)} per person',
                style: const TextStyle(
                    color: AppTheme.deepBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.title,
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(p.description,
              style: const TextStyle(color: AppTheme.greyText, height: 1.6)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              fact(Icons.schedule_rounded, 'Duration', p.duration),
              fact(Icons.groups_outlined, 'Participants', p.participants),
              fact(Icons.devices_outlined, 'Delivery mode', p.delivery),
              fact(Icons.person_outline, 'Trainer', p.trainer),
              fact(Icons.flag_outlined, 'Target audience', p.audience),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Learning objectives',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final o in p.objectives)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
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
          const SizedBox(height: 12),
          const Text('Modules', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final m in p.modules)
                Chip(
                  label: Text(m, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => openEnquiry(
                  context,
                  type: 'Corporate Training',
                  service: p.title,
                  message: p.price == null
                      ? 'Please send me a quote for: ${p.title}.'
                      : 'I would like to enquire about: ${p.title}.',
                  source: 'programmes',
                ),
                icon: const Icon(Icons.mail_outline, size: 18),
                label: Text(p.price == null ? 'Request a Quote' : 'Enquire'),
              ),
              OutlinedButton.icon(
                onPressed: () => _brochure(context, p),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download brochure'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
