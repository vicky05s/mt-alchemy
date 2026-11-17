import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

String money(double v) => 'RM ${v.toStringAsFixed(2)}';

/// Small "Digital" / "Physical" pill.
class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    final digital = type == 'Digital';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: digital
            ? AppTheme.deepBlue.withValues(alpha: 0.08)
            : AppTheme.softYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            digital ? Icons.cloud_download_outlined : Icons.local_shipping_outlined,
            size: 13,
            color: AppTheme.deepBlue,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: const TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured chip for an order status or payment status.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'successful':
      case 'available':
      case 'delivered':
        return const Color(0xFF4C7A6B);
      case 'processing':
      case 'shipped':
        return AppTheme.purple;
      case 'failed':
        return const Color(0xFFD92D20);
      default: // pending
        return const Color(0xFFB7791F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty
        ? status
        : status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Horizontal progress of an order through its statuses.
class OrderTimeline extends StatelessWidget {
  final List<String> flow;
  final String current;
  const OrderTimeline({super.key, required this.flow, required this.current});

  @override
  Widget build(BuildContext context) {
    final currentIndex = flow.indexOf(current);
    return Wrap(
      spacing: 6,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < flow.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: i <= currentIndex
                  ? AppTheme.deepBlue
                  : const Color(0xFFEDEAF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i <= currentIndex)
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(Icons.check_circle,
                        size: 14, color: AppTheme.softYellow),
                  ),
                Text(
                  flow[i],
                  style: TextStyle(
                    color: i <= currentIndex ? Colors.white : AppTheme.greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (i < flow.length - 1)
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.greyText),
        ],
      ],
    );
  }
}
