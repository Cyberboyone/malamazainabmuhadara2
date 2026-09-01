import 'package:flutter/material.dart';

/// Builds the [ThemeData] used across the Malama Zainab app family.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
  );
}

/// Premium navy-and-gold design system for the Malama Zainab app family.
///
/// Replaces the old light "neumorphic" appearance with a consistent
/// deep-navy + gold visual language shared across all Malama Zainab apps.
class AppColors {
  AppColors._();

  // Primary navy / midnight palette
  static const primary = Color(0xFF0B2A44);
  static const background = Color(0xFF081E33);
  static const backgroundAlt = Color(0xFF0C2A46);
  static const surface = Color(0xFF0F3250);
  static const surfaceLight = Color(0xFF143C5E);
  static const border = Color(0xFF24567F);

  // Gold accent
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFE8C766);
  static const goldDark = Color(0xFFB08D2F);

  // Text
  static const textPrimary = Color(0xFFF7F3EA);
  static const textSecondary = Color(0xFFAFC3D6);
  static const textMuted = Color(0xFF7C94AB);

  // Semantic
  static const success = Color(0xFF57C98A);
  static const error = Color(0xFFE56B6B);

  // Gradients
  static const Gradient scaffoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A2340),
      Color(0xFF081E33),
      Color(0xFF061828),
    ],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );

  static const Gradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF123654), Color(0xFF0C2A46)],
  );

  static const Gradient goldRing = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [goldLight, goldDark],
  );
}

/// Spacing + shape + radii tokens.
class AppSizes {
  AppSizes._();

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 20;
  static const double spaceXl = 28;
  static const double spaceXxl = 40;

  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 12, 20, 12);
}

/// Typography tokens for the Malama Zainab apps.
class AppType {
  AppType._();

  static const TextStyle heroTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: 0.5,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle brandTagline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 2.5,
  );

  static const TextStyle lessonTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle goldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static const TextStyle smallMuted = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );
}

/// A decorative premium background with a subtle Islamic geometric feel.
class PremiumBackground extends StatelessWidget {
  final Widget child;
  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.scaffoldGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.gold.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -140,
            child: _GlowOrb(
              size: 300,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// Standard premium card surface.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLg);
    Widget card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.surfaceGradient,
        color: color,
        borderRadius: radius,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: child,
    );
    if (onTap != null) {
      card = InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Thin gold divider used between sections.
class GoldDivider extends StatelessWidget {
  final double width;
  const GoldDivider({super.key, this.width = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Animated "now playing" equalizer bars.
class PlayingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  const PlayingIndicator({
    super.key,
    this.size = 16,
    this.color = AppColors.gold,
  });

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _bars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _bars = List.generate(
      4,
      (i) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15, 0.6 + i * 0.15, curve: Curves.easeInOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: widget.size,
          width: widget.size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                width: 2.5,
                height: widget.size * _bars[i].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
