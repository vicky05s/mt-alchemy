
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class StoreScreen extends StatefulWidget {
const StoreScreen({super.key});

@override
State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
final TextEditingController _searchController =
TextEditingController();

String _selectedCategory = 'All';

final List<Map<String, dynamic>> _products = [
{
'name': 'Leadership Toolkit',
'category': 'Leadership',
'price': 49.00,
'description':
'Practical resources to strengthen leadership skills and workplace conversations.',
'icon': Icons.groups_rounded,
},
{
'name': 'Emotional Intelligence Workbook',
'category': 'Personal Growth',
'price': 29.00,
'description':
'Reflective exercises to build self-awareness and improve relationships.',
'icon': Icons.psychology_rounded,
},
{
'name': 'Team Engagement Guide',
'category': 'Team Development',
'price': 39.00,
'description':
'Ideas and activities to support communication and collaboration in teams.',
'icon': Icons.handshake_rounded,
},
{
'name': 'Personal Growth Journal',
'category': 'Personal Growth',
'price': 19.00,
'description':
'A guided journal for reflection, learning goals, and personal development.',
'icon': Icons.menu_book_rounded,
},
];

List<Map<String, dynamic>> get _filteredProducts {
final query = _searchController.text.toLowerCase().trim();

return _products.where((product) {
final matchesSearch =
product['name'].toString().toLowerCase().contains(query) ||
product['description']
    .toString()
    .toLowerCase()
    .contains(query);

final matchesCategory = _selectedCategory == 'All' ||
product['category'] == _selectedCategory;

return matchesSearch && matchesCategory;
}).toList();
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final products = _filteredProducts;

return Scaffold(
backgroundColor: AppTheme.background,
appBar: AppBar(
title: const Text(
'MT Alchemy Store',
style: TextStyle(fontWeight: FontWeight.w800),
),
backgroundColor: AppTheme.background,
foregroundColor: AppTheme.deepBlue,
actions: [
IconButton(
tooltip: 'Shopping Cart',
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CartScreen(),
),
);
},
icon: const Icon(Icons.shopping_bag_outlined),
),
const SizedBox(width: 8),
],
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1100),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
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
'Explore practical resources for leadership, '
'personal growth and team development.',
style: TextStyle(
color: Colors.white70,
height: 1.5,
),
),
],
),
),
const SizedBox(height: 26),
TextField(
controller: _searchController,
onChanged: (_) => setState(() {}),
decoration: InputDecoration(
hintText: 'Search resources...',
prefixIcon: const Icon(Icons.search),
suffixIcon: _searchController.text.isEmpty
? null
    : IconButton(
onPressed: () {
_searchController.clear();
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
children: [
'All',
'Leadership',
'Personal Growth',
'Team Development',
].map((category) {
final selected = _selectedCategory == category;

return ChoiceChip(
label: Text(category),
selected: selected,
selectedColor: AppTheme.softYellow,
onSelected: (_) {
setState(() {
_selectedCategory = category;
});
},
);
}).toList(),
),
const SizedBox(height: 24),
Text(
'${products.length} resources',
style: const TextStyle(
color: AppTheme.deepBlue,
fontSize: 21,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 16),
if (products.isEmpty)
const Padding(
padding: EdgeInsets.all(30),
child: Center(
child: Text(
'No resources found. Try another search.',
),
),
)
else
LayoutBuilder(
builder: (context, constraints) {
final columns =
constraints.maxWidth >= 850
? 3
    : constraints.maxWidth >= 540
? 2
    : 1;

return GridView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: products.length,
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: columns,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
mainAxisExtent: 285,
),
itemBuilder: (context, index) {
final product = products[index];

return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(22),
border: Border.all(
color: const Color(0xFFE4E0E9),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
height: 62,
width: 62,
decoration: BoxDecoration(
color: AppTheme.purple
    .withValues(alpha: 0.10),
borderRadius:
BorderRadius.circular(18),
),
child: Icon(
product['icon'] as IconData,
color: AppTheme.purple,
size: 30,
),
),
const SizedBox(height: 14),
Text(
product['category'] as String,
style: const TextStyle(
color: AppTheme.purple,
fontSize: 12,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 6),
Text(
product['name'] as String,
style: const TextStyle(
color: AppTheme.deepBlue,
fontSize: 17,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 6),
Expanded(
child: Text(
product['description'] as String,
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
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
Text(
'RM ${(product['price'] as double).toStringAsFixed(2)}',
style: const TextStyle(
color: AppTheme.deepBlue,
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
IconButton.filled(
tooltip: 'View product',
style: IconButton.styleFrom(
backgroundColor:
AppTheme.deepBlue,
foregroundColor: Colors.white,
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
ProductDetailScreen(
product: product,
),
),
);
},
icon: const Icon(
Icons.arrow_forward_rounded,
),
),
],
),
],
),
);
},
);
},
),
],
),
),
),
),
),
);
}
}
