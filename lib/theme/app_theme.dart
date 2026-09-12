import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Cairo',
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.night,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.night,
        secondary: AppColors.goldSoft,
        surface: AppColors.charcoal,
        onSurface: AppColors.cream,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.night.withValues(alpha: 0.92),
        foregroundColor: AppColors.cream,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: elMessiri(size: 22, weight: FontWeight.w600),
      ),
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        displayLarge: cinzel(size: 40, weight: FontWeight.w600),
        headlineMedium: elMessiri(size: 28, weight: FontWeight.w600),
        titleLarge: elMessiri(size: 22, weight: FontWeight.w600),
        titleMedium: cairo(size: 17, weight: FontWeight.w600),
        bodyLarge: cairo(size: 16, height: 1.85),
        bodyMedium: cairo(size: 15, height: 1.8, color: AppColors.muted),
        labelLarge: cairo(size: 15, weight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.graphite,
        hintStyle: cairo(size: 14, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.ink,
        elevation: 0,
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  static double _wght(FontWeight weight) => weight.value.toDouble();

  static TextStyle cairo({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.cream,
    double height = 1.6,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [FontVariation('wght', _wght(weight))],
    );
  }

  static TextStyle elMessiri({
    double size = 22,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.cream,
    double height = 1.35,
  }) {
    return TextStyle(
      fontFamily: 'ElMessiri',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      fontVariations: [FontVariation('wght', _wght(weight))],
    );
  }

  static TextStyle cinzel({
    double size = 28,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.gold,
    double letterSpacing = 4,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: 'Cinzel',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [FontVariation('wght', _wght(weight))],
    );
  }
}
