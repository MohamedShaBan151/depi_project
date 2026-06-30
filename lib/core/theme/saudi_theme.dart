// ─────────────────────────────────────────────────────────────────────────────
// saudi_theme.dart  –  Noon Saudi palette + ThemeData
//
// Primary  : #FEF200  (Noon yellow)
// Secondary: #006C35  (Saudi green)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFFEF200); // Noon yellow
  static const secondary = Color(0xFF006C35); // Saudi green
  static const darkGreen = Color(0xFF004D26);
  static const lightYellow = Color(0xFFFFFBB0);

  // UI Aliases
  static const gold = primary;
  static const lightGold = lightYellow;
  static const accentGold = primary;

  // Neutral
  static const surface = Color(0xFFFAFAFA);
  static const card = Colors.white;
  static const divider = Color(0xFFEEEEEE);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF666666);
  static const ink = Color(0xFF111111);

  // Semantic
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF2E7D32);
  static const discount = Color(0xFFE53935);
  static const teal = Color(0xFF1a5c5c);
  static const slate = Color(0xFF1a2a4a);
}

abstract final class SaudiTheme {
  // ── System chrome ─────────────────────────────────────────────────────────
  static const _systemOverlay = SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.dark, // dark icons on yellow
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static SystemUiOverlayStyle get overlayStyle => _systemOverlay;

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          primary: AppColors.secondary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: AppColors.darkGreen,
          error: AppColors.error,
        ),

        // ── Typography ─────────────────────────────────────────────────────────
        textTheme: GoogleFonts.cairoTextTheme().copyWith(
          displayLarge: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          titleLarge: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.cairo(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),

        // ── AppBar ──────────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkGreen,
          elevation: 0,
          systemOverlayStyle: _systemOverlay,
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkGreen),
        ),

        // ── Buttons ─────────────────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // ── Cards ───────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),

        // ── Chips ───────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightYellow,
          selectedColor: AppColors.primary,
          labelStyle: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),

        // ── Bottom nav ──────────────────────────────────────────────────────────
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 12,
          selectedLabelStyle: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
        ),

        scaffoldBackgroundColor: AppColors.surface,
      );
}
