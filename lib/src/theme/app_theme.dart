import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF171214);
  static const backgroundAlt = Color(0xFF120D0F);
  static const surface = Color(0xFF241E20);
  static const surfaceLow = Color(0xFF201A1C);
  static const surfaceHigh = Color(0xFF2F282A);
  static const surfaceHighest = Color(0xFF3A3335);
  static const surfaceBright = Color(0xFF3E3739);
  static const primary = Color(0xFFFFB598);
  static const primaryStrong = Color(0xFFEF8354);
  static const primaryDeep = Color(0xFF7D2D03);
  static const secondary = Color(0xFF61D8D8);
  static const onSurface = Color(0xFFECDFE2);
  static const onSurfaceMuted = Color(0xFFDCC1B7);
  static const outline = Color(0xFFA48C82);
  static const outlineVariant = Color(0xFF56433B);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const black = Color(0xFF090607);

  static const primaryGradient = LinearGradient(
    colors: [primary, primaryStrong],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.primaryStrong,
      onPrimaryContainer: AppColors.black,
      secondary: AppColors.secondary,
      onSecondary: AppColors.black,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    final baseText = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.epilogue(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          height: 0.95,
          letterSpacing: -1.4,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.epilogue(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 0.95,
          letterSpacing: -1.1,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.epilogue(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -0.8,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.epilogue(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -0.6,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.epilogue(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.onSurface,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.onSurfaceMuted,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.onSurfaceMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        space: 0,
        thickness: 0,
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundAlt,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceMuted.withValues(alpha: 0.7),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.onSurfaceMuted,
        ),
        border: _inputBorder(AppColors.outlineVariant.withValues(alpha: 0.18)),
        enabledBorder: _inputBorder(
          AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
        focusedBorder: _inputBorder(AppColors.primaryStrong),
        errorBorder: _inputBorder(AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceBright,
          disabledForegroundColor: AppColors.onSurfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.onSurface,
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.55),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceLow,
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }
}
