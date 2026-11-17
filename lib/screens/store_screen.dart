import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../store/cart_provider.dart';
import '../store/product_models.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'product_detail_screen.dart';

/// Store: products come from Firestore (collection `products`).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  static const _categories = [
    'All',
    'Leadership',
    'Personal Growth',
    'Team Development',
  ];

  final _search = TextEditingController();
  late final Stream<List<Product>> _products;
  String _category = 'All';
  String _type = 'All'; // All | Digital | Physical
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _products = StoreService.instance.publishedProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> all) {
    final q = _search.text.toLowerCase().trim();
    return all.where((p) {
      final text = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final cat = _category == 'All' || p.category == _category;
      final type = _type == 'All' || p.type == _type;
      return text && cat && type;
    }).toList();
  }

  Future<void> _loadSamples() async {
    setState(() => _seeding = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await StoreService.instance.loadSampleProducts();
      messenger.showSnackBar(
          const SnackBar(content: Text('Sample products loaded.')));
    } catch (e) {
      debugPrint('Seeding products failed: $e');
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not load products. Are you logged in as admin?')));
    }
    if (mounted) setState(() => _seeding = false);
  }

  void _openProduct(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
    );
  }

  void _quickAdd(Product p) {
    final message = context.read<CartProvider>().add(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? '${p.name} added to cart.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().hasRole([UserRole.admin]);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: StreamBuilder<List<Product>>(
              stream: _products,
              builder: (context, snap) {
                final all = snap.data ?? const <Product>[];
                final products = _filter(all);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hero(),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search resources...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _search.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Product type:',
                            style: TextStyle(
                                color: AppTheme.greyText,
                                fontWeight: FontWeight.w600)),
                        for (final t in ['All', 'Digital', 'Physical'])
                          ChoiceChip(
                            avatar: Icon(
                              t == 'Digital'
                                  ? Icons.cloud_download_outlined
                                  : t == 'Physical'
                                      ? Icons.local_shipping_outlined
                                      : Icons.apps_rounded,
                              size: 18,
                              color: _type == t
                                  ? Colors.white
                                  : AppTheme.deepBlue,
                            ),
                            label: Text(t),
                            showCheckmark: false,
                            selected: _type == t,
                            selectedColor: AppTheme.deepBlue,
                            labelStyle: TextStyle(
                              color: _type == t
                                  ? Colors.white
                                  : AppTheme.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _type = t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _categories)
                          ChoiceChip(
                            label: Text(c),
                            selected: _category == c,
                            selectedColor: AppTheme.softYellow,
                            onSelected: (_) => setState(() => _category = c),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (snap.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snap.hasError)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                              'Products could not be loaded. Check that the Firestore rules are published.'),
                        ),
                      )
                    else if (all.isEmpty)
                      _emptyStore(isAdmin)
                    else ...[
                      Text(
                        '${products.length} ${products.length == 1 ? 'resource' : 'resources'}',
                        style: const TextStyle(
                          color: AppTheme.deepBlue,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (isAdmin)
                        TextButton.icon(
                          onPressed: _seeding ? null : _loadSamples,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(_seeding
                              ? 'Reloading…'
                              : 'Admin: reload sample products'),
                        ),
                      const SizedBox(height: 16),
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: Text('No resources found. Try another search.'),
                          ),
                        )
                      else
                        _grid(products),
                    ],
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOOLS FOR GROWTH',
            style: TextStyle(
              color: AppTheme.softYellow,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Resources for your next step.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Digital downloads and physical resources for leadership, '
            'personal growth and team development.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _emptyStore(bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront_outlined,
              size: 40, color: AppTheme.purple),
          const SizedBox(height: 10),
          const Text('The store is being stocked.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'You are signed in as admin. Load the sample products to get started.'
                : 'Please check back soon.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.greyText),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _seeding ? null : _loadSamples,
              icon: const Icon(Icons.download_rounded),
              label: Text(_seeding ? 'Loading…' : 'Load sample products'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _grid(List<Product> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 540
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 300,
          ),
          itemBuilder: (context, i) => _card(products[i]),
        );
      },
    );
  }

  Widget _card(Product p) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openProduct(p),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4E0E9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: AppTheme.purple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(p.icon, color: AppTheme.purple, size: 30),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.category,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TypeBadge(p.type),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                p.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.greyText,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        money(p.price),
                        style: const TextStyle(
                          color: AppTheme.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        p.availability,
                        style: TextStyle(
                          fontSize: 11,
                          color: p.inStock
                              ? AppTheme.greyText
                              : const Color(0xFFD92D20),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Add to cart',
                  onPressed: p.inStock ? () => _quickAdd(p) : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                ),
                IconButton.filled(
                  tooltip: 'View product',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.deepBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openProduct(p),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
