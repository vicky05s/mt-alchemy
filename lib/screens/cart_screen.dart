import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../store/cart_provider.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'store_screen.dart';

/// Shopping cart (reads CartProvider, so the header badge stays in sync).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _checkout(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to check out. Your cart will be kept.'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: cart.isEmpty
          ? _empty(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 18, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Shopping Bag',
                        style: TextStyle(
                          color: AppTheme.deepBlue,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${cart.count} ${cart.count == 1 ? 'item' : 'items'} · review your resources before checkout.',
                        style: const TextStyle(color: AppTheme.greyText),
                      ),
                      const SizedBox(height: 22),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _items(context, cart)),
                            const SizedBox(width: 24),
                            SizedBox(width: 340, child: _summary(context, cart)),
                          ],
                        )
                      else ...[
                        _items(context, cart),
                        const SizedBox(height: 20),
                        _summary(context, cart),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 64, color: AppTheme.purple),
            const SizedBox(height: 16),
            const Text('Your bag is empty',
                style: TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Explore the store to find resources for your next step.',
                style: TextStyle(color: AppTheme.greyText)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreScreen()),
              ),
              child: const Text('Browse the Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _items(BuildContext context, CartProvider cart) {
    return Column(
      children: [for (final item in cart.items) _line(context, cart, item)],
    );
  }

  Widget _line(BuildContext context, CartProvider cart, CartItem item) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.deepBlue.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(p.icon, color: AppTheme.purple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TypeBadge(p.type),
                    const SizedBox(width: 8),
                    Text(money(p.price),
                        style: const TextStyle(color: AppTheme.greyText)),
                  ],
                ),
                const SizedBox(height: 10),
                if (p.isPhysical)
                  Row(
                    children: [
                      _qtyButton(Icons.remove,
                          () => cart.setQuantity(p.id, item.quantity - 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      _qtyButton(
                          Icons.add,
                          item.quantity < p.stock
                              ? () => cart.setQuantity(p.id, item.quantity + 1)
                              : null),
                    ],
                  )
                else
                  const Text('Digital download · 1 copy',
                      style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(item.lineTotal),
                  style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () => cart.remove(p.id),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E0E9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      ),
    );
  }

  Widget _summary(BuildContext context, CartProvider cart) {
    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
              Text(value,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                      color: bold ? AppTheme.deepBlue : null,
                      fontSize: bold ? 19 : null)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.deepBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue)),
          const SizedBox(height: 20),
          row('Subtotal', money(cart.subtotal)),
          row('Discount', money(cart.discount)),
          row('Shipping', cart.hasPhysical ? money(cart.shipping) : 'Free (digital only)'),
          const Divider(height: 24),
          row('Total', money(cart.total), bold: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _checkout(context),
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}
