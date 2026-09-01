import 'package:flutter/material.dart';
import '../data/sample_lessons.dart';
import '../models/lesson.dart';
import '../screens/player_screen.dart';
import '../services/duration_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_box.dart';
import '../widgets/gold_icon_button.dart';
import '../widgets/lesson_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCourse = 'All';

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

  List<String> get _courses {
    final courses =
        sampleLessons.map((l) => l.course).toSet().toList();
    courses.sort();
    return ['All', ...courses];
  }

  List<Lesson> get _lessons {
    if (_selectedCourse == 'All') return sampleLessons;
    return sampleLessons
        .where((l) => l.course == _selectedCourse)
        .toList();
  }

  void _openPlayer(Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlayerScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = sampleLessons.fold<Duration>(
      Duration.zero,
      (sum, l) => sum + l.duration,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    AppHeader(
                      tagline: 'MALAMA ZAINAB JAAFAR',
                      title: 'Muhadara 2',
                      subtitle:
                          '${sampleLessons.length} lessons - offline audio lectures',
                      artworkPath: 'assets/images/scholar_zainab.png',
                    ),
                    const SizedBox(height: 16),
                    _HeroCard(
                      totalLessons: sampleLessons.length,
                      totalDuration: totalDuration,
                    ),
                    const SizedBox(height: 20),

                    // Filter chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GoldFilterChip(
                                label: course,
                                selected: _selectedCourse == course,
                                onTap: () => setState(
                                    () => _selectedCourse = course),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: _selectedCourse == 'All'
                            ? 'All Lessons'
                            : _selectedCourse,
                        trailing: '${_lessons.length}',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lessons list with ads
                    if (_lessons.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No lessons in this category yet.',
                            style: AppType.bodySecondary,
                          ),
                        ),
                      )
                    else
                      ..._lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lesson = entry.value;
                        final showBanner =
                            (index + 1) % 4 == 0 &&
                                index < _lessons.length - 1;
                        return Column(
                          children: [
                            LessonCard(
                              lesson: lesson,
                              lessonNumber: index + 1,
                              onTap: () => _openPlayer(lesson),
                            ),
                            if (showBanner)
                              BannerAdBox(
                                index: index,
                              ),
                          ],
                        );
                      }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Persistent mini player
              const MiniPlayer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int totalLessons;
  final Duration totalDuration;

  const _HeroCard({
    required this.totalLessons,
    required this.totalDuration,
  });

  String get _durationLabel {
    final h = totalDuration.inHours;
    final m = totalDuration.inMinutes.remainder(60);
    if (h > 0) return '$h hr ${m.toString().padLeft(2, '0')} min';
    return '${totalDuration.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Artwork
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
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
                      color: AppColors.gold, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Lectures Collection',
                  style: AppType.brandTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Muhadara 2',
                  style: AppType.screenTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat(value: '$totalLessons', label: 'Lectures'),
                    const SizedBox(width: 16),
                    _Stat(value: _durationLabel, label: 'Playback'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.goldLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppType.smallMuted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}