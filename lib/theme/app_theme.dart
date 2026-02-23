import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- SJCET Brand Colors ---
  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color secondaryRed = Color(0xFFD32F2F);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color charcoal = Color(0xFF263238);

  // --- Background Gradients (Light Academic Theme) ---
  static const List<Color> mainBackgroundGradient = [
    pureWhite,
    offWhite,
    Color(0xFFFFEBEE), // Subtle red tint at bottom
  ];

  static const List<double> mainBackgroundStops = [0.0, 0.7, 1.0];

  // --- Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: goldAccent,
        surface: pureWhite,
        onPrimary: Colors.white,
        onSurface: charcoal,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: charcoal,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: charcoal,
          letterSpacing: 4,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: primaryRed,
          letterSpacing: 2,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: charcoal.withValues(alpha: 0.8),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: charcoal.withValues(alpha: 0.7),
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: charcoal.withValues(alpha: 0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Keeping darkTheme for backward compatibility if needed, but updated to match branding
  static ThemeData get darkTheme =>
      lightTheme; // For now, let's enforce light theme as requested
}
