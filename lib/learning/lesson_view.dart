import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'course_models.dart';

/// Shows one lesson. Each content type is its own small widget, so a new
/// type (quiz, slides, live session...) is one `case` plus one widget.
class LessonContent extends StatelessWidget {
  final Lesson lesson;
  final String posterImage;
  final bool tall;

  const LessonContent({
    super.key,
    required this.lesson,
    required this.posterImage,
    this.tall = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (lesson.type) {
      case 'video':
        return _VideoBlock(lesson: lesson, poster: posterImage, tall: tall);
      case 'pdf':
        return _FileBlock(
          icon: Icons.picture_as_pdf_outlined,
          label: 'PDF resource',
          lesson: lesson,
        );
      case 'audio':
        return _FileBlock(
          icon: Icons.headphones_rounded,
          label: 'Audio lesson',
          lesson: lesson,
        );
      case 'link':
        return _FileBlock(
          icon: Icons.link_rounded,
          label: 'External resource',
          lesson: lesson,
        );
      case 'image':
        return _ImageBlock(lesson: lesson);
      default:
        return _TextBlock(lesson: lesson);
    }
  }
}

class _VideoBlock extends StatelessWidget {
  final Lesson lesson;
  final String poster;
  final bool tall;
  const _VideoBlock(
      {required this.lesson, required this.poster, required this.tall});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: tall ? 340 : 210,
          decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: AssetImage(poster),
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
              child: const Icon(Icons.play_arrow,
                  color: AppTheme.deepBlue, size: 42),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lesson.url.isEmpty
              ? 'Video lesson · ${lesson.minutes} min (video file not uploaded yet)'
              : 'Video lesson · ${lesson.minutes} min',
          style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _TextBlock(lesson: lesson),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  final Lesson lesson;
  const _TextBlock({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Text(
      lesson.body.isEmpty ? 'Lesson content will appear here.' : lesson.body,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _ImageBlock extends StatelessWidget {
  final Lesson lesson;
  const _ImageBlock({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lesson.url.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              lesson.url,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 120,
                child: Center(child: Text('Image could not be loaded.')),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _TextBlock(lesson: lesson),
      ],
    );
  }
}

class _FileBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final Lesson lesson;
  const _FileBlock(
      {required this.icon, required this.label, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E0E9)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.purple, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      lesson.url.isEmpty
                          ? 'File not uploaded yet.'
                          : lesson.url,
                      style: const TextStyle(
                          color: AppTheme.greyText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TextBlock(lesson: lesson),
      ],
    );
  }
}
