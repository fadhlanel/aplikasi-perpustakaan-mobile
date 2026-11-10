import 'package:flutter/material.dart';

/// Design System & Tema Aplikasi Pustaka Digital
/// Mengacu 100% pada palet warna dan komponen dari 6 Layar Desain Figma.
class AppTheme {
  AppTheme._();

  // Primary Colors
  static const Color primaryNavy = Color(0xFF0D1E3A);
  static const Color primaryNavyDark = Color(0xFF0A1931);
  static const Color navyCard = Color(0xFF102A68);
  static const Color primaryBlue = Color(0xFF1E5BB5);
  static const Color accentBlue = Color(0xFF2563EB);

  // Accent & Status Colors
  static const Color cyanAccent = Color(0xFF00D2BA);
  static const Color cyanGlow = Color(0xFF22D3EE);
  static const Color mintGreen = Color(0xFF10B981);
  static const Color mintBackground = Color(0xFFE8F7F0);
  static const Color softBlueBackground = Color(0xFFEBF3FC);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amberBackground = Color(0xFFFEF3C7);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerBackground = Color(0xFFFEE2E2);

  // Neutral Background & Surface
  static const Color background = Color(0xFFF6F8FB);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryNavy,
      secondary: accentBlue,
      surface: surfaceWhite,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEF2F6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textSubtle, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
