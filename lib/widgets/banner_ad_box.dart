import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ads_service.dart';
import '../theme/app_theme.dart';

/// Wraps the native AdMob banner PlatformView with clear separation from
/// app controls so it cannot be mistaken for content or cause accidental taps.
class BannerAdBox extends StatelessWidget {
  final int index;
  final double height;

  const BannerAdBox({super.key, required this.index, this.height = 60});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Advertisement',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              color: AppColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: height - 20,
            child: AndroidView(
              viewType: AdsService.bannerViewType,
              creationParams: {'index': index},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        ],
      ),
    );
  }
}