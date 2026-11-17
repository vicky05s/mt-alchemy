import 'package:flutter/material.dart';

import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'digital_library_screen.dart';
import 'order_detail_screen.dart';
import 'store_screen.dart';

/// Shown right after checkout (brief Page 22).
class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: StreamBuilder<OrderRecord?>(
        stream: StoreService.instance.order(orderId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snap.data;
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }
          final paid = order.paymentStatus == 'successful';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Icon(
                      paid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                      size: 72,
                      color: paid ? const Color(0xFF4C7A6B) : const Color(0xFFB7791F),
                    ),
                    const SizedBox(height: 14),
                    const Text('Thank you for your order.',
                        style: TextStyle(
                            color: AppTheme.deepBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      paid
                          ? 'Your payment was successful.'
                          : 'Your payment is pending. We will confirm it shortly.',
                      style: const TextStyle(color: AppTheme.greyText),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4E0E9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Order number', '#${order.orderNumber}'),
                          _row('Amount paid',
                              paid ? money(order.total) : '${money(order.total)} (due)'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const SizedBox(
                                    width: 140,
                                    child: Text('Payment status',
                                        style: TextStyle(
                                            color: AppTheme.greyText))),
                                StatusChip(order.paymentStatus),
                              ],
                            ),
                          ),
                          _row('Order status', order.status),
                          const Divider(height: 28),
                          const Text('Items',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          for (final i in order.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${i.quantity} × ${i.name}')),
                                  TypeBadge(i.type),
                                  const SizedBox(width: 10),
                                  Text(money(i.price * i.quantity)),
                                ],
                              ),
                            ),
                          if (order.hasPhysical) ...[
                            const Divider(height: 28),
                            const Text('Shipping information',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text(
                              '${order.customer['name'] ?? ''}\n'
                              '${order.shipping['address'] ?? ''}, '
                              '${order.shipping['postcode'] ?? ''} ${order.shipping['city'] ?? ''}, '
                              '${order.shipping['state'] ?? ''}, ${order.shipping['country'] ?? ''}',
                              style: const TextStyle(
                                  color: AppTheme.greyText, height: 1.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        if (order.hasDigital && paid)
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DigitalLibraryScreen()),
                            ),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download Product'),
                          ),
                        if (order.hasPhysical)
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailScreen(orderId: order.id)),
                            ),
                            icon: const Icon(Icons.local_shipping_outlined),
                            label: const Text('Track Order'),
                          ),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StoreScreen()),
                          ),
                          child: const Text('Continue Shopping'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppTheme.greyText)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
