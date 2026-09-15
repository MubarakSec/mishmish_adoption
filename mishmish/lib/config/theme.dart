import 'package:flutter/material.dart';

/// Lightweight design system: single source of truth for colors,
/// typography, spacing and radii. Screens should reference these
/// instead of hardcoding values.
class AppColors {
  static const primary = Color(0xFFFF6B6B);
  static const primarySoft = Color(0xFFFFF0F0);
  static const secondary = Color(0xFF4ECDC4);
  static const background = Color(0xFFF7F7F7);
  static const surface = Colors.white;
  static const card = Colors.white;
  static const text = Color(0xFF2D3436);
  static const textLight = Color(0xFF636E72);
  static const border = Color(0xFFDDDDDD);
  static const error = Color(0xFFE74C3C);
  static const success = Colors.green;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  static const subtitle = TextStyle(fontSize: 15, color: AppColors.textLight);
  static const body = TextStyle(fontSize: 15, color: AppColors.text);
  static const caption = TextStyle(fontSize: 13, color: AppColors.textLight);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
