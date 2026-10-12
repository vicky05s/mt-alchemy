import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'courses_screen.dart';
import 'store_screen.dart';
import 'corporate_screen.dart';
import 'contact_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _hero(),
              const SizedBox(height: 28),
              const Text('Ways we support growth', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppTheme.deepBlue)),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, c) {
                final count = c.maxWidth > 760 ? 3 : c.maxWidth > 500 ? 2 : 1;
                final items = [
                  _ServiceData(Icons.school_outlined, 'Learning & Development', 'Explore learning paths and practical courses.', () => _go(context, const CoursesScreen())),
                  _ServiceData(Icons.groups_outlined, 'Corporate Learning', 'Plan employee learning and team development.', () => _go(context, const CorporateScreen())),
                  _ServiceData(Icons.menu_book_outlined, 'Learning Resources', 'Browse workbooks, guides and digital resources.', () => _go(context, const StoreScreen())),
                ];
                return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: count, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: count == 1 ? 2.0 : 1.05, children: items.map((e) => _serviceCard(context, e)).toList());
              }),
              const SizedBox(height: 26),
              Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFE9E0F5), borderRadius: BorderRadius.circular(22)), child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 18, runSpacing: 14, children: [const SizedBox(width: 430, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Need help choosing?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.deepBlue)), SizedBox(height: 7), Text('Tell us what you or your organisation would like to develop.') ])), _compactButton('Contact Us', () => _go(context, const ContactScreen()))])),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _hero() => Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppTheme.deepBlue, borderRadius: BorderRadius.circular(26)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MT ALCHEMY SERVICES', style: TextStyle(color: AppTheme.softYellow, letterSpacing: 1.5, fontWeight: FontWeight.bold)), SizedBox(height: 14), Text('Learning that moves people forward.', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.15)), SizedBox(height: 12), Text('Discover learning experiences and resources for individuals, teams and organisations.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6))]));
  Widget _serviceCard(BuildContext context, _ServiceData data) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(data.icon, size: 32, color: AppTheme.purple), const SizedBox(height: 14), Text(data.title, style: const TextStyle(color: AppTheme.deepBlue, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(data.description, style: const TextStyle(color: AppTheme.greyText, height: 1.5)), const SizedBox(height: 14), Align(alignment: Alignment.centerLeft, child: _compactButton('Explore', data.onTap))]));
  Widget _compactButton(String text, VoidCallback action) => ElevatedButton(onPressed: action, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.deepBlue, foregroundColor: Colors.white, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12)), child: Text(text));
  void _go(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}
class _ServiceData { final IconData icon; final String title; final String description; final VoidCallback onTap; _ServiceData(this.icon, this.title, this.description, this.onTap); }
