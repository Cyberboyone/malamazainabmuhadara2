import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium seekable progress bar used by the full player.
///
/// Renders a gold-filled track over a dark track with a drag handle.
/// The parent supplies [fraction] (0..1) and an optional [onSeek] callback
/// receiving the fractional position tapped/dragged to.
class AudioProgressBar extends StatelessWidget {
  final double fraction;
  final ValueChanged<double>? onSeek;
  final double height;
  final bool showThumb;

  const AudioProgressBar({
    super.key,
    required this.fraction,
    this.onSeek,
    this.height = 6,
    this.showThumb = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);
    final thumbSize = height + 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final thumbX =
            (barWidth * clamped - thumbSize / 2).clamp(0.0, barWidth - thumbSize);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _seek(details.localPosition.dx, barWidth),
          onHorizontalDragUpdate: (details) =>
              _seek(details.localPosition.dx, barWidth),
          child: SizedBox(
            height: height + (showThumb ? 12 : 4),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track background
                Positioned(
                  left: 0,
                  right: 0,
                  top: 4,
                  height: height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(height / 2),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                // Filled track
                Positioned(
                  left: 0,
                  top: 4,
                  height: height,
                  width: barWidth * clamped,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
                if (showThumb)
                  Positioned(
                    left: thumbX,
                    top: 2 + (height - thumbSize) / 2,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _seek(double dx, double width) {
    if (onSeek == null || width <= 0) return;
    final ratio = (dx / width).clamp(0.0, 1.0);
    onSeek!(ratio);
  }
}

/// Formats a [Duration] as m:ss or h:mm:ss.
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}
