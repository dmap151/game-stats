import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Dark Mode Cinematic Brand Colors ---
  static const Color darkScaffold = Color(0xFF0D0F14); // Deep graphite / obsidian
  static const Color darkSurface = Color(0xFF161822); // Card surface
  static const Color darkSurfaceContainerLowest = Color(0xFF0F1118);
  static const Color darkSurfaceContainerLow = Color(0xFF13151F);
  static const Color darkSurfaceContainer = Color(0xFF1A1D28);
  static const Color darkSurfaceContainerHigh = Color(0xFF222635);
  static const Color darkSurfaceContainerHighest = Color(0xFF2C3244);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkOutlineVariant = Color(0xFF282E3E);

  // Vivid Signaling Colors (Letterboxd / Media Tracking Inspired)
  // Blue: Primary brand, focus, links
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueContainer = Color(0xFF1E3A8A);
  static const Color onPrimaryBlueContainer = Color(0xFFDBEAFE);

  // Green: Completed matches, victories, high scores
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentGreenContainer = Color(0xFF064E3B);
  static const Color onAccentGreenContainer = Color(0xFFA7F3D0);

  // Orange: Highlights, stars, watchlist, podium
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeContainer = Color(0xFF78350F);
  static const Color onAccentOrangeContainer = Color(0xFFFFEDD5);

  // Error Red
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedContainer = Color(0xFF7F1D1D);

  // --- Light Mode Colors ---
  static const Color lightScaffold = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E8F0);
  static const Color lightOutline = Color(0xFF94A3B8);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightPrimaryContainer = Color(0xFFDBEAFE);
  static const Color lightOnPrimaryContainer = Color(0xFF1E3A8A);

  static const Color lightSecondary = Color(0xFFD97706);
  static const Color lightSecondaryContainer = Color(0xFFFEF3C7);

  static const Color lightTertiary = Color(0xFF059669);
  static const Color lightTertiaryContainer = Color(0xFFD1FAE5);

  static TextTheme _buildTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 52 / 44,
        letterSpacing: -0.03,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 38 / 30,
        letterSpacing: -0.02,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        letterSpacing: -0.01,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.01,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.02,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.02,
        color: onSurfaceVariant,
      ),
    );
  }

  static ThemeData get darkTheme {
    const onSurface = Color(0xFFF8FAFC);
    const onSurfaceVariant = Color(0xFF94A3B8);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: primaryBlueContainer,
      onPrimaryContainer: onPrimaryBlueContainer,
      secondary: accentOrange,
      onSecondary: Colors.black,
      secondaryContainer: accentOrangeContainer,
      onSecondaryContainer: onAccentOrangeContainer,
      tertiary: accentGreen,
      onTertiary: Colors.black,
      tertiaryContainer: accentGreenContainer,
      onTertiaryContainer: onAccentGreenContainer,
      error: errorRed,
      onError: Colors.white,
      errorContainer: errorRedContainer,
      onErrorContainer: Color(0xFFFEE2E2),
      surface: darkSurface,
      onSurface: onSurface,
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainerLow: darkSurfaceContainerLow,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkScaffold,
      textTheme: _buildTextTheme(
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkOutlineVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        modalBackgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkOutlineVariant, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkOutlineVariant,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    const onSurface = Color(0xFF0F172A);
    const onSurfaceVariant = Color(0xFF475569);

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: lightOnPrimaryContainer,
      secondary: lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: lightSecondaryContainer,
      onSecondaryContainer: Color(0xFF78350F),
      tertiary: lightTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: lightTertiaryContainer,
      onTertiaryContainer: Color(0xFF064E3B),
      error: errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: lightSurface,
      onSurface: onSurface,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8FAFC),
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHigh: Color(0xFFE2E8F0),
      surfaceContainerHighest: lightSurfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightScaffold,
      textTheme: _buildTextTheme(
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightOutlineVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        modalBackgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightOutlineVariant,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
