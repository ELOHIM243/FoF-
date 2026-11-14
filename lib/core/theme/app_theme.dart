import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0A7C6E);
  static const secondary = Color(0xFF1E3A5F);
  static const accent = Color(0xFFFFB020);
  static const lightBg = Color(0xFFF7F9FA);
  static const darkBg = Color(0xFF101418);
  static const darkCard = Color(0xFF1E252B);
  static const online = Color(0xFF22C55E);
  static const danger = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
          foregroundColor: Colors.black87,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkCard,
          elevation: 0.5,
          centerTitle: false,
        ),
        cardColor: AppColors.darkCard,
      );
}
