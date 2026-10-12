import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // MT ALCHEMY BRAND COLORS
  // =========================

  static const Color deepBlue = Color(0xFF172A4D);
  static const Color softYellow = Color(0xFFF4D35E);
  static const Color purple = Color(0xFF7657A6);

  static const Color background = Color(0xFFF7F8FA);
  static const Color white = Colors.white;
  static const Color darkText = Color(0xFF172033);
  static const Color greyText = Color(0xFF667085);

  // =========================
  // APP THEME
  // =========================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.light(
      primary: deepBlue,
      onPrimary: white,

      secondary: purple,
      onSecondary: white,

      tertiary: softYellow,
      onTertiary: deepBlue,

      surface: white,
      onSurface: darkText,

      error: Color(0xFFD92D20),
      onError: white,
    ),

    // =========================
    // TYPOGRAPHY
    // =========================

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: darkText,
        height: 1.1,
      ),

      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: darkText,
      ),

      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),

      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),

      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),

      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkText,
        height: 1.5,
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: greyText,
        height: 1.5,
      ),

      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),

    // =========================
    // APP BAR
    // =========================

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: darkText,
      elevation: 0,
      centerTitle: false,
    ),

    // =========================
    // ELEVATED BUTTON
    // =========================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBlue,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // =========================
    // OUTLINED BUTTON
    // =========================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: deepBlue,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ),
        side: const BorderSide(
          color: deepBlue,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // =========================
    // INPUT FIELDS
    // =========================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: deepBlue,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD92D20),
        ),
      ),

      labelStyle: const TextStyle(
        color: greyText,
        fontSize: 14,
      ),
    ),

    // =========================
    // CARD
    // =========================

    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // =========================
    // DIVIDER
    // =========================

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE4E7EC),
      thickness: 1,
    ),
  );
}