import 'package:flutter/foundation.dart';

import 'product_models.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem(this.product, this.quantity);

  double get lineTotal => product.price * quantity;
}

/// The shopping cart. Lives in memory for the whole app session, so guests can
/// fill it before signing in. Replaces the old static list in CartScreen.
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  /// Total number of units (used for the header badge).
  int get count => _items.values.fold(0, (sum, i) => sum + i.quantity);

  bool get hasPhysical => _items.values.any((i) => i.product.isPhysical);
  bool get hasDigital => _items.values.any((i) => i.product.isDigital);
  bool get digitalOnly => hasDigital && !hasPhysical;

  double get subtotal => _items.values.fold(0.0, (sum, i) => sum + i.lineTotal);
  double get discount => 0; // no promo codes yet
  double get shipping => hasPhysical ? kShippingFee : 0;
  double get total => subtotal - discount + shipping;

  bool contains(String productId) => _items.containsKey(productId);

  /// Adds a product. Returns a message if it could not be added.
  String? add(Product p, {int quantity = 1}) {
    if (!p.inStock) return '${p.name} is out of stock.';
    final existing = _items[p.id];

    if (p.isDigital) {
      // A digital product is bought once.
      if (existing != null) return '${p.name} is already in your cart.';
      _items[p.id] = CartItem(p, 1);
    } else {
      final next = (existing?.quantity ?? 0) + quantity;
      if (next > p.stock) {
        return 'Only ${p.stock} of ${p.name} available.';
      }
      if (existing != null) {
        existing.quantity = next;
      } else {
        _items[p.id] = CartItem(p, quantity);
      }
    }
    notifyListeners();
    return null;
  }

  void setQuantity(String productId, int quantity) {
    final item = _items[productId];
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else if (item.product.isPhysical && quantity <= item.product.stock) {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
