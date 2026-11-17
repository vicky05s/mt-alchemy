import 'package:flutter/material.dart';

import '../learning/course_models.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'digital_library_screen.dart';

/// Order detail and tracking: status timeline, items, totals, addresses.
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

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
          final o = snap.data;
          if (o == null) return const Center(child: Text('Order not found.'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${o.orderNumber}',
                        style: const TextStyle(
                            color: AppTheme.deepBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Placed on ${formatDate(o.createdAt)}',
                        style: const TextStyle(color: AppTheme.greyText)),
                    const SizedBox(height: 20),
                    _card('Order status', [
                      OrderTimeline(flow: o.flow, current: o.status),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text('Payment: ',
                              style: TextStyle(color: AppTheme.greyText)),
                          StatusChip(o.paymentStatus),
                        ],
                      ),
                      if (o.paymentStatus == 'pending')
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Your payment is pending. Digital downloads unlock and the order moves on once it is confirmed.',
                            style: TextStyle(color: AppTheme.greyText, height: 1.4),
                          ),
                        ),
                      if (o.hasDigital && o.paymentStatus == 'successful')
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DigitalLibraryScreen()),
                            ),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Open My Digital Products'),
                          ),
                        ),
                    ]),
                    _card('Items', [
                      for (final i in o.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(child: Text('${i.quantity} × ${i.name}')),
                              TypeBadge(i.type),
                              const SizedBox(width: 10),
                              Text(money(i.price * i.quantity)),
                            ],
                          ),
                        ),
                      const Divider(height: 24),
                      _line('Subtotal', money(o.subtotal)),
                      _line('Discount', money(o.discount)),
                      _line('Shipping',
                          o.hasPhysical ? money(o.shippingFee) : 'Free'),
                      _line('Total', money(o.total), bold: true),
                    ]),
                    if (o.hasPhysical)
                      _card('Shipping address', [
                        Text(
                          '${o.customer['name'] ?? ''}\n'
                          '${o.shipping['address'] ?? ''}\n'
                          '${o.shipping['postcode'] ?? ''} ${o.shipping['city'] ?? ''}, '
                          '${o.shipping['state'] ?? ''}\n${o.shipping['country'] ?? ''}',
                          style: const TextStyle(
                              color: AppTheme.greyText, height: 1.5),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _line(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
            Text(v,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                    color: bold ? AppTheme.deepBlue : null)),
          ],
        ),
      );
}
