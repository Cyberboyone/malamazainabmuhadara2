import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/duration_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_progress_bar.dart';

class LessonCard extends StatefulWidget {
  final Lesson lesson;
  final int lessonNumber;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.lessonNumber,
    required this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  @override
  void initState() {
    super.initState();
    DurationService.instance.durationsReady.addListener(_rebuild);
    PlayerService.instance.tick.addListener(_rebuild);
  }

  @override
  void dispose() {
    DurationService.instance.durationsReady.removeListener(_rebuild);
    PlayerService.instance.tick.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  bool get _isCurrent {
    final current = PlayerService.instance.currentLesson;
    return current?.id == widget.lesson.id;
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isPlaying = _isCurrent && PlayerService.instance.isPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          onTap: widget.onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: isPlaying
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B3A24), Color(0xFF0C2A46)],
                    )
                  : AppColors.surfaceGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: isPlaying
                    ? AppColors.gold
                    : AppColors.border.withValues(alpha: 0.5),
                width: isPlaying ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                // Lesson number badge
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPlaying
                        ? Colors.transparent
                        : AppColors.backgroundAlt.withValues(alpha: 0.7),
                    border: Border.all(
                      color: isPlaying
                          ? AppColors.gold
                          : AppColors.border.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: isPlaying
                      ? const PlayingIndicator(size: 16)
                      : Text(
                          '${widget.lessonNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isPlaying
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Title / course / duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lesson.title,
                        style: AppType.lessonTitle.copyWith(
                          color: isPlaying
                              ? AppColors.goldLight
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.headphones_outlined,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lesson.course.isNotEmpty
                                  ? lesson.course
                                  : lesson.scholarName,
                              style: AppType.smallMuted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (lesson.duration > Duration.zero) ...[
                            Container(width: 1, height: 10, color: AppColors.border),
                            const SizedBox(width: 6),
                            Text(
                              formatDuration(lesson.duration),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Play/pause button
                _PlayButton(isPlaying: isPlaying, onTap: widget.onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}