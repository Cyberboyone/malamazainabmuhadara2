import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section heading with an optional gold accent bar.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.goldRing,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: AppType.sectionTitle),
        ),
        if (trailing != null)
          Text(trailing!, style: AppType.smallMuted),
      ],
    );
  }
}
