import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color primaryPurple = Color(0xFF3F3D89);
  static const Color pureBlack = Color(0xFF000000);
  static const Color warmBrown = Color(0xFF2C1F1F);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color goldAccent = Color(0xFFFFD892);

  // --- Background Gradients ---
  static const List<Color> mainBackgroundGradient = [
    primaryPurple,
    pureBlack,
    warmBrown,
  ];

  static const List<double> mainBackgroundStops = [0.0, 0.45, 1.0];

  // --- Theme Data ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,
      colorScheme: const ColorScheme.dark(
        primary: accentIndigo,
        secondary: goldAccent,
        surface: Color(0xFF1A1A1A),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 4,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 5,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: Colors.white.withValues(alpha: 0.3),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
