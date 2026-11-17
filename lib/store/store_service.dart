import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_provider.dart';
import 'product_models.dart';

/// Order status flow (brief 4.33):
///   physical: Pending -> Paid -> Processing -> Shipped -> Delivered
///   digital:  Pending -> Paid -> Available
const physicalFlow = ['Pending', 'Paid', 'Processing', 'Shipped', 'Delivered'];
const digitalFlow = ['Pending', 'Paid', 'Available'];

class OrderLine {
  final String productId;
  final String name;
  final String type;
  final double price;
  final int quantity;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.type,
    required this.price,
    required this.quantity,
  });

  factory OrderLine.fromMap(Map<String, dynamic> m) => OrderLine(
        productId: (m['productId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? 'Digital') as String,
        price: ((m['price'] ?? 0) as num).toDouble(),
        quantity: ((m['quantity'] ?? 1) as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'type': type,
        'price': price,
        'quantity': quantity,
      };
}

class OrderRecord {
  final String id;
  final String uid;
  final String orderNumber;
  final List<OrderLine> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String paymentStatus; // successful | pending | failed
  final String status; // see flows above
  final bool hasPhysical;
  final bool hasDigital;
  final Map<String, dynamic> customer;
  final Map<String, dynamic> billing;
  final Map<String, dynamic> shipping;
  final DateTime createdAt;

  const OrderRecord({
    required this.id,
    required this.uid,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.paymentStatus,
    required this.status,
    required this.hasPhysical,
    required this.hasDigital,
    required this.customer,
    required this.billing,
    required this.shipping,
    required this.createdAt,
  });

  bool get digitalOnly => hasDigital && !hasPhysical;
  List<String> get flow => digitalOnly ? digitalFlow : physicalFlow;

  /// The next status an admin can move this order to (null at the end).
  String? get nextStatus {
    final i = flow.indexOf(status);
    if (i < 0 || i >= flow.length - 1) return null;
    return flow[i + 1];
  }

  factory OrderRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    Map<String, dynamic> map(dynamic v) =>
        v == null ? <String, dynamic>{} : Map<String, dynamic>.from(v as Map);
    return OrderRecord(
      id: doc.id,
      uid: (d['uid'] ?? '') as String,
      orderNumber: (d['orderNumber'] ?? '') as String,
      items: ((d['items'] ?? const []) as List)
          .map((i) => OrderLine.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList(),
      subtotal: ((d['subtotal'] ?? 0) as num).toDouble(),
      discount: ((d['discount'] ?? 0) as num).toDouble(),
      shippingFee: ((d['shippingFee'] ?? 0) as num).toDouble(),
      total: ((d['total'] ?? 0) as num).toDouble(),
      paymentStatus: (d['paymentStatus'] ?? 'pending') as String,
      status: (d['status'] ?? 'Pending') as String,
      hasPhysical: (d['hasPhysical'] ?? false) as bool,
      hasDigital: (d['hasDigital'] ?? false) as bool,
      customer: map(d['customer']),
      billing: map(d['billing']),
      shipping: map(d['shipping']),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// A purchased digital product the learner may download.
class DigitalEntitlement {
  final String id;
  final String productId;
  final String productName;
  final String fileName;
  final String orderNumber;
  final String accessInstructions;
  final DateTime purchasedAt;

  const DigitalEntitlement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.fileName,
    required this.orderNumber,
    required this.accessInstructions,
    required this.purchasedAt,
  });

  factory DigitalEntitlement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return DigitalEntitlement(
      id: doc.id,
      productId: (d['productId'] ?? '') as String,
      productName: (d['productName'] ?? '') as String,
      fileName: (d['fileName'] ?? '') as String,
      orderNumber: (d['orderNumber'] ?? '') as String,
      accessInstructions: (d['accessInstructions'] ?? '') as String,
      purchasedAt: (d['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// All Firestore access for the store, orders and the digital library.
class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _downloads =>
      _db.collection('downloads');

  // ---------------------------------------------------------------- products
  Stream<List<Product>> publishedProducts() {
    return _products
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((s) {
      final list = s.docs.map(Product.fromDoc).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  /// Admin only (enforced by the Firestore rules). Safe to run twice.
  Future<void> loadSampleProducts() async {
    final batch = _db.batch();
    for (final p in sampleProducts()) {
      batch.set(_products.doc(p.id), p.toMap());
    }
    await batch.commit();
  }

  // ------------------------------------------------------------------ orders
  String _orderNumber() {
    final now = DateTime.now();
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final rnd = Random.secure().nextInt(9000) + 1000;
    return 'MA-$yy$mm$dd-$rnd';
  }

  /// Creates the order. [paymentStatus] is 'successful' or 'pending'.
  /// Successful payments also unlock the digital products in the library.
  Future<String> createOrder({
    required String uid,
    required CartProvider cart,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> billing,
    required Map<String, dynamic>? shipping,
    required String paymentStatus,
  }) async {
    final ref = _orders.doc();
    final number = _orderNumber();
    final paid = paymentStatus == 'successful';
    final status = paid ? (cart.digitalOnly ? 'Available' : 'Paid') : 'Pending';
    final items = cart.items;

    await ref.set({
      'uid': uid,
      'orderNumber': number,
      'items': items
          .map((i) => OrderLine(
                productId: i.product.id,
                name: i.product.name,
                type: i.product.type,
                price: i.product.price,
                quantity: i.quantity,
              ).toMap())
          .toList(),
      'subtotal': cart.subtotal,
      'discount': cart.discount,
      'shippingFee': cart.shipping,
      'total': cart.total,
      'paymentStatus': paymentStatus,
      'payment': {
        'provider': 'simulated',
        'reference': 'SIM-${DateTime.now().millisecondsSinceEpoch}',
        'status': paymentStatus,
      },
      'status': status,
      'hasPhysical': cart.hasPhysical,
      'hasDigital': cart.hasDigital,
      'customer': customer,
      'billing': billing,
      'shipping': shipping ?? <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (paid) {
      await _grantDigital(
        orderId: ref.id,
        orderNumber: number,
        uid: uid,
        products: items.map((i) => i.product).toList(),
      );
    }
    return ref.id;
  }

  Future<void> _grantDigital({
    required String orderId,
    required String orderNumber,
    required String uid,
    required List<Product> products,
  }) async {
    final digital = products.where((p) => p.isDigital).toList();
    if (digital.isEmpty) return;
    final batch = _db.batch();
    for (final p in digital) {
      batch.set(_downloads.doc('${uid}_${p.id}'), {
        'uid': uid,
        'productId': p.id,
        'productName': p.name,
        'fileName': p.fileName,
        'accessInstructions': p.accessInstructions,
        'orderId': orderId,
        'orderNumber': orderNumber,
        'purchasedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Stream<OrderRecord?> order(String id) => _orders
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? OrderRecord.fromDoc(d) : null);

  Stream<List<OrderRecord>> ordersForUser(String uid) {
    return _orders.where('uid', isEqualTo: uid).snapshots().map((s) {
      final list = s.docs.map(OrderRecord.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Staff only: every order, newest first.
  Stream<List<OrderRecord>> allOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(OrderRecord.fromDoc).toList());
  }

  /// Staff: move an order to its next status.
  Future<void> advanceOrder(OrderRecord order) async {
    final next = order.nextStatus;
    if (next == null) return;
    await _orders.doc(order.id).update({'status': next});
  }

  /// Staff: a pending payment was received. Marks it paid and unlocks
  /// any digital products for the buyer.
  Future<void> markPaymentReceived(OrderRecord order) async {
    final status = order.digitalOnly ? 'Available' : 'Paid';
    await _orders.doc(order.id).update({
      'paymentStatus': 'successful',
      'payment.status': 'successful',
      'status': status,
    });
    if (order.hasDigital) {
      final batch = _db.batch();
      for (final line in order.items.where((l) => l.type == 'Digital')) {
        final p = await _products.doc(line.productId).get();
        final data = p.data() ?? <String, dynamic>{};
        batch.set(_downloads.doc('${order.uid}_${line.productId}'), {
          'uid': order.uid,
          'productId': line.productId,
          'productName': line.name,
          'fileName': (data['fileName'] ?? '') as String,
          'accessInstructions': (data['accessInstructions'] ?? '') as String,
          'orderId': order.id,
          'orderNumber': order.orderNumber,
          'purchasedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  // --------------------------------------------------------- digital library
  Stream<List<DigitalEntitlement>> libraryFor(String uid) {
    return _downloads.where('uid', isEqualTo: uid).snapshots().map((s) {
      final list = s.docs.map(DigitalEntitlement.fromDoc).toList();
      list.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
      return list;
    });
  }

  /// Re-checks on the server that this user really bought the product
  /// before a file is released.
  Future<bool> hasPurchased(String uid, String productId) async {
    final snap = await _downloads
        .doc('${uid}_$productId')
        .get(const GetOptions(source: Source.server));
    return snap.exists && snap.data()?['uid'] == uid;
  }
}
