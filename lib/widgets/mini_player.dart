import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';
import '../widgets/audio_progress_bar.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  void initState() {
    super.initState();
    PlayerService.instance.tick.addListener(_onTick);
  }

  @override
  void dispose() {
    PlayerService.instance.tick.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final audio = PlayerService.instance;
    final lesson = audio.currentLesson;
    if (lesson == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlayerScreen(lesson: lesson)),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        decoration: BoxDecoration(
          gradient: AppColors.surfaceGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Mini artwork
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldRing,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/scholar_zainab.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.mic,
                            color: AppColors.gold, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + play state
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.mic,
                              size: 12, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lesson.course.isNotEmpty
                                  ? lesson.course
                                  : lesson.scholarName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppType.smallMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Play/pause
                StreamBuilder<PlayerState>(
                  stream: audio.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return GestureDetector(
                      onTap: () => audio.togglePlay(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress
            StreamBuilder<Duration>(
              stream: audio.player.positionStream,
              builder: (context, posSnapshot) {
                final position = posSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: audio.player.durationStream,
                  builder: (context, durSnapshot) {
                    final duration =
                        durSnapshot.data ?? lesson.duration;
                    final totalMs = duration.inMilliseconds < 1
                        ? 1
                        : duration.inMilliseconds;
                    final fraction =
                        (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
                    return AudioProgressBar(
                      fraction: fraction,
                      showThumb: false,
                      height: 3,
                      onSeek: (f) => audio.player.seek(
                        Duration(milliseconds: (totalMs * f).round()),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}