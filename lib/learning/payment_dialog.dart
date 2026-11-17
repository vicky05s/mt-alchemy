import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum PaymentResult { successful, failed, pending, cancelled }

/// SIMULATED checkout. No real money moves. It lets us demonstrate the
/// Successful / Failed / Pending payment states the brief asks for.
/// A real payment gateway replaces this later.
Future<PaymentResult> showSimulatedPayment(
  BuildContext context, {
  required String title,
  required double amount,
}) async {
  final result = await showDialog<PaymentResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Checkout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppTheme.deepBlue)),
          const SizedBox(height: 6),
          Text('Amount: RM ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.softYellow.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Demo mode: no real payment is taken. Choose an outcome to '
              'see how the platform handles it.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.start,
      actionsOverflowButtonSpacing: 6,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, PaymentResult.successful),
          child: const Text('Pay now (successful)'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, PaymentResult.failed),
          child: const Text('Simulate failed'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, PaymentResult.pending),
          child: const Text('Simulate pending'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, PaymentResult.cancelled),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
  return result ?? PaymentResult.cancelled;
}
