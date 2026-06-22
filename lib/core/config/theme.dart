import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme {
  AppTheme._();

  // Color Palette from Minimalist Banking App Reference
  static const Color primaryColor = Color(0xFF111111); // Black
  static const Color secondaryColor = Color(0xFFF6A071); // Soft Orange
  static const Color accentGreen = Color(0xFF7BA05B); // Soft Green
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color surfaceColor = Color(0xFFF6F6F6); // Off-white/Light Gray
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF888888);
  static const Color errorColor = Color(0xFFE53935);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static final TextTheme _textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      color: textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      color: textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final TextTheme _darkTextTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      color: darkTextPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      color: darkTextSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: _textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0, // Shadows will be custom per card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Pill shape
        ),
        textStyle: _textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Pill shape
        ),
        textStyle: _textTheme.labelLarge?.copyWith(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Pill shape for inputs
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      hintStyle: _textTheme.bodyLarge?.copyWith(color: textSecondary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: secondaryColor,
      secondary: accentGreen,
      surface: darkSurfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    textTheme: _darkTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: darkTextPrimary),
      titleTextStyle: _darkTextTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: _darkTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrimary,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: Color(0xFF444444), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: _darkTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      hintStyle: _darkTextTheme.bodyMedium,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),
  );
}
