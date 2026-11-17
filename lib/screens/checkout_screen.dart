import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../auth/auth_widgets.dart' show Validators;
import '../learning/payment_dialog.dart';
import '../store/cart_provider.dart';
import '../store/store_service.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

/// Checkout: customer, billing, shipping (physical items only) and a
/// SIMULATED payment that returns Successful / Failed / Pending.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

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

  final _shipAddress = TextEditingController();
  final _shipCity = TextEditingController();
  final _shipState = TextEditingController();
  final _shipPostcode = TextEditingController();
  final _shipCountry = TextEditingController(text: 'Malaysia');

  bool _sameAsBilling = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _name.text = user.name;
      _email.text = user.email;
      _phone.text = '${user.extra['phone'] ?? ''}';
      final country = user.extra['country'];
      if (country is String && country.isNotEmpty) {
        _country.text = country;
        _shipCountry.text = country;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _email, _phone, _address, _city, _state, _postcode, _country,
      _shipAddress, _shipCity, _shipState, _shipPostcode, _shipCountry,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _billing() => {
        'address': _address.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'postcode': _postcode.text.trim(),
        'country': _country.text.trim(),
      };

  Map<String, dynamic> _shipping() => _sameAsBilling
      ? _billing()
      : {
          'address': _shipAddress.text.trim(),
          'city': _shipCity.text.trim(),
          'state': _shipState.text.trim(),
          'postcode': _shipPostcode.text.trim(),
          'country': _shipCountry.text.trim(),
        };

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid;
    if (uid == null || cart.isEmpty) return;

    final result = await showSimulatedPayment(
      context,
      title: 'MT Alchemy order (${cart.count} items)',
      amount: cart.total,
    );
    if (!mounted) return;

    switch (result) {
      case PaymentResult.cancelled:
        return;
      case PaymentResult.failed:
        setState(() => _error =
            'Payment failed. You have not been charged and your cart is kept. Please try again.');
        return;
      case PaymentResult.successful:
      case PaymentResult.pending:
        break;
    }

    setState(() => _busy = true);
    try {
      final orderId = await StoreService.instance.createOrder(
        uid: uid,
        cart: cart,
        customer: {
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
        },
        billing: _billing(),
        shipping: cart.hasPhysical ? _shipping() : null,
        paymentStatus:
            result == PaymentResult.successful ? 'successful' : 'pending',
      );
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(orderId: orderId)),
      );
    } catch (e) {
      debugPrint('Create order failed: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'We could not place your order. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.deepBlue,
      ),
      body: cart.isEmpty && !_busy
          ? const Center(child: Text('Your cart is empty.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _form(cart)),
                            const SizedBox(width: 24),
                            SizedBox(width: 340, child: _summary(cart)),
                          ],
                        )
                      : Column(
                          children: [
                            _summary(cart),
                            const SizedBox(height: 20),
                            _form(cart),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.deepBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
        ),
        validator: validator ?? (v) => Validators.required(v, label),
      ),
    );
  }

  Widget _pairRow(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 420) return Column(children: [a, b]);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 14),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  Widget _addressFields({
    required TextEditingController address,
    required TextEditingController city,
    required TextEditingController state,
    required TextEditingController postcode,
    required TextEditingController country,
  }) {
    return Column(
      children: [
        _field(address, 'Address'),
        _pairRow(_field(city, 'City'), _field(state, 'State')),
        _pairRow(
          _field(postcode, 'Postcode', keyboard: TextInputType.number),
          _field(country, 'Country'),
        ),
      ],
    );
  }

  Widget _form(CartProvider cart) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card('Customer information', [
            _field(_name, 'Full name'),
            _pairRow(
              _field(_email, 'Email',
                  keyboard: TextInputType.emailAddress,
                  validator: Validators.email),
              _field(_phone, 'Phone',
                  keyboard: TextInputType.phone, validator: Validators.phone),
            ),
          ]),
          _card('Billing address', [
            _addressFields(
              address: _address,
              city: _city,
              state: _state,
              postcode: _postcode,
              country: _country,
            ),
          ]),
          if (cart.hasPhysical)
            _card('Shipping address', [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _sameAsBilling,
                activeThumbColor: AppTheme.deepBlue,
                title: const Text('Same as billing address'),
                onChanged: (v) => setState(() => _sameAsBilling = v),
              ),
              if (!_sameAsBilling) ...[
                const SizedBox(height: 10),
                _addressFields(
                  address: _shipAddress,
                  city: _shipCity,
                  state: _shipState,
                  postcode: _shipPostcode,
                  country: _shipCountry,
                ),
              ],
            ]),
          _card('Payment', [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.softYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Demo checkout: no real payment is taken. You will choose an '
                'outcome (successful, failed or pending). A real payment '
                'gateway replaces this at launch.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDA29B)),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: Color(0xFFB42318))),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _pay,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_outline, size: 18),
                label: Text(_busy ? 'Placing order…' : 'Pay ${money(cart.total)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _summary(CartProvider cart) {
    Widget row(String l, String v, {bool bold = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
          const Text('Order summary',
              style: TextStyle(
                  color: AppTheme.deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          for (final i in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${i.quantity} × ${i.product.name}',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Text(money(i.lineTotal)),
                ],
              ),
            ),
          const Divider(height: 24),
          row('Subtotal', money(cart.subtotal)),
          row('Discount', money(cart.discount)),
          row('Shipping',
              cart.hasPhysical ? money(cart.shipping) : 'Free (digital only)'),
          const Divider(height: 24),
          row('Total', money(cart.total), bold: true),
        ],
      ),
    );
  }
}
