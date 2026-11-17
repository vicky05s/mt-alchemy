import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const _borderColor = Color(0xFFE4E0E9);

/// Shared text-field style for the auth screens (matches the app theme).
InputDecoration authInput(
    String label, {
      IconData? icon,
      Widget? suffix,
      String? hint,
    }) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon:
    icon == null ? null : Icon(icon, color: AppTheme.purple, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppTheme.background,
    border: border(_borderColor),
    enabledBorder: border(_borderColor),
    focusedBorder: border(AppTheme.deepBlue, 1.6),
    errorBorder: border(const Color(0xFFD92D20)),
    focusedErrorBorder: border(const Color(0xFFD92D20), 1.6),
  );
}

/// White rounded card, centred, scrollable, max width.
class AuthCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const AuthCard({super.key, required this.child, this.maxWidth = 480});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.deepBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppTheme.softYellow, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.deepBlue,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.greyText, height: 1.5),
        ),
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDA29B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD92D20), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Color(0xFFB42318))),
          ),
        ],
      ),
    );
  }
}

/// Full-width primary button that shows a spinner while [busy].
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: busy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: busy
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppTheme.softYellow),
      )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class Validators {
  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? email(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'Enter a valid email address';
  }

  static String? phone(String? v) {
    final r = required(v, 'Phone number');
    if (r != null) return r;
    final digits = v!.replaceAll(RegExp(r'[\s\-+()]'), '');
    return RegExp(r'^\d{8,15}$').hasMatch(digits)
        ? null
        : 'Enter a valid phone number';
  }

  static String? password(String? v) {
    if (v == null || v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use both letters and numbers';
    }
    return null;
  }
}