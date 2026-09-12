import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_copy.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/atmosphere.dart';
import '../widgets/brand_mark.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _intro;
  Timer? _gate;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _gate = Timer(const Duration(milliseconds: 2600), _openHome);
  }

  @override
  void dispose() {
    _gate?.cancel();
    _pulse.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, animation, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
    return Scaffold(
      body: NightBackdrop(
        child: SafeArea(
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(fade),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = _pulse.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _ring(220 + (12 * t), 0.16 + (0.12 * t)),
                          _ring(168 + (8 * (1 - t)), 0.22 + (0.1 * (1 - t))),
                          child!,
                        ],
                      );
                    },
                    child: const BrandMark(size: 118),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    AppCopy.brand.toUpperCase(),
                    style: AppTheme.cinzel(size: 34, letterSpacing: 7),
                  ),
                  const SizedBox(height: 16),
                  const GoldHairline(indent: 88),
                  const SizedBox(height: 16),
                  Text(
                    AppCopy.tagline,
                    style: AppTheme.elMessiri(
                      size: 20,
                      color: AppColors.goldSoft,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(flex: 4),
                  Text(
                    AppCopy.cinemaLine,
                    style: AppTheme.cairo(size: 13, color: AppColors.muted, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: opacity.clamp(0.0, 1.0)),
          width: 1,
        ),
      ),
    );
  }
}
