import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/cart_provider.dart';
import '../store/product_models.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get p => widget.product;

  void _add() {
    final message =
        context.read<CartProvider>().add(p, quantity: p.isDigital ? 1 : _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Added to cart.'),
        action: message == null
            ? SnackBarAction(
                label: 'VIEW CART',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                const SizedBox(height: 28),
                const Text(
                  'About this resource',
                  style: TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  p.description,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 24),
                _detailsCard(),
                const SizedBox(height: 28),
                _related(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.deepBlue, Color(0xFF344C76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(p.icon, size: 64, color: AppTheme.softYellow),
          ),
          const SizedBox(height: 22),
          Text(
            p.category.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.softYellow,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          TypeBadge(p.type),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.purple, size: 20),
              const SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: Text(label,
                    style: const TextStyle(color: AppTheme.greyText)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        color: AppTheme.darkText, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product details',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          row(Icons.category_outlined, 'Product type',
              p.isDigital ? 'Digital download' : 'Physical product'),
          row(Icons.inventory_outlined, 'Availability', p.availability),
          if (p.isPhysical) ...[
            row(Icons.numbers_rounded, 'Stock quantity', '${p.stock}'),
            row(Icons.local_shipping_outlined, 'Shipping',
                'Shipping required (${money(kShippingFee)} flat rate)'),
            if (p.weightKg > 0)
              row(Icons.scale_outlined, 'Weight',
                  '${p.weightKg.toStringAsFixed(2)} kg'),
          ] else ...[
            row(Icons.lock_open_outlined, 'Download access',
                'Unlocked in My Digital Products after you buy'),
            if (p.accessInstructions.isNotEmpty)
              row(Icons.info_outline, 'How to access', p.accessInstructions),
          ],
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price',
                  style: TextStyle(color: AppTheme.greyText)),
              Text(
                money(p.price),
                style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (p.isPhysical && p.inStock)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E0E9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$_quantity',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      IconButton(
                        onPressed: _quantity < p.stock
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ElevatedButton.icon(
                onPressed: p.inStock ? _add : null,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 19),
                label: Text(p.inStock ? 'Add to Cart' : 'Out of stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.deepBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  side: const BorderSide(color: AppTheme.deepBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _related() {
    return StreamBuilder<List<Product>>(
      stream: StoreService.instance.publishedProducts(),
      builder: (context, snap) {
        final others = (snap.data ?? const <Product>[])
            .where((x) => x.id != p.id)
            .toList()
          ..sort((a, b) {
            // same category first
            final sa = a.category == p.category ? 0 : 1;
            final sb = b.category == p.category ? 0 : 1;
            return sa.compareTo(sb);
          });
        final related = others.take(3).toList();
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Related products',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final r in related)
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: r)),
                    ),
                    child: Container(
                      width: 270,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4E0E9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.purple.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(r.icon, color: AppTheme.purple),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(money(r.price),
                                        style: const TextStyle(
                                            color: AppTheme.deepBlue,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(width: 8),
                                    TypeBadge(r.type),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
