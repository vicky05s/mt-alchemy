import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Flat shipping fee (RM) charged when an order has a physical product.
/// PLACEHOLDER: replace with the real shipping rules.
const double kShippingFee = 10.0;

const Map<String, IconData> _icons = {
  'groups': Icons.groups_rounded,
  'psychology': Icons.psychology_rounded,
  'handshake': Icons.handshake_rounded,
  'book': Icons.menu_book_rounded,
  'video': Icons.play_circle_outline_rounded,
  'cards': Icons.style_rounded,
  'kit': Icons.inventory_2_rounded,
};

class Product {
  final String id;
  final String name;
  final String category;
  final String type; // Digital | Physical
  final double price;
  final String description;
  final String iconKey;
  final String status; // draft | published | archived
  final int stock; // physical only
  final double weightKg; // physical only
  final String accessInstructions; // digital only
  final String fileName; // digital only (the file the buyer downloads)

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.price,
    required this.description,
    this.iconKey = 'book',
    this.status = 'published',
    this.stock = 0,
    this.weightKg = 0,
    this.accessInstructions = '',
    this.fileName = '',
  });

  bool get isDigital => type == 'Digital';
  bool get isPhysical => type == 'Physical';
  bool get inStock => isDigital || stock > 0;
  IconData get icon => _icons[iconKey] ?? Icons.auto_stories_rounded;

  String get availability => isDigital
      ? 'Available instantly'
      : (stock > 5
          ? 'In stock'
          : (stock > 0 ? 'Only $stock left' : 'Out of stock'));

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Product(
      id: doc.id,
      name: (d['name'] ?? '') as String,
      category: (d['category'] ?? '') as String,
      type: (d['type'] ?? 'Digital') as String,
      price: ((d['price'] ?? 0) as num).toDouble(),
      description: (d['description'] ?? '') as String,
      iconKey: (d['iconKey'] ?? 'book') as String,
      status: (d['status'] ?? 'draft') as String,
      stock: ((d['stock'] ?? 0) as num).toInt(),
      weightKg: ((d['weightKg'] ?? 0) as num).toDouble(),
      accessInstructions: (d['accessInstructions'] ?? '') as String,
      fileName: (d['fileName'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'type': type,
        'price': price,
        'description': description,
        'iconKey': iconKey,
        'status': status,
        'stock': stock,
        'weightKg': weightKg,
        'accessInstructions': accessInstructions,
        'fileName': fileName,
      };
}

/// Sample products so the store has content on day one.
/// PLACEHOLDERS: replace names, prices and descriptions with MT Alchemy's real range.
List<Product> sampleProducts() => const [
      Product(
        id: 'leadership-toolkit',
        name: 'Leadership Toolkit',
        category: 'Leadership',
        type: 'Physical',
        price: 49,
        description:
            'Practical resources to strengthen leadership skills and workplace conversations.',
        iconKey: 'groups',
        stock: 25,
        weightKg: 0.6,
      ),
      Product(
        id: 'ei-workbook',
        name: 'Emotional Intelligence Workbook',
        category: 'Personal Growth',
        type: 'Digital',
        price: 29,
        description:
            'Reflective exercises to build self-awareness and improve relationships.',
        iconKey: 'psychology',
        accessInstructions:
            'Open My Digital Products after purchase and tap Download. Print it or fill it in on screen.',
        fileName: 'Emotional-Intelligence-Workbook.pdf',
      ),
      Product(
        id: 'team-engagement-guide',
        name: 'Team Engagement Guide',
        category: 'Team Development',
        type: 'Digital',
        price: 39,
        description:
            'Ideas and activities to support communication and collaboration in teams.',
        iconKey: 'handshake',
        accessInstructions:
            'Open My Digital Products after purchase and tap Download.',
        fileName: 'Team-Engagement-Guide.pdf',
      ),
      Product(
        id: 'growth-journal',
        name: 'Personal Growth Journal',
        category: 'Personal Growth',
        type: 'Physical',
        price: 19,
        description:
            'A guided journal for reflection, learning goals, and personal development.',
        iconKey: 'book',
        stock: 40,
        weightKg: 0.35,
      ),
      Product(
        id: 'eq-workshop-recording',
        name: 'Leading with EQ: Workshop Recording',
        category: 'Leadership',
        type: 'Digital',
        price: 59,
        description:
            'A recorded workshop on leading with emotional intelligence, available to download.',
        iconKey: 'video',
        accessInstructions:
            'Open My Digital Products after purchase and tap Download.',
        fileName: 'Leading-with-EQ-Workshop.pdf',
      ),
      Product(
        id: 'mindfulness-cards',
        name: 'Mindfulness Card Deck',
        category: 'Personal Growth',
        type: 'Physical',
        price: 35,
        description:
            'A printed deck of prompts for daily mindfulness and team check-ins.',
        iconKey: 'cards',
        stock: 3,
        weightKg: 0.25,
      ),
      Product(
        id: 'team-learning-kit',
        name: 'Team Learning Kit',
        category: 'Team Development',
        type: 'Physical',
        price: 129,
        description:
            'Printed workshop materials and activity cards for running a team session.',
        iconKey: 'kit',
        stock: 12,
        weightKg: 1.8,
      ),
    ];
