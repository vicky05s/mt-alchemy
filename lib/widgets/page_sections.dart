import 'package:flutter/material.dart';

import '../screens/contact_screen.dart';
import '../theme/app_theme.dart';
import 'main_app_bar.dart';

/// Opens the enquiry (contact) form with some fields pre-filled.
void openEnquiry(
  BuildContext context, {
  String? type,
  String? service,
  String? message,
  String source = 'contact',
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ContactScreen(
        initialType: type,
        service: service,
        initialMessage: message,
        source: source,
      ),
    ),
  );
}

/// Standard page: shared header, centred 1100px column, scrolls.
class PageShell extends StatelessWidget {
  final List<Widget> children;
  const PageShell({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...children, const SizedBox(height: 30)],
            ),
          ),
        ),
      ),
    );
  }
}

class PageHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const PageHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.softYellow,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              eyebrow,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: const TextStyle(
                color: Colors.white70, fontSize: 16, height: 1.6),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ],
      ),
    );
  }
}

/// Yellow button used on dark heroes.
Widget heroButton(String label, VoidCallback onPressed, {IconData? icon}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.softYellow,
      foregroundColor: AppTheme.deepBlue,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    ),
  );
}

/// Outlined button used on dark heroes.
Widget heroOutlineButton(String label, VoidCallback onPressed) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white54),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
    ),
    child: Text(label),
  );
}

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.purple,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: const TextStyle(
                    color: AppTheme.greyText, fontSize: 15, height: 1.6)),
          ],
        ],
      ),
    );
  }
}

/// White card with an icon, title and text.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.text = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: AppTheme.purple),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(text,
                  style: const TextStyle(color: AppTheme.greyText, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Responsive grid of equally sized children.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int maxColumns;
  const ResponsiveGrid({super.key, required this.children, this.maxColumns = 3});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 16.0;
        var cols = c.maxWidth > 820 ? maxColumns : (c.maxWidth > 520 ? 2 : 1);
        if (cols > maxColumns) cols = maxColumns;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final ch in children) SizedBox(width: w, child: ch)],
        );
      },
    );
  }
}

/// Lilac call-to-action band.
class CtaBand extends StatelessWidget {
  final String title;
  final String text;
  final String label;
  final VoidCallback onPressed;

  const CtaBand({
    super.key,
    required this.title,
    required this.text,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E0F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
