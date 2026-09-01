import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A circular navy/gold icon button used across the player and navigation.
class GoldIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool filled;

  const GoldIconButton({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 22,
    this.onTap,
    this.iconColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (filled ? AppColors.primary : AppColors.gold);
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.goldGradient : AppColors.surfaceGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled
                ? Colors.transparent
                : AppColors.gold.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? color : color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Primary filled gold action button with navy text.
class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expanded;

  const GoldButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (expanded) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}

/// Filter chip following the navy/gold language.
class GoldFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GoldFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldGradient : null,
          color: selected ? null : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.border.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
