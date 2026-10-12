import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'assessment_screen.dart';

class CoursePlayerScreen extends StatefulWidget {
  const CoursePlayerScreen({super.key});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  int selectedModule = 0;
  int selectedLesson = 0;

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Understanding Your Leadership Style',
      'lessons': [
        'Introduction to Leadership',
        'Discovering Your Leadership Style',
        'Strengths and Development Areas',
        'Leadership Reflection',
      ],
    },
    {
      'title': 'Communication & Influence',
      'lessons': [
        'Effective Communication',
        'Active Listening',
        'Influencing Others',
        'Building Trust',
        'Communication Practice',
      ],
    },
    {
      'title': 'Leading Difficult Conversations',
      'lessons': [
        'Understanding Difficult Conversations',
        'Preparing for Challenging Discussions',
        'Managing Emotions',
        'Conversation Practice',
      ],
    },
    {
      'title': 'Building High-Trust Teams',
      'lessons': [
        'What Makes a High-Trust Team?',
        'Team Collaboration',
        'Psychological Safety',
        'Giving Feedback',
        'Team Activity',
      ],
    },
    {
      'title': 'Decision Making & Accountability',
      'lessons': [
        'Making Better Decisions',
        'Taking Ownership',
        'Accountability in Teams',
        'Decision-Making Practice',
      ],
    },
    {
      'title': 'From Insight to Impact',
      'lessons': [
        'Turning Learning into Action',
        'Creating Your Action Plan',
        'Final Reflection',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentModule = modules[selectedModule];
    final lessons = currentModule['lessons'] as List<String>;
    final currentLesson = lessons[selectedLesson];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Player'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your course progress is saved.'),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (isDesktop)
                SizedBox(
                  width: 330,
                  child: _buildSidebar(),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 40 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isDesktop) _buildMobileModuleSelector(),

                      Text(
                        'MODULE ${selectedModule + 1}',
                        style: const TextStyle(
                          color: AppTheme.purple,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        currentModule['title'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium,
                      ),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        height: isDesktop ? 360 : 220,
                        decoration: BoxDecoration(
                          color: AppTheme.deepBlue,
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/leadership_discussion.png',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.45,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(
                              color: AppTheme.softYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: AppTheme.deepBlue,
                              size: 42,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        currentLesson,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'In this lesson, you will explore practical ideas '
                            'and activities related to leadership development. '
                            'Work through the content at your own pace and '
                            'complete the activities before moving forward.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE4E7EC),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.softYellow.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: AppTheme.deepBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Lesson Activity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Reflect on the key ideas from this lesson '
                                        'and prepare for the next activity.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _previousLesson,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _nextLesson,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next Lesson'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      if (selectedModule == modules.length - 1 &&
                          selectedLesson == lessons.length - 1)
                        _buildQuizCard(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE4E7EC),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'COURSE CONTENT',
              style: TextStyle(
                color: AppTheme.purple,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, moduleIndex) {
                final module = modules[moduleIndex];
                final lessons = module['lessons'] as List<String>;

                return ExpansionTile(
                  initiallyExpanded: moduleIndex == selectedModule,
                  title: Text(
                    'Module ${moduleIndex + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    module['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: List.generate(
                    lessons.length,
                        (lessonIndex) {
                      final isSelected =
                          moduleIndex == selectedModule &&
                              lessonIndex == selectedLesson;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor:
                        AppTheme.softYellow.withOpacity(0.25),
                        leading: Icon(
                          isSelected
                              ? Icons.play_circle
                              : Icons.check_circle_outline,
                          color: isSelected
                              ? AppTheme.purple
                              : AppTheme.greyText,
                        ),
                        title: Text(
                          lessons[lessonIndex],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedModule = moduleIndex;
                            selectedLesson = lessonIndex;
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileModuleSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedModule,
          isExpanded: true,
          items: List.generate(
            modules.length,
                (index) => DropdownMenuItem(
              value: index,
              child: Text(
                'Module ${index + 1}: ${modules[index]['title']}',
              ),
            ),
          ),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedModule = value;
              selectedLesson = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuizCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.purple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.quiz_outlined,
            color: AppTheme.softYellow,
            size: 32,
          ),
          const SizedBox(height: 14),
          const Text(
            'Ready for the assessment?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the course assessment to test your understanding.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssessmentScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.softYellow,
              foregroundColor: AppTheme.deepBlue,
            ),
            child: const Text('Start Assessment'),
          ),
        ],
      ),
    );
  }

  void _nextLesson() {
    final lessons = modules[selectedModule]['lessons'] as List<String>;

    if (selectedLesson < lessons.length - 1) {
      setState(() {
        selectedLesson++;
      });
      return;
    }

    if (selectedModule < modules.length - 1) {
      setState(() {
        selectedModule++;
        selectedLesson = 0;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'You have reached the end of the course.',
        ),
      ),
    );
  }

  void _previousLesson() {
    if (selectedLesson > 0) {
      setState(() {
        selectedLesson--;
      });
      return;
    }

    if (selectedModule > 0) {
      final previousModule = selectedModule - 1;
      final lessons =
      modules[previousModule]['lessons'] as List<String>;

      setState(() {
        selectedModule = previousModule;
        selectedLesson = lessons.length - 1;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are already at the first lesson.'),
      ),
    );
  }
}