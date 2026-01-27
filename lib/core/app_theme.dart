import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color accentColor = Color(0xFF10B981); // Emerald
  static const Color backgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color surfaceColor = Color(0xFF1E293B); // Slate 800
  static const Color errorColor = Color(0xFFEF4444); // Red 500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineMedium: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}
