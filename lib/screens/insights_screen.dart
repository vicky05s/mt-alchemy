import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final articles = [
      ('01', 'The value of continuous learning', 'Small, consistent learning habits can help people keep developing their skills.', Icons.auto_stories_outlined),
      ('02', 'Building stronger teams', 'Trust, communication and shared goals help teams work together more effectively.', Icons.groups_outlined),
      ('03', 'Turning insight into action', 'Reflection becomes more useful when it leads to practical changes in everyday work.', Icons.lightbulb_outline),
    ];
    return Scaffold(appBar: AppBar(title: const Text('Insights')), body: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppTheme.deepBlue, borderRadius: BorderRadius.circular(26)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('IDEAS FOR GROWTH', style: TextStyle(color: AppTheme.softYellow, fontWeight: FontWeight.bold, letterSpacing: 1.4)), SizedBox(height: 14), Text('Ideas to inspire your next step.', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)), SizedBox(height: 12), Text('Explore perspectives on learning, leadership and workplace development.', style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 16))])), const SizedBox(height: 28), const Text('Featured topics', style: TextStyle(fontSize: 26, color: AppTheme.deepBlue, fontWeight: FontWeight.bold)), const SizedBox(height: 16), ...articles.map((a) => Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFE9E0F5), borderRadius: BorderRadius.circular(14)), child: Icon(a.$4, color: AppTheme.purple)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('INSIGHT ${a.$1}', style: const TextStyle(color: AppTheme.purple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)), const SizedBox(height: 6), Text(a.$2, style: const TextStyle(fontSize: 19, color: AppTheme.deepBlue, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(a.$3, style: const TextStyle(color: AppTheme.greyText, height: 1.5))]))]))), const SizedBox(height: 12), const Text('Prototype content', style: TextStyle(color: AppTheme.greyText, fontSize: 12))])))));
  }
}
