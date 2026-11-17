import 'package:flutter/material.dart';

import '../learning/course_models.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';

/// Staff order management (brief 4.33): see every order and move it along
/// Pending -> Paid -> Processing -> Shipped -> Delivered
/// (digital: Pending -> Paid -> Available).
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      debugPrint('Order update failed: $e');
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not update the order.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Order Management')),
      body: StreamBuilder<List<OrderRecord>>(
        stream: StoreService.instance.allOrders(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
                child: Text('Orders could not be loaded. Are the rules published?'));
          }
          final orders = snap.data ?? const <OrderRecord>[];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              final next = o.nextStatus;
              final pendingPayment = o.paymentStatus == 'pending';

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E0E9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('#${o.orderNumber}',
                                  style: const TextStyle(
                                      color: AppTheme.deepBlue,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800)),
                            ),
                            Text(money(o.total),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${o.customer['name'] ?? 'Customer'} · ${o.customer['email'] ?? ''} · ${formatDate(o.createdAt)}',
                          style: const TextStyle(
                              color: AppTheme.greyText, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          o.items.map((l) => '${l.quantity} × ${l.name}').join(', '),
                          style: const TextStyle(height: 1.4),
                        ),
                        if (o.hasPhysical)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Ship to: ${o.shipping['address'] ?? ''}, ${o.shipping['postcode'] ?? ''} ${o.shipping['city'] ?? ''}, ${o.shipping['state'] ?? ''}',
                              style: const TextStyle(
                                  color: AppTheme.greyText, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Payment:'),
                            StatusChip(o.paymentStatus),
                            const Text('Order:'),
                            StatusChip(o.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OrderTimeline(flow: o.flow, current: o.status),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            if (pendingPayment)
                              ElevatedButton.icon(
                                onPressed: () => _run(
                                  context,
                                  () => StoreService.instance
                                      .markPaymentReceived(o),
                                ),
                                icon: const Icon(Icons.payments_outlined,
                                    size: 18),
                                label: const Text('Mark payment received'),
                              )
                            else if (next != null)
                              ElevatedButton.icon(
                                onPressed: () => _run(
                                  context,
                                  () => StoreService.instance.advanceOrder(o),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                                label: Text('Move to $next'),
                              )
                            else
                              const Text('Order complete',
                                  style: TextStyle(color: AppTheme.greyText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
