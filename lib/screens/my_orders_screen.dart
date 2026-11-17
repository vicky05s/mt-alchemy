import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'order_detail_screen.dart';
import 'store_screen.dart';

/// My Orders (brief Page 23): Order, Date, Amount, Status. Tap for detail.
class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: uid == null
          ? const Center(child: Text('Please sign in to see your orders.'))
          : StreamBuilder<List<OrderRecord>>(
              stream: StoreService.instance.ordersForUser(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snap.data ?? const <OrderRecord>[];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Orders',
                              style: TextStyle(
                                  color: AppTheme.deepBlue,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text(
                              'Your digital and physical purchases, with their status.',
                              style: TextStyle(color: AppTheme.greyText)),
                          const SizedBox(height: 20),
                          if (snap.hasError)
                            const Text(
                                'Orders could not be loaded. Check that the Firestore rules are published.')
                          else if (orders.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFFE4E0E9)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.receipt_long_outlined,
                                      size: 40, color: AppTheme.purple),
                                  const SizedBox(height: 10),
                                  const Text('No orders yet.'),
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const StoreScreen()),
                                    ),
                                    child: const Text('Visit Store'),
                                  ),
                                ],
                              ),
                            )
                          else
                            for (final o in orders) _row(context, o),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(BuildContext context, OrderRecord o) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E0E9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: AppTheme.purple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${o.orderNumber}',
                      style: const TextStyle(
                          color: AppTheme.deepBlue,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                    '${formatDate(o.createdAt)} · ${o.items.length} ${o.items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                        color: AppTheme.greyText, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(money(o.total),
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 14),
            StatusChip(o.status),
            const Icon(Icons.chevron_right, color: AppTheme.greyText),
          ],
        ),
      ),
    );
  }
}
