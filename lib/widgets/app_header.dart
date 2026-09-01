import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Branding header used on the home screen.
class AppHeader extends StatelessWidget {
  final String title;
  final String tagline;
  final String? subtitle;
  final String? artworkPath;
  final VoidCallback? onArtworkTap;

  const AppHeader({
    super.key,
    required this.title,
    required this.tagline,
    this.subtitle,
    this.artworkPath,
    this.onArtworkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tagline,
                  style: AppType.brandTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: AppType.heroTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppType.bodySecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (artworkPath != null) ...[
            const SizedBox(width: 14),
            _ArtworkThumb(path: artworkPath!, onTap: onArtworkTap),
          ],
        ],
      ),
    );
  }
}

class _ArtworkThumb extends StatelessWidget {
  final String path;
  final VoidCallback? onTap;
  const _ArtworkThumb({required this.path, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = 54.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.goldRing,
        ),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.mic,
                  color: AppColors.gold, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
