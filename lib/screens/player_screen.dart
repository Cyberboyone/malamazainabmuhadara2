import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/sample_lessons.dart';
import '../models/lesson.dart';
import '../services/player_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_progress_bar.dart';
import '../widgets/gold_icon_button.dart';

class PlayerScreen extends StatefulWidget {
  final Lesson lesson;
  const PlayerScreen({super.key, required this.lesson});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _audio = PlayerService.instance;
  AudioPlayer get _player => _audio.player;
  late List<Lesson> _courseLessons;
  late int _currentIndex;
  StreamSubscription<PlayerState>? _completionSub;

  @override
  void initState() {
    super.initState();
    _courseLessons = sampleLessons
        .where((l) => l.course == widget.lesson.course)
        .toList();
    _currentIndex =
        _courseLessons.indexWhere((l) => l.id == widget.lesson.id);
    if (_currentIndex == -1) _currentIndex = 0;
    _load();

    // When a track finishes, move on to the next one (playlist behaviour).
    _completionSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> _load() async {
    try {
      final lesson = _courseLessons[_currentIndex];
      final saved = ProgressService.instance.lastPosition(lesson.id);
      await _audio.playLesson(lesson, startAt: saved);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load audio: $e')),
        );
      }
    }
  }

  void _playLesson(Lesson lesson) {
    _saveCurrentPosition();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayerScreen(lesson: lesson)),
    );
  }

  void _playNext() {
    if (_currentIndex < _courseLessons.length - 1) {
      _playLesson(_courseLessons[_currentIndex + 1]);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _playLesson(_courseLessons[_currentIndex - 1]);
    } else {
      _player.seek(Duration.zero);
    }
  }

  void _saveCurrentPosition() {
    if (_player.position > Duration.zero) {
      ProgressService.instance.savePosition(
        _courseLessons[_currentIndex].id,
        _player.position,
      );
    }
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _saveCurrentPosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _courseLessons[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              final artworkSize =
                  (constraints.maxWidth * 0.5).clamp(170.0, 260.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GoldIconButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            size: 44,
                            iconSize: 26,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          Column(
                            children: [
                              const Text(
                                'Now Playing',
                                style: AppType.brandTagline,
                              ),
                              Text(
                                lesson.course,
                                style: AppType.smallMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),

                      SizedBox(height: compact ? 18 : 24),

                      // Central artwork
                      _ArtworkDisc(
                        size: artworkSize,
                        lesson: lesson,
                        playing: _audio.isPlaying,
                      ),

                      SizedBox(height: compact ? 18 : 28),

                      // Title
                      Text(
                        lesson.title,
                        textAlign: TextAlign.center,
                        style: AppType.screenTitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.brightness_1,
                              size: 8, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              lesson.scholarName,
                              textAlign: TextAlign.center,
                              style: AppType.bodySecondary,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: compact ? 18 : 26),

                      // Progress
                      _ProgressArea(
                        lesson: lesson,
                        onSeekRatio: (ratio) => _seek(ratio),
                      ),

                      SizedBox(height: compact ? 10 : 20),

                      // Transport controls
                      _TransportControls(
                        player: _player,
                        onShuffle: (v) =>
                            _player.setShuffleModeEnabled(v),
                        onPrevious: _playPrevious,
                        onPlayPause: () => _audio.togglePlay(),
                        onNext: _currentIndex < _courseLessons.length - 1
                            ? _playNext
                            : null,
                        onLoop: (mode) => _player.setLoopMode(mode),
                        currentIndex: _currentIndex,
                        totalCount: _courseLessons.length,
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _seek(double ratio) {
    final lesson = _courseLessons[_currentIndex];
    final duration = _player.duration ?? lesson.duration;
    if (duration <= Duration.zero) return;
    final target =
        Duration(milliseconds: (duration.inMilliseconds * ratio).round());
    _player.seek(target);
  }
}

/// Circular disc artwork with a subtle rotation while playing.
class _ArtworkDisc extends StatelessWidget {
  final double size;
  final Lesson lesson;
  final bool playing;

  const _ArtworkDisc({
    required this.size,
    required this.lesson,
    required this.playing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldRing,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.surfaceGradient,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: lesson.scholarPhotoPath != null
              ? Image.asset(
                  lesson.scholarPhotoPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _DiscFallback(
                      size: size, lesson: lesson, playing: playing),
                )
              : _DiscFallback(
                  size: size, lesson: lesson, playing: playing),
        ),
      ),
    );
  }
}

class _DiscFallback extends StatelessWidget {
  final double size;
  final Lesson lesson;
  final bool playing;
  const _DiscFallback(
      {required this.size, required this.lesson, required this.playing});

  @override
  Widget build(BuildContext context) {
    if (lesson.arabicLabel != null) {
      return Container(
        color: AppColors.primary,
        alignment: Alignment.center,
        child: Text(
          lesson.arabicLabel!,
          style: TextStyle(
            fontSize: size * 0.22,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
      );
    }
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: AppColors.gold, size: 56),
          if (playing) ...[
            const SizedBox(height: 14),
            const PlayingIndicator(size: 26),
          ],
        ],
      ),
    );
  }
}

class _ProgressArea extends StatelessWidget {
  final Lesson lesson;
  final ValueChanged<double> onSeekRatio;
  const _ProgressArea({required this.lesson, required this.onSeekRatio});

  @override
  Widget build(BuildContext context) {
    final player = PlayerService.instance.player;
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durSnapshot) {
        final duration = durSnapshot.data ?? lesson.duration;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnapshot) {
            final position = posSnapshot.data ?? Duration.zero;
            final totalMs =
                duration.inMilliseconds.clamp(1, double.infinity).toInt();
            final fraction =
                (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
            return Column(
              children: [
                AudioProgressBar(
                  fraction: fraction,
                  onSeek: onSeekRatio,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(position),
                        style: AppType.smallMuted),
                    Text(formatDuration(duration),
                        style: AppType.smallMuted),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TransportControls extends StatelessWidget {
  final AudioPlayer player;
  final ValueChanged<bool> onShuffle;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback? onNext;
  final ValueChanged<LoopMode> onLoop;
  final int currentIndex;
  final int totalCount;

  const _TransportControls({
    required this.player,
    required this.onShuffle,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onLoop,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<bool>(
              stream: player.shuffleModeEnabledStream,
              builder: (context, snapshot) {
                final shuffleOn = snapshot.data ?? false;
                return GoldIconButton(
                  icon: Icons.shuffle,
                  size: 46,
                  iconSize: 20,
                  iconColor: shuffleOn
                      ? AppColors.goldLight
                      : AppColors.textSecondary,
                  onTap: () => onShuffle(!shuffleOn),
                );
              },
            ),
            GoldIconButton(
              icon: Icons.skip_previous_rounded,
              size: 56,
              iconSize: 26,
              onTap: onPrevious,
            ),
            // Main play/pause
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? false;
                return GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            GoldIconButton(
              icon: Icons.skip_next_rounded,
              size: 56,
              iconSize: 26,
              onTap: onNext,
            ),
            StreamBuilder<LoopMode>(
              stream: player.loopModeStream,
              builder: (context, snapshot) {
                final loopMode = snapshot.data ?? LoopMode.off;
                IconData icon;
                Color? color;
                switch (loopMode) {
                  case LoopMode.off:
                    icon = Icons.repeat;
                    color = AppColors.textSecondary;
                    break;
                  case LoopMode.one:
                    icon = Icons.repeat_one;
                    color = AppColors.goldLight;
                    break;
                  case LoopMode.all:
                    icon = Icons.repeat;
                    color = AppColors.goldLight;
                    break;
                }
                return GoldIconButton(
                  icon: icon,
                  size: 46,
                  iconSize: 20,
                  iconColor: color,
                  onTap: () {
                    final modes = [
                      LoopMode.off,
                      LoopMode.all,
                      LoopMode.one,
                    ];
                    final nextIndex =
                        (modes.indexOf(loopMode) + 1) % modes.length;
                    onLoop(modes[nextIndex]);
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '${currentIndex + 1} / $totalCount',
          style: AppType.smallMuted,
        ),
      ],
    );
  }
}