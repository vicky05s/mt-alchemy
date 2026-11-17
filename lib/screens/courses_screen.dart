import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'course_detail_screen.dart';

/// Learning Hub: lists published courses from Firestore.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  static const _categories = [
    'All Courses',
    'Leadership',
    'People Skills',
    'Team Engagement',
    'Well-being',
  ];

  final _search = TextEditingController();
  late final Stream<List<Course>> _courses;
  String _category = 'All Courses';
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _courses = CourseService.instance.publishedCourses();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCourse(Course c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: c.id)),
    );
  }

  Future<void> _loadSamples() async {
    setState(() => _seeding = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await CourseService.instance.loadSampleCourses();
      messenger.showSnackBar(
          const SnackBar(content: Text('Sample courses loaded.')));
    } catch (e) {
      debugPrint('Seeding failed: $e');
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not load courses. Are you logged in as admin?')));
    }
    if (mounted) setState(() => _seeding = false);
  }

  List<Course> _filter(List<Course> all) {
    final q = _search.text.trim().toLowerCase();
    return all.where((c) {
      final matchesCat = _category == 'All Courses' || c.category == _category;
      final matchesText = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
      return matchesCat && matchesText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context
        .watch<AuthProvider>()
        .hasRole([UserRole.admin, UserRole.trainer]);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: const MainAppBar(),
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
                child: StreamBuilder<List<Course>>(
                  stream: _courses,
                  builder: (context, snap) {
                    final all = snap.data ?? const <Course>[];
                    final filtered = _filter(all);
                    final showFeatured = _category == 'All Courses' &&
                        _search.text.trim().isEmpty &&
                        filtered.isNotEmpty;
                    final featured = showFeatured
                        ? filtered.firstWhere((c) => c.featured,
                            orElse: () => filtered.first)
                        : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(desktop),
                        const SizedBox(height: 24),
                        _searchBar(),
                        const SizedBox(height: 18),
                        _categoryFilters(),
                        const SizedBox(height: 28),
                        if (snap.connectionState == ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snap.hasError)
                          _message(
                            Icons.error_outline,
                            'Courses could not be loaded. Check your connection and that the Firestore rules are published.',
                          )
                        else if (all.isEmpty)
                          _emptyCatalogue(isStaff)
                        else ...[
                          if (featured != null) ...[
                            _featuredCourse(featured, desktop),
                            const SizedBox(height: 36),
                          ],
                          _sectionHeader(filtered.length),
                          if (isStaff)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _seeding ? null : _loadSamples,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: Text(_seeding
                                    ? 'Reloading…'
                                    : 'Staff: reload sample courses'),
                              ),
                            ),
                          const SizedBox(height: 18),
                          if (filtered.isEmpty)
                            _message(Icons.search_off_rounded,
                                'No courses match your search. Try another keyword or category.')
                          else
                            _courseGrid(filtered, desktop),
                        ],
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _message(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppTheme.purple),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.greyText, height: 1.5)),
        ],
      ),
    );
  }

  Widget _emptyCatalogue(bool isStaff) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.school_outlined, size: 40, color: AppTheme.purple),
          const SizedBox(height: 10),
          const Text('No courses published yet.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            isStaff
                ? 'You are signed in as staff. Load the sample courses to get started.'
                : 'Please check back soon.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.greyText),
          ),
          if (isStaff) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _seeding ? null : _loadSamples,
              icon: const Icon(Icons.download_rounded),
              label: Text(_seeding ? 'Loading…' : 'Load sample courses'),
            ),
          ],
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          'Learn. Apply. Grow.',
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
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.55),
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
          child: const Icon(Icons.school_rounded,
              color: AppTheme.softYellow, size: 45),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search courses, skills or topics...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _search.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _search.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }

  Widget _categoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in _categories)
            Padding(
              padding: const EdgeInsets.only(right: 9),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                  decoration: BoxDecoration(
                    color: _category == c ? AppTheme.deepBlue : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _category == c
                          ? AppTheme.deepBlue
                          : const Color(0xFFE4E0E9),
                    ),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      color:
                          _category == c ? Colors.white : AppTheme.darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featuredCourse(Course course, bool desktop) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openCourse(course),
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
              Image.asset(course.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppTheme.deepBlue)),
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
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _smallPill('FEATURED COURSE'),
                        const SizedBox(height: 12),
                        Text(
                          course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          course.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _courseMeta(Icons.menu_book_rounded,
                                '${course.moduleCount} modules'),
                            _courseMeta(Icons.schedule_rounded,
                                '${course.durationHours.toStringAsFixed(course.durationHours % 1 == 0 ? 0 : 1)} hrs'),
                            _courseMeta(Icons.sell_outlined, course.priceLabel),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Course',
                                style: TextStyle(
                                  color: AppTheme.deepBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 7),
                              Icon(Icons.arrow_forward_rounded,
                                  color: AppTheme.deepBlue, size: 17),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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
        Icon(icon, color: Colors.white70, size: 15),
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

  Widget _sectionHeader(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPLORE LEARNING',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Develop what matters.',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$count ${count == 1 ? 'course' : 'courses'} to choose from.',
          style: const TextStyle(color: AppTheme.greyText, fontSize: 13),
        ),
      ],
    );
  }

  Widget _courseGrid(List<Course> courses, bool desktop) {
    if (desktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: courses.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, i) => _courseCard(courses[i]),
      );
    }
    return Column(
      children: [
        for (final c in courses)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _courseCard(c),
          ),
      ],
    );
  }

  Widget _courseCard(Course course) {
    final titleColor = course.darkText ? AppTheme.deepBlue : Colors.white;
    final descriptionColor = course.darkText
        ? AppTheme.deepBlue.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.78);
    final accent = course.accentColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openCourse(course),
        child: Container(
          height: 285,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: accent,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(course.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: accent)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: course.darkText
                        ? [
                            Colors.transparent,
                            AppTheme.softYellow.withValues(alpha: 0.92),
                          ]
                        : [
                            Colors.transparent,
                            accent.withValues(alpha: 0.94),
                          ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: course.darkText
                                ? AppTheme.deepBlue
                                : Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.softYellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.priceLabel,
                            style: const TextStyle(
                              color: AppTheme.deepBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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
                        Expanded(
                          child: Text(
                            '${course.moduleCount} modules · ${course.level} · ${course.instructor}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded,
                            color: titleColor, size: 18),
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
