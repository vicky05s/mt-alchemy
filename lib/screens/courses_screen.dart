import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: _appBar(context),
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
                    _header(desktop),
                    const SizedBox(height: 24),
                    _searchBar(),
                    const SizedBox(height: 18),
                    _categoryFilters(),
                    const SizedBox(height: 28),
                    _featuredCourse(context, desktop),
                    const SizedBox(height: 36),
                    _sectionHeader(),
                    const SizedBox(height: 18),
                    _courseGrid(context, desktop),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6F9),
      elevation: 0,
      titleSpacing: 24,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
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
          onPressed: () {},
          child: const Text('Learning Hub'),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _header(bool desktop) {
    return Container(
      padding: EdgeInsets.all(desktop ? 32 : 24),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: desktop
          ? Row(
        children: [
          Expanded(child: _headerText()),
          const SizedBox(width: 30),
          _headerIcon(),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerText(),
          const SizedBox(height: 22),
          _headerIcon(),
        ],
      ),
    );
  }

  Widget _headerText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppTheme.softYellow,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'LEARNING HUB',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Learn something\nthat moves you forward.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Explore practical learning experiences designed to turn insight into practice, behaviour and impact.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _headerIcon() {
    return Container(
      width: 145,
      height: 145,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.softYellow.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.purple.withValues(alpha: 0.28),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: AppTheme.softYellow,
            size: 45,
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search courses, skills or topics...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }

  Widget _categoryFilters() {
    final categories = [
      'All Courses',
      'Leadership',
      'People Skills',
      'Team Engagement',
      'Well-being',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
              (index) {
            final selected = index == 0;

            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.deepBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? AppTheme.deepBlue
                        : const Color(0xFFE4E0E9),
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppTheme.darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _featuredCourse(BuildContext context, bool desktop) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseDetailScreen(),
            ),
          );
        },
        child: Container(
          height: desktop ? 330 : 430,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepBlue.withValues(alpha: 0.15),
                blurRadius: 25,
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
                      AppTheme.deepBlue.withValues(alpha: 0.78),
                      AppTheme.deepBlue.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(desktop ? 30 : 24),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _smallPill('FEATURED COURSE'),
                        const SizedBox(height: 12),
                        const Text(
                          'Leadership\nDevelopment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 0.98,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Build confident leadership habits, communicate with clarity and create stronger teams.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _courseMeta(
                              Icons.menu_book_rounded,
                              '6 modules',
                            ),
                            const SizedBox(width: 16),
                            _courseMeta(
                              Icons.schedule_rounded,
                              'Self-paced',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore Course',
                                style: TextStyle(
                                  color: AppTheme.deepBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 7),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppTheme.deepBlue,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallPill(String text) {
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
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _courseMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 15,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORE LEARNING',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Develop what matters.',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Choose a learning experience that fits your development journey.',
          style: TextStyle(
            color: AppTheme.greyText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _courseGrid(BuildContext context, bool desktop) {
    final courses = [
      _CourseData(
        title: 'Emotional Intelligence',
        category: 'PEOPLE SKILLS',
        description:
        'Understand yourself, connect with others and lead with awareness.',
        image: 'assets/images/team_collaboration.png',
        accent: AppTheme.purple,
        modules: '5 modules',
      ),
      _CourseData(
        title: 'Leadership Development',
        category: 'LEADERSHIP',
        description:
        'Build practical leadership habits for real workplace situations.',
        image: 'assets/images/leadership_discussion.png',
        accent: AppTheme.deepBlue,
        modules: '6 modules',
      ),
      _CourseData(
        title: 'Team Engagement',
        category: 'TEAM DEVELOPMENT',
        description:
        'Create connected, motivated and collaborative teams.',
        image: 'assets/images/upskilling_workspace.png',
        accent: AppTheme.softYellow,
        modules: '4 modules',
        darkText: true,
      ),
      _CourseData(
        title: 'Workplace Well-being',
        category: 'WELL-BEING',
        description:
        'Build healthier habits and create a more supportive workplace.',
        image: 'assets/images/hero_office.png',
        accent: const Color(0xFF4C7A6B),
        modules: '4 modules',
      ),
    ];

    if (desktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: courses.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          return _courseCard(
            context,
            courses[index],
          );
        },
      );
    }

    return Column(
      children: courses
          .map(
            (course) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _courseCard(
            context,
            course,
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _courseCard(
      BuildContext context,
      _CourseData course,
      ) {
    final titleColor =
    course.darkText ? AppTheme.deepBlue : Colors.white;

    final descriptionColor = course.darkText
        ? AppTheme.deepBlue.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.78);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseDetailScreen(),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 285,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: course.accent,
            boxShadow: [
              BoxShadow(
                color: course.accent.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                course.image,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: course.darkText
                        ? [
                      Colors.transparent,
                      AppTheme.softYellow
                          .withValues(alpha: 0.92),
                    ]
                        : [
                      Colors.transparent,
                      course.accent
                          .withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: course.darkText
                            ? AppTheme.deepBlue
                            : Colors.white
                            .withValues(alpha: 0.16),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.category,
                        style: TextStyle(
                          color: course.darkText
                              ? Colors.white
                              : Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          course.modules,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: titleColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseData {
  final String title;
  final String category;
  final String description;
  final String image;
  final Color accent;
  final String modules;
  final bool darkText;

  const _CourseData({
    required this.title,
    required this.category,
    required this.description,
    required this.image,
    required this.accent,
    required this.modules,
    this.darkText = false,
  });
}