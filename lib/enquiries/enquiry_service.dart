import 'package:cloud_firestore/cloud_firestore.dart';

/// Journey E pipeline, in order.
const enquiryStatuses = <(String, String)>[
  ('new', 'New'),
  ('contacted', 'Contacted'),
  ('consultation', 'Consultation'),
  ('proposal', 'Customised proposal'),
  ('won', 'Purchased / enrolled'),
  ('closed', 'Closed'),
];

String enquiryStatusLabel(String key) {
  for (final s in enquiryStatuses) {
    if (s.$1 == key) return s.$2;
  }
  return key;
}

class EnquiryRecord {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String organisation;
  final String enquiryType;
  final String service;
  final String source;
  final String message;
  final String status;
  final String notes;
  final String uid;
  final DateTime createdAt;

  const EnquiryRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.organisation,
    required this.enquiryType,
    required this.service,
    required this.source,
    required this.message,
    required this.status,
    required this.notes,
    required this.uid,
    required this.createdAt,
  });

  factory EnquiryRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    String s(String k) => (d[k] ?? '') as String;
    return EnquiryRecord(
      id: doc.id,
      name: s('name'),
      email: s('email'),
      phone: s('phone'),
      organisation: s('organisation'),
      enquiryType: s('enquiryType'),
      service: s('service'),
      source: s('source'),
      message: s('message'),
      status: s('status').isEmpty ? 'new' : s('status'),
      notes: s('notes'),
      uid: s('uid'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class EnquiryService {
  EnquiryService._();
  static final EnquiryService instance = EnquiryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('enquiries');

  /// Staff: every enquiry, newest first.
  Stream<List<EnquiryRecord>> all() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(EnquiryRecord.fromDoc).toList());
  }

  /// A signed-in customer's own enquiries.
  Stream<List<EnquiryRecord>> mine(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map((s) {
      final list = s.docs.map(EnquiryRecord.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> update(String id, {required String status, required String notes}) {
    return _col.doc(id).update({
      'status': status,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
