import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'courses_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.deepBlue,
        elevation: 0,
        title: const Text(
          'About MT Alchemy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO SECTION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlue,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'OUR STORY',
                            style: TextStyle(
                              color: AppTheme.deepBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Turning potential into progress.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'MT Alchemy is a learning and development platform '
                              'designed to support personal growth, stronger teams, '
                              'and workplace development.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 26),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CoursesScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school_outlined),
                          label: const Text('Explore Learning'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.softYellow,
                            foregroundColor: AppTheme.deepBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            minimumSize: const ui.Size(0,0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // INTRODUCTION
                  const Text(
                    'Who We Are',
                    style: TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We bring learning resources and development experiences '
                        'together in one place. Visitors can explore courses, '
                        'discover practical learning materials, and find resources '
                        'that support individual and organisational growth.',
                    style: TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // MISSION AND VISION
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 650;

                      final cards = [
                        _infoCard(
                          icon: Icons.flag_outlined,
                          title: 'Our Mission',
                          description:
                          'Make learning and development resources easier '
                              'to discover and use for personal and workplace growth.',
                          color: AppTheme.softYellow,
                        ),
                        _infoCard(
                          icon: Icons.visibility_outlined,
                          title: 'Our Vision',
                          description:
                          'Support a culture of continuous learning, '
                              'stronger teams, and meaningful development.',
                          color: const Color(0xFFE9E0F5),
                        ),
                      ];

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 18),
                            Expanded(child: cards[1]),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 18),
                          cards[1],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // VALUES
                  const Text(
                    'What We Value',
                    style: TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 750
                          ? 3
                          : constraints.maxWidth > 480
                          ? 2
                          : 1;

                      final values = [
                        _valueItem(
                          Icons.lightbulb_outline,
                          'Continuous Learning',
                          'Encouraging curiosity and ongoing improvement.',
                        ),
                        _valueItem(
                          Icons.groups_outlined,
                          'Collaboration',
                          'Helping people and teams grow together.',
                        ),
                        _valueItem(
                          Icons.trending_up,
                          'Practical Growth',
                          'Connecting learning with everyday progress.',
                        ),
                      ];

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: columns == 1 ? 2.3 : 1.05,
                        children: values,
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // LEARNING JOURNEY
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A Better Learning Journey',
                          style: TextStyle(
                            color: AppTheme.deepBlue,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _journeyStep(
                          '01',
                          'Discover',
                          'Explore courses and learning resources.',
                        ),
                        _journeyStep(
                          '02',
                          'Develop',
                          'Build knowledge through structured learning.',
                        ),
                        _journeyStep(
                          '03',
                          'Apply',
                          'Use what you learn in real-world situations.',
                        ),
                        _journeyStep(
                          '04',
                          'Grow',
                          'Continue developing your skills and potential.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // BOTTOM CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E0F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 18,
                      spacing: 20,
                      children: [
                        const SizedBox(
                          width: 420,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ready to take the next step?',
                                style: TextStyle(
                                  color: AppTheme.deepBlue,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Explore learning opportunities and start '
                                    'building your skills.',
                                style: TextStyle(height: 1.6),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CoursesScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            minimumSize: const ui.Size(0,0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Browse Courses'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.deepBlue, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.greyText,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: AppTheme.purple),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.greyText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeyStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.softYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.deepBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}