import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32); // Verde scuro / Forest Green
  static const Color accentColor = Color(0xFF4CAF50); // Verde brillante
  static const Color backgroundColor = Color(0xFFD6E3D6); // Verde pastello più marcato per lo sfondo
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        titleMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
