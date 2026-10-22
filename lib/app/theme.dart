import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Theme Colors
  static const darkBackground = Color(0xFF09090B);
  static const darkForeground = Color(0xFFFAFAFA);
  static const darkCard = Color(0xFF18181B);
  static const darkPrimary = Color(0xFFE8DEFF);
  static const darkPrimaryForeground = Color(0xFF150A29);
  static const darkSecondary = Color(0xFF27272A);
  static const darkMuted = Color(0xFF27272A);
  static const darkMutedForeground = Color(0xFFA1A1AA);
  static const darkAccent = Color(0xFFB3D9FF);
  static const darkDestructive = Color(0xFF7F1D1D);
  static const darkBorder = Color(0xFF27272A);
  static const darkRing = Color(0xFFE8DEFF);

  // Light Theme Colors
  static const lightBackground = Color(0xFFFAFAFC);
  static const lightForeground = Color(0xFF09090B);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF8B5CF6);
  static const lightAccent = Color(0xFFDBEDFF);
  static const lightDestructive = Color(0xFFDC2626);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double base = 12.8;
  static const BorderRadius baseRadius = BorderRadius.all(Radius.circular(base));
}

class AppTypography {
  // Add typography styles here if needed
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkBackground,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkPrimaryForeground,
        secondary: AppColors.darkSecondary,
        error: AppColors.darkDestructive,
      ),
      textTheme: baseTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.baseRadius,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightBackground,
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightAccent,
        error: AppColors.lightDestructive,
      ),
      textTheme: baseTextTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.baseRadius,
        ),
      ),
    );
  }
}
