
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'certificate_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;
  bool submitted = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is one important quality of an effective leader?',
      'answers': [
        'Avoiding feedback',
        'Clear communication',
        'Making every decision alone',
        'Ignoring team concerns',
      ],
      'correct': 1,
    },
    {
      'question': 'What does active listening involve?',
      'answers': [
        'Interrupting to give advice',
        'Thinking only about your reply',
        'Paying attention and understanding the speaker',
        'Changing the subject quickly',
      ],
      'correct': 2,
    },
    {
      'question': 'How can a leader build trust within a team?',
      'answers': [
        'By being consistent and accountable',
        'By hiding important information',
        'By avoiding difficult conversations',
        'By taking credit for others’ work',
      ],
      'correct': 0,
    },
    {
      'question': 'What should a leader do after receiving constructive feedback?',
      'answers': [
        'Reject it immediately',
        'Blame the team',
        'Ignore it',
        'Reflect on it and identify improvements',
      ],
      'correct': 3,
    },
    {
      'question': 'What is the purpose of a leadership action plan?',
      'answers': [
        'To avoid setting goals',
        'To turn learning into practical actions',
        'To replace teamwork',
        'To stop personal development',
      ],
      'correct': 1,
    },
  ];

  void nextQuestion() {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer first.'),
        ),
      );
      return;
    }

    if (selectedAnswer == questions[currentQuestion]['correct']) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      setState(() {
        submitted = true;
      });
    }
  }

  void restartQuiz() {
    setState(() {
      currentQuestion = 0;
      selectedAnswer = null;
      score = 0;
      submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final percentage = (score / questions.length * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Assessment'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: submitted
                ? buildResult(percentage)
                : buildQuestion(question),
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    final answers = question['answers'] as List<String>;
    final progress = (currentQuestion + 1) / questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LEADERSHIP DEVELOPMENT',
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Course Assessment',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Test your understanding of the course content.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestion + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE4E7EC),
                  color: AppTheme.purple,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                question['question'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              ...List.generate(answers.length, (index) {
                final isSelected = selectedAnswer == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.softYellow.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.deepBlue
                          : const Color(0xFFE4E7EC),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: index,
                    groupValue: selectedAnswer,
                    activeColor: AppTheme.deepBlue,
                    title: Text(answers[index]),
                    onChanged: (value) {
                      setState(() {
                        selectedAnswer = value;
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(
                    currentQuestion == questions.length - 1
                        ? 'Submit Assessment'
                        : 'Next Question',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildResult(int percentage) {
    final passed = percentage >= 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.emoji_events : Icons.menu_book,
            size: 76,
            color: passed ? AppTheme.purple : AppTheme.deepBlue,
          ),
          const SizedBox(height: 20),
          Text(
            passed ? 'Assessment Completed!' : 'Keep Learning!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Your score: $score / ${questions.length} ($percentage%)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            passed
                ? 'Well done! You passed this prototype assessment.'
                : 'Review the course lessons and try the assessment again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: restartQuiz,
              child: const Text('Try Again'),
            ),
          ),
          if (passed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('View Certificate'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Course'),
            ),
          ),
        ],
      ),
    );
  }
}
