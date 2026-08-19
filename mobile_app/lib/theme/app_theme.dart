import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';

class TrimeTheme {
  TrimeTheme._();

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: TrimeColors.primaryNavy,
        onPrimary: Colors.white,
        secondary: TrimeColors.secondaryBlue,
        onSecondary: Colors.white,
        surface: TrimeColors.surface,
        error: TrimeColors.dangerRed,
      ),
      scaffoldBackgroundColor: TrimeColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: TrimeColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TrimeColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TrimeColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TrimeColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TrimeColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TrimeColors.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TrimeColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TrimeColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TrimeColors.textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TrimeColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: TrimeColors.surface,
        foregroundColor: TrimeColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TrimeColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: TrimeColors.surface,
        elevation: TrimeSpacing.elevationNav,
        selectedItemColor: TrimeColors.primaryNavy,
        unselectedItemColor: TrimeColors.textMuted,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: TrimeColors.surface,
        elevation: TrimeSpacing.elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: TrimeSpacing.radiusMd,
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: TrimeColors.surfaceAlt,
        selectedColor: TrimeColors.primaryNavy,
        disabledColor: TrimeColors.surfaceAlt,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: TrimeColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TrimeSpacing.md,
          vertical: TrimeSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: TrimeSpacing.radiusPill,
          side: BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrimeColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TrimeSpacing.lg,
          vertical: TrimeSpacing.md,
        ),
        hintStyle: GoogleFonts.poppins(
          color: TrimeColors.textMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusPill,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusPill,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TrimeSpacing.radiusPill,
          borderSide: const BorderSide(
            color: TrimeColors.secondaryBlue,
            width: 1.5,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TrimeColors.surfaceAlt,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: TrimeColors.primaryNavy,
        unselectedLabelColor: TrimeColors.textMuted,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          color: TrimeColors.secondaryBlue.withValues(alpha: 0.15),
          borderRadius: TrimeSpacing.radiusPill,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
