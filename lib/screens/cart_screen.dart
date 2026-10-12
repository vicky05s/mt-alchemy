import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static final List<Map<String, dynamic>> items = [];

  static void addProduct(Map<String, dynamic> product) {
    final index = items.indexWhere(
          (item) => item['name'] == product['name'],
    );

    if (index >= 0) {
      items[index]['quantity'] = (items[index]['quantity'] as int) + 1;
    } else {
      items.add({...product, 'quantity': 1});
    }
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total => CartScreen.items.fold<double>(
    0,
        (sum, item) =>
    sum +
        (item['price'] as num).toDouble() *
            (item['quantity'] as int),
  );

  @override
  Widget build(BuildContext context) {
    final items = CartScreen.items;
    final isWide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your Shopping Bag'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.deepBlue,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _emptyCart()
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 18,
              vertical: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your picks, your progress.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Review your learning resources before checkout.',
                  style: TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 26),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _productList(items)),
                      const SizedBox(width: 28),
                      SizedBox(width: 320, child: _orderSummary()),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _productList(items),
                      const SizedBox(height: 22),
                      _orderSummary(),
                    ],
                  ),
                const SizedBox(height: 36),
                _trustStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCart() {
    final storeProducts = <Map<String, dynamic>>[
      {
        'name': 'Leadership Toolkit',
        'category': 'Leadership',
        'price': 49.0,
        'icon': Icons.groups_rounded,
        'description':
        'Practical resources for developing leadership skills.',
      },
      {
        'name': 'Emotional Intelligence Workbook',
        'category': 'Personal Growth',
        'price': 29.0,
        'icon': Icons.psychology_rounded,
        'description':
        'Activities for self-awareness and emotional growth.',
      },
      {
        'name': 'Team Engagement Guide',
        'category': 'Team Development',
        'price': 39.0,
        'icon': Icons.handshake_rounded,
        'description': 'Ideas for improving teamwork and engagement.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 34,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.deepBlue, Color(0xFF344C76)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.softYellow.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppTheme.softYellow,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your next step starts here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your shopping bag is waiting for something meaningful. '
                          'Explore resources designed to support learning and growth.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, height: 1.6),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Explore the Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.softYellow,
                        foregroundColor: AppTheme.deepBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 15,
                        ),
                        minimumSize: const Size(0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Explore our resources',
                  style: TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'A few ideas for your learning journey.',
                  style: TextStyle(color: AppTheme.greyText),
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 650 ? 3 : 2;
                  final cardWidth =
                      (constraints.maxWidth - (columns - 1) * 14) / columns;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: storeProducts.map((product) {
                      final price = (product['price'] as num).toDouble();
                      return SizedBox(
                        width: cardWidth,
                        child: _recommendationCard(product, price),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendationCard(Map<String, dynamic> product, double price) {
    final icon = product['icon'] as IconData? ?? Icons.auto_stories_rounded;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.deepBlue.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 68,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.purple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppTheme.purple, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              product['name'] as String? ?? 'Learning Resource',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'RM ${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.purple,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text(
                  'View resource',
                  style: TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppTheme.deepBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _productList(List<Map<String, dynamic>> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _productCard(items[i], i),
          if (i < items.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _productCard(Map<String, dynamic> item, int index) {
    final price = (item['price'] as num).toDouble();
    final quantity = item['quantity'] as int;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.deepBlue.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              item['icon'] as IconData? ?? Icons.shopping_bag_outlined,
              color: AppTheme.purple,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String? ?? 'Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'RM ${price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    _quantityButton(
                      icon: Icons.remove,
                      tooltip: 'Decrease quantity',
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) {
                            item['quantity'] = quantity - 1;
                          } else {
                            CartScreen.items.removeAt(index);
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add,
                      tooltip: 'Increase quantity',
                      onPressed: () {
                        setState(() {
                          item['quantity'] = quantity + 1;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => CartScreen.items.removeAt(index));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'RM ${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
    );
  }

  Widget _orderSummary() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.deepBlue.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow('Subtotal', total),
          const SizedBox(height: 12),
          _summaryRow('Discount', 0),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Shipping'), Text('Free')],
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'RM ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () async {
                final completed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(total: total),
                  ),
                );

                if (!mounted) return;
                if (completed == true) setState(() {});
              },
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _trustStrip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.softYellow.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: AppTheme.purple, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Invest in your next step. Explore resources that support '
                  'your learning and professional development.',
              style: TextStyle(
                color: AppTheme.deepBlue,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text('RM ${amount.toStringAsFixed(2)}'),
      ],
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final double total;

  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postcode = TextEditingController();
  final _country = TextEditingController(text: 'Malaysia');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _postcode.dispose();
    _country.dispose();
    super.dispose();
  }

  void _confirmOrder() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    CartScreen.items.clear();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Demo Order Confirmed'),
        content: Text(
          'Thank you, ${_name.text.trim()}.\n\n'
              'Demo total: RM ${widget.total.toStringAsFixed(2)}\n\n'
              'No payment was taken and no real order was submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.deepBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Order total: RM ${widget.total.toStringAsFixed(2)}'),
                    const SizedBox(height: 22),
                    _field(_name, 'Full name'),
                    _field(
                      _email,
                      'Email address',
                      keyboardType: TextInputType.emailAddress,
                      email: true,
                    ),
                    _field(
                      _phone,
                      'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Billing Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field(_address, 'Street address'),
                    _field(_city, 'City'),
                    _field(_state, 'State'),
                    _field(
                      _postcode,
                      'Postcode',
                      keyboardType: TextInputType.number,
                    ),
                    _field(_country, 'Country'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppTheme.softYellow.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Prototype only. Payment integration is not enabled.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          minimumSize: const Size(0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: const Text('Confirm Demo Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool email = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return '$label is required.';
          if (email &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
            return 'Enter a valid email address.';
          }
          return null;
        },
      ),
    );
  }
}
