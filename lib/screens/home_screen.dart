import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'courses_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'store_screen.dart';
import 'about_screen.dart';
import 'services_screen.dart';
import 'insights_screen.dart';
import 'contact_screen.dart';
import 'corporate_screen.dart';
import 'course_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

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
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250),
                child: desktop
                    ? _desktopHome(context)
                    : _mobileHome(context),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 900
          ? _mobileNav()
          : null,
    );
  }


  PreferredSizeWidget _appBar(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return AppBar(
      backgroundColor: const Color(0xFFF7F6F9),
      elevation: 0,
      titleSpacing: desktop ? 48 : 18,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.deepBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.softYellow,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'MT Alchemy',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        if (desktop) ...[
          _navItem('About'),
          _navItem('Services'),
          _navItem('Learn'),
          _navItem('Develop'),
          _navItem('Store'),
          _navItem('Insights'),
          _navItem('Contact'),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.deepBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.deepBlue),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        IconButton(
          tooltip: 'Open Store',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StoreScreen(),
              ),
            );
          },
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: TextButton(
        onPressed: () {
          Widget? page;
          switch (title) {
            case 'About': page = const AboutScreen(); break;
            case 'Learn':
            case 'Develop': page = const CoursesScreen(); break;
            case 'Store': page = const StoreScreen(); break;
            case 'Insights': page = const InsightsScreen(); break;
            case 'Services': page = const ServicesScreen(); break;
            case 'Contact': page = const ContactScreen(); break;
          }
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
          }
        },
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget _desktopHome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 440,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: _hero()),
              const SizedBox(width: 18),
              Expanded(flex: 4, child: _journeyCard()),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _alchemyMethod(),
        const SizedBox(height: 34),
        _sectionTitle(
          'DEVELOP WHAT MATTERS',
          'Build skills that move people forward.',
          'Explore practical development areas designed for meaningful change.',
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 310,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: _photoCard(
                  image: 'assets/images/team_collaboration.png',
                  eyebrow: '01  •  CORE SKILL',
                  title: 'Emotional Intelligence',
                  description:
                  'Understand yourself. Connect with others. Lead with awareness.',
                  accent: AppTheme.purple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: _photoCard(
                  image: 'assets/images/leadership_discussion.png',
                  eyebrow: '02  •  LEADERSHIP',
                  title: 'Leadership Development',
                  description: 'Lead conversations with clarity and purpose.',
                  accent: AppTheme.deepBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: _photoCard(
                  image: 'assets/images/upskilling_workspace.png',
                  eyebrow: '03  •  UPSKILLING',
                  title: 'Team Engagement',
                  description: 'Create connected, motivated teams.',
                  accent: AppTheme.softYellow,
                  darkText: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _organisationSection(),
        const SizedBox(height: 24),
        _impactSection(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _mobileHome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hero(),
        const SizedBox(height: 18),
        _journeyCard(),
        const SizedBox(height: 18),
        _alchemyMethod(),
        const SizedBox(height: 28),
        _sectionTitle(
          'DEVELOP WHAT MATTERS',
          'Build skills that move people forward.',
          'Explore practical development areas designed for meaningful change.',
        ),
        const SizedBox(height: 16),
        _photoCard(
          image: 'assets/images/team_collaboration.png',
          eyebrow: '01  •  CORE SKILL',
          title: 'Emotional Intelligence',
          description:
          'Understand yourself. Connect with others. Lead with awareness.',
          accent: AppTheme.purple,
          height: 280,
        ),
        const SizedBox(height: 12),
        _photoCard(
          image: 'assets/images/leadership_discussion.png',
          eyebrow: '02  •  LEADERSHIP',
          title: 'Leadership Development',
          description: 'Lead conversations with clarity and purpose.',
          accent: AppTheme.deepBlue,
          height: 250,
        ),
        const SizedBox(height: 12),
        _photoCard(
          image: 'assets/images/upskilling_workspace.png',
          eyebrow: '03  •  UPSKILLING',
          title: 'Team Engagement',
          description: 'Create connected, motivated teams.',
          accent: AppTheme.softYellow,
          darkText: true,
          height: 250,
        ),
        const SizedBox(height: 18),
        _organisationSection(),
        const SizedBox(height: 20),
        _impactSection(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _hero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepBlue.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/hero_office.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.deepBlue.withValues(alpha: 0.98),
                      AppTheme.deepBlue.withValues(alpha: 0.78),
                      AppTheme.deepBlue.withValues(alpha: 0.20),
                    ],
                  ),
                ),
              ),
              if (!compact)
                Positioned(
                  right: 28,
                  top: 22,
                  child: _orbitGraphic(),
                ),
              Padding(
                padding: EdgeInsets.all(compact ? 25 : 40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 570),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pill('PEOPLE  •  POTENTIAL  •  IMPACT'),
                        const SizedBox(height: 23),
                        Text(
                          'Turn potential\ninto impact.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 39 : 54,
                            height: 0.97,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 17),
                        Text(
                          'People development designed around real transformation — from insight to practice, behaviour and impact.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 15,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CoursesScreen(),

                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.softYellow,
                            foregroundColor: AppTheme.deepBlue,
                            minimumSize: const Size(205, 53),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Begin Your Journey'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
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
        );
      },
    );
  }

  Widget _journeyCard() {
    return _HoverShell(
      glow: AppTheme.purple,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE4E0E9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: AppTheme.purple,
                  ),
                ),
                const Spacer(),
                const Text(
                  '68%',
                  style: TextStyle(
                    color: AppTheme.purple,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            const Text(
              'YOUR TRANSFORMATION',
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Leadership Development',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Continue building your leadership skills.',
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 21),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.68),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFEDEAF4),
                        valueColor: const AlwaysStoppedAnimation(
                          AppTheme.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${(value * 100).round()}% of your learning path',
                      style: const TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                _JourneyDot(label: 'Insight', active: true),
                _JourneyLine(),
                _JourneyDot(label: 'Practice', active: true),
                _JourneyLine(),
                _JourneyDot(label: 'Behaviour', active: true),
                _JourneyLine(),
                _JourneyDot(label: 'Impact', active: false),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Module 4 of 6',
                  style: TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursePlayerScreen()));
                  },
                  child: const Text('Continue →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alchemyMethod() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4E0E9)),
          ),
          child: compact
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ALCHEMY METHOD',
                style: TextStyle(
                  color: AppTheme.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _methodItem(
                      '01',
                      'Insight',
                      AppTheme.purple,
                    ),
                  ),
                  Expanded(
                    child: _methodItem(
                      '02',
                      'Practice',
                      AppTheme.deepBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _methodItem(
                      '03',
                      'Behaviour',
                      AppTheme.softYellow,
                    ),
                  ),
                  Expanded(
                    child: _methodItem(
                      '04',
                      'Impact',
                      const Color(0xFF4C7A6B),
                    ),
                  ),
                ],
              ),
            ],
          )
              : Row(
            children: [
              const Text(
                'ALCHEMY METHOD',
                style: TextStyle(
                  color: AppTheme.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _methodItem(
                  '01',
                  'Insight',
                  AppTheme.purple,
                ),
              ),
              _line(),
              Expanded(
                child: _methodItem(
                  '02',
                  'Practice',
                  AppTheme.deepBlue,
                ),
              ),
              _line(),
              Expanded(
                child: _methodItem(
                  '03',
                  'Behaviour',
                  AppTheme.softYellow,
                ),
              ),
              _line(),
              Expanded(
                child: _methodItem(
                  '04',
                  'Impact',
                  const Color(0xFF4C7A6B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _methodItem(String number, String title, Color color) {
    final foreground =
    color == AppTheme.softYellow ? AppTheme.deepBlue : color;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: foreground,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _line() {
    return Container(
      width: 20,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFD8D3DF),
    );
  }

  Widget _photoCard({
    required String image,
    required String eyebrow,
    required String title,
    required String description,
    required Color accent,
    bool darkText = false,
    double? height,
  }) {
    final titleColor = darkText ? AppTheme.deepBlue : Colors.white;
    final subColor = darkText
        ? AppTheme.deepBlue.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.78);

    return _HoverShell(
      glow: accent,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: accent,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: darkText
                      ? [
                    Colors.transparent,
                    AppTheme.softYellow.withValues(alpha: 0.20),
                    AppTheme.softYellow.withValues(alpha: 0.96),
                  ]
                      : [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.20),
                    accent.withValues(alpha: 0.94),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: TextStyle(
                      color: titleColor.withValues(alpha: 0.85),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 21,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explore  →',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _organisationSection() {
    return _HoverShell(
      glow: AppTheme.deepBlue,
      child: Container(
        height: 330,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppTheme.deepBlue,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/employer_business.png',
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
                    AppTheme.deepBlue.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pill('FOR ORGANISATIONS'),
                      const SizedBox(height: 16),
                      const Text(
                        'Develop your people.\nStrengthen your organisation.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create learning pathways, support employee growth and track progress through one connected experience.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CorporateScreen()));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Explore Corporate Learning'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _impactSection() {
    return Container(
      height: 340,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppTheme.deepBlue,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/impact_buildings.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.deepBlue.withValues(alpha: 0.96),
                  AppTheme.deepBlue.withValues(alpha: 0.72),
                  AppTheme.deepBlue.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 430,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pill('FROM LEARNING TO IMPACT'),
                    const SizedBox(height: 16),
                    const Text(
                      'Learn.\nLead.\nTransform.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        height: 0.98,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meaningful development turns knowledge into practice, practice into behaviour, and behaviour into impact.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.55,
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

  Widget _orbitGraphic() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _OrbitPainter(_orbitController.value),
            child: child,
          ),
        );
      },
      child: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: AppTheme.softYellow,
          size: 38,
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
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

  Widget _sectionTitle(String eyebrow, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppTheme.purple,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final items = <(String, IconData, Widget)>[
          ('About', Icons.info_outline, const AboutScreen()),
          ('Services', Icons.auto_awesome_outlined, const ServicesScreen()),
          ('Corporate Learning', Icons.business_outlined, const CorporateScreen()),
          ('Contact', Icons.mail_outline, const ContactScreen()),
          ('Login', Icons.login_rounded, const LoginScreen()),
          ('Register', Icons.person_add_alt_1_rounded, const RegisterScreen()),
        ];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Text('Explore MT Alchemy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.deepBlue)),
              ),
              ...items.map((item) => ListTile(
                leading: Icon(item.$2, color: AppTheme.purple),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3));
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileNav() {
    return NavigationBar(
      backgroundColor: Colors.white,
      selectedIndex: 0,
      onDestinationSelected: (index) {
        Widget? page;
        switch (index) {
          case 1: page = const CoursesScreen(); break;
          case 2: page = const StoreScreen(); break;
          case 3: page = const InsightsScreen(); break;
          case 4:
            _showMoreMenu();
            return;
          default: return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school_rounded),
          label: 'Learn',
        ),
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: 'Store',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories_rounded),
          label: 'Insights',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_horiz_rounded),
          label: 'More',
        ),
      ],
    );
  }
}

class _HoverShell extends StatefulWidget {
  final Widget child;
  final Color glow;

  const _HoverShell({
    required this.child,
    required this.glow,
  });

  @override
  State<_HoverShell> createState() => _HoverShellState();
}

class _HoverShellState extends State<_HoverShell> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          hovered ? -5 : 0,
          0,
        )..scale(hovered ? 1.012 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: hovered
              ? [
            BoxShadow(
              color: widget.glow.withValues(alpha: 0.24),
              blurRadius: 28,
              offset: const Offset(0, 13),
            ),
          ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

class _JourneyDot extends StatelessWidget {
  final String label;
  final bool active;

  const _JourneyDot({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active ? AppTheme.purple : const Color(0xFFEDEAF4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            active ? Icons.check_rounded : Icons.circle_outlined,
            size: 12,
            color: active ? Colors.white : AppTheme.greyText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _JourneyLine extends StatelessWidget {
  const _JourneyLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 15),
        color: const Color(0xFFE1DCE8),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;

  _OrbitPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.softYellow.withValues(alpha: 0.34);

    for (final radius in [42.0, 62.0, 82.0]) {
      canvas.drawCircle(center, radius, ring);
    }

    final angle = progress * 2 * math.pi;
    final dot = Offset(
      center.dx + 62 * math.cos(angle),
      center.dy + 62 * math.sin(angle),
    );

    final dotPaint = Paint()
      ..color = AppTheme.softYellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dot, 4, dotPaint);

    final purple = Paint()
      ..color = AppTheme.purple.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - 38, center.dy + 38),
      30,
      purple,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

