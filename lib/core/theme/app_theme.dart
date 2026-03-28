import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────────────────────
// Color Palette — WhatsApp-meets-Telegram Aesthetic
// ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Teal accent (send bubbles, highlights)
  static const primary = Color(0xFF00BFA5);
  static const primaryDark = Color(0xFF008F7A);
  static const primaryLight = Color(0xFF4DD9C6);

  // Dark theme
  static const darkBackground = Color(0xFF0E1621);
  static const darkSurface = Color(0xFF17212B);
  static const darkCard = Color(0xFF1E2C3A);
  static const darkBubbleSend = Color(0xFF2B5278);
  static const darkBubbleReceive = Color(0xFF1E2C3A);
  static const darkInput = Color(0xFF242F3D);
  static const darkBorder = Color(0xFF2A3B4D);

  // Light theme
  static const lightBackground = Color(0xFFF0F2F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBubbleSend = Color(0xFFDCF8C6);
  static const lightBubbleReceive = Color(0xFFFFFFFF);
  static const lightInput = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE5E5E5);

  // Semantic
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA000);
  static const online = Color(0xFF4CAF50);
  static const offline = Color(0xFF9E9E9E);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8DA0B3);
  static const textHint = Color(0xFF6C7E8F);
  static const textPrimaryLight = Color(0xFF111B21);
  static const textSecondaryLight = Color(0xFF667781);
}

// ──────────────────────────────────────────────────────────────
// Typography
// ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1(BuildContext ctx) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle heading2(BuildContext ctx) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext ctx) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle caption(BuildContext ctx) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
      );

  static TextStyle button(BuildContext ctx) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      );
}

// ──────────────────────────────────────────────────────────────
// Theme Data
// ──────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.darkBubbleSend,
        secondary: AppColors.primaryLight,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dividerColor: AppColors.darkBorder,
      cardColor: AppColors.darkCard,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.lightBubbleSend,
        secondary: AppColors.primaryDark,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dividerColor: AppColors.lightBorder,
      cardColor: AppColors.lightSurface,
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );
  }
}
