import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../learning/course_service.dart';
import '../theme/app_theme.dart';
import 'certificate_screen.dart';

/// Course assessment. Questions come from the course in Firestore and can be
/// single choice, true/false, multiple answer or short answer.
class AssessmentScreen extends StatefulWidget {
  final Course course;
  final Enrolment? enrolment; // null = staff preview (nothing is saved)

  const AssessmentScreen({
    super.key,
    required this.course,
    required this.enrolment,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late final List<Question> _questions;
  late List<Set<int>> _picked;
  late List<TextEditingController> _typed;

  int _index = 0;
  bool _submitted = false;
  bool _saving = false;
  String? _certificateId;
  String? _saveError;

  Assessment? get _assessment => widget.course.assessment;
  int get _passMark => _assessment?.passingScore ?? 60;

  @override
  void initState() {
    super.initState();
    _questions = _assessment?.questions ?? const [];
    _reset();
    // Learner already passed earlier: keep their certificate handy.
    if (widget.enrolment?.passed == true &&
        widget.enrolment!.certificateId.isNotEmpty) {
      _certificateId = widget.enrolment!.certificateId;
    }
  }

  void _reset() {
    _picked = List.generate(_questions.length, (_) => <int>{});
    _typed = List.generate(_questions.length, (_) => TextEditingController());
    _index = 0;
    _submitted = false;
    _saveError = null;
  }

  @override
  void dispose() {
    for (final c in _typed) {
      c.dispose();
    }
    super.dispose();
  }

  bool _answered(int i) {
    final q = _questions[i];
    return q.type == 'short'
        ? _typed[i].text.trim().isNotEmpty
        : _picked[i].isNotEmpty;
  }

  bool _correct(int i) => _questions[i].isCorrect(
        picked: _picked[i],
        typed: _typed[i].text,
      );

  int get _correctCount =>
      List.generate(_questions.length, (i) => _correct(i)).where((c) => c).length;

  int get _percent => _questions.isEmpty
      ? 0
      : ((_correctCount / _questions.length) * 100).round();

  bool get _passed => _percent >= _passMark;

  Future<void> _next() async {
    if (!_answered(_index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the question first.')),
      );
      return;
    }
    if (_index < _questions.length - 1) {
      setState(() => _index++);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _saving = true;
      _saveError = null;
    });

    final enrolment = widget.enrolment;
    final auth = context.read<AuthProvider>();
    final percent = _percent;
    final passed = _passed;

    if (enrolment != null) {
      try {
        await CourseService.instance.recordAttempt(
          enrolmentId: enrolment.id,
          percent: percent,
          bestPercent: percent > enrolment.bestScore ? percent : enrolment.bestScore,
          passed: passed,
        );
        if (passed) {
          _certificateId = await CourseService.instance.ensureCertificate(
            course: widget.course,
            uid: enrolment.uid,
            learnerName: auth.user?.name ?? 'Learner',
          );
        }
      } catch (e) {
        debugPrint('Saving assessment failed: $e');
        _saveError =
            'Your result could not be saved. Check your connection and try again.';
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _retake() {
    for (final c in _typed) {
      c.dispose();
    }
    setState(_reset);
  }

  // ------------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: AppBar(title: const Text('Course Assessment')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _questions.isEmpty
                ? _noAssessment()
                : (_submitted ? _result() : _question()),
          ),
        ),
      ),
    );
  }

  Widget _noAssessment() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'This course does not have an assessment yet.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _question() {
    final q = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.course.title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.purple,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text('Course Assessment',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Pass mark: $_passMark%. Test your understanding of the course content.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E0E9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Question ${_index + 1} of ${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${(progress * 100).round()}%',
                      style: const TextStyle(
                          color: AppTheme.purple, fontWeight: FontWeight.w700)),
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
              const SizedBox(height: 26),
              Text(q.text, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                _hint(q),
                style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (q.type == 'short')
                TextField(
                  controller: _typed[_index],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Type your answer',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                for (var i = 0; i < q.options.length; i++) _option(q, i),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (_index > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _index--),
                      child: const Text('Previous'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_index == _questions.length - 1
                        ? 'Submit Assessment'
                        : 'Next Question'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _hint(Question q) {
    switch (q.type) {
      case 'multiple':
        return 'Select all that apply.';
      case 'short':
        return 'Short answer.';
      case 'truefalse':
        return 'Choose True or False.';
      default:
        return 'Choose one answer.';
    }
  }

  Widget _option(Question q, int i) {
    final selected = _picked[_index].contains(i);
    final multi = q.type == 'multiple';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.softYellow.withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppTheme.deepBlue : const Color(0xFFE4E7EC),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          if (multi) {
            selected ? _picked[_index].remove(i) : _picked[_index].add(i);
          } else {
            _picked[_index] = {i};
          }
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                multi
                    ? (selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded)
                    : (selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded),
                color: selected ? AppTheme.deepBlue : AppTheme.greyText,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q.options[i])),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ result
  Widget _result() {
    final passed = _passed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4E0E9)),
          ),
          child: Column(
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.menu_book,
                size: 72,
                color: passed ? AppTheme.purple : AppTheme.deepBlue,
              ),
              const SizedBox(height: 16),
              Text(
                passed ? 'Congratulations, you passed!' : 'Keep learning!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Score: $_correctCount / ${_questions.length}  ($_percent%)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text('Pass mark: $_passMark%',
                  style: const TextStyle(color: AppTheme.greyText)),
              const SizedBox(height: 12),
              Text(
                passed
                    ? 'Well done! You have completed this course.'
                    : 'Review the lessons and the answers below, then retake the assessment.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (_saving) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 6),
                const Text('Saving your result…',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
              if (_saveError != null) ...[
                const SizedBox(height: 12),
                Text(_saveError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB42318))),
              ],
              if (widget.enrolment == null) ...[
                const SizedBox(height: 12),
                const Text('Staff preview: results are not saved.',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (passed && _certificateId != null)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CertificateScreen(certificateId: _certificateId!),
                        ),
                      ),
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text('View Certificate'),
                    ),
                  if (!passed && !_saving)
                    ElevatedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retake Assessment'),
                    ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Course'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('Review your answers',
            style: TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (var i = 0; i < _questions.length; i++) _reviewCard(i),
      ],
    );
  }

  Widget _reviewCard(int i) {
    final q = _questions[i];
    final ok = _correct(i);
    final yourAnswer = q.type == 'short'
        ? _typed[i].text.trim()
        : (_picked[i].toList()..sort()).map((x) => q.options[x]).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ok ? const Color(0xFF4C7A6B) : const Color(0xFFFDA29B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.cancel,
                color: ok ? const Color(0xFF4C7A6B) : const Color(0xFFD92D20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${i + 1}. ${q.text}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Your answer: ${yourAnswer.isEmpty ? '—' : yourAnswer}',
              style: const TextStyle(color: AppTheme.greyText)),
          if (!ok)
            Text('Correct answer: ${q.correctText}',
                style: const TextStyle(
                    color: Color(0xFF4C7A6B), fontWeight: FontWeight.w600)),
          if (q.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(q.explanation,
                style: const TextStyle(color: AppTheme.greyText, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
