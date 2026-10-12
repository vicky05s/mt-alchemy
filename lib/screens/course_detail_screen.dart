import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'course_player_screen.dart';


class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F9),
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.softYellow,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'MT Alchemy',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Learning'),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 48 : 18,
              vertical: 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _courseHero(context, desktop),
                    const SizedBox(height: 24),
                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _courseContent()),
                          const SizedBox(width: 22),
                          SizedBox(
                            width: 340,
                            child: _enrolCard(context),
                          ),
                        ],
                      )
                    else ...[
                      _enrolCard(context),
                      const SizedBox(height: 24),
                      _courseContent(),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _courseHero(BuildContext context, bool desktop) {
    return Container(
      height: desktop ? 350 : 430,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/leadership_discussion.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.deepBlue.withValues(alpha: 0.98),
                  AppTheme.deepBlue.withValues(alpha: 0.80),
                  AppTheme.deepBlue.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(desktop ? 34 : 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pill('LEADERSHIP  •  6 MODULES'),
                    const SizedBox(height: 14),
                    Text(
                      'Leadership\nDevelopment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: desktop ? 42 : 34,
                        height: 0.98,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Build confident leadership habits, communicate with clarity and create stronger teams.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABOUT THIS COURSE',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Turn leadership knowledge into everyday behaviour.',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This learning experience helps participants strengthen leadership awareness, communication and decision-making through practical activities and reflection.',
          style: TextStyle(
            color: AppTheme.greyText,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        _learningOutcomes(),
        const SizedBox(height: 28),
        const Text(
          'COURSE CONTENT',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _module('01', 'Understanding Your Leadership Style', '4 lessons'),
        _module('02', 'Communication & Influence', '5 lessons'),
        _module('03', 'Leading Difficult Conversations', '4 lessons'),
        _module('04', 'Building High-Trust Teams', '5 lessons'),
        _module('05', 'Decision Making & Accountability', '4 lessons'),
        _module('06', 'From Insight to Impact', '3 lessons'),
      ],
    );
  }

  Widget _learningOutcomes() {
    final outcomes = [
      'Recognise your leadership strengths and development areas.',
      'Communicate with greater clarity, empathy and confidence.',
      'Apply practical leadership behaviours in workplace situations.',
      'Build stronger relationships and more engaged teams.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT YOU WILL DEVELOP',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...outcomes.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppTheme.purple,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _module(String number, String title, String lessons) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 3,
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.deepBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          lessons,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 10,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.greyText,
        ),
      ),
    );
  }

  Widget _enrolCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE4E0E9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR NEXT STEP',
            style: TextStyle(
              color: AppTheme.purple,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Start your leadership journey.',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 20,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 17),
          _infoRow(Icons.schedule_rounded, 'Self-paced learning'),
          _infoRow(Icons.menu_book_rounded, '6 learning modules'),
          _infoRow(Icons.quiz_outlined, 'Assessments included'),
          _infoRow(Icons.workspace_premium_outlined, 'Certificate on completion'),
          const SizedBox(height: 18),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoursePlayerScreen(),
                  ),
                );
              },
            child: const Text('Enrol in Course'),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'Prototype action • No payment required yet',
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.purple,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.greyText,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.softYellow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.deepBlue,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
