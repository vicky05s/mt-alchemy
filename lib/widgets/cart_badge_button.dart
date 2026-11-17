import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/cart_provider.dart';

/// Cart icon with a live item-count badge (reads CartProvider).
class CartBadgeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CartBadgeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;

    return IconButton(
      tooltip: 'Cart',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
