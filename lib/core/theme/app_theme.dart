import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0F172A);
  static const Color primary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF22C55E);
  static const Color surface = Color(0xFF1E293B);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: Colors.white, displayColor: Colors.white)
        .copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: accent,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            letterSpacing: 0.5,
            color: Colors.white,
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            letterSpacing: 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: 18,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: accent.withValues(alpha: 0.2),
      secondarySelectedColor: accent,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: accent),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
  );
}
