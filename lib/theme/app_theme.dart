import 'package:flutter/material.dart';

class AppTheme {
  // ================================================================
  // SONEXA COLORS
  // ================================================================

  static const Color background = Color(0xFF07070D);
  static const Color surface = Color(0xFF111017);
  static const Color surfaceLight = Color(0xFF17131F);
  static const Color surfaceLighter = Color(0xFF201A2A);

  static const Color primary = Color(0xFF9B5CFF);
  static const Color primaryLight = Color(0xFFB77CFF);
  static const Color primaryDark = Color(0xFF7138C8);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA8A0B3);
  static const Color textMuted = Color(0xFF70677C);

  static const Color divider = Color(0xFF2A2235);
  static const Color border = Color(0xFF29232F);

  // ================================================================
  // LIGHT COLORS
  // ================================================================

  static const Color lightBackground = Color(0xFFF8F6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1ECF7);

  static const Color lightTextPrimary = Color(0xFF17131D);
  static const Color lightTextSecondary = Color(0xFF6F6878);
  static const Color lightTextMuted = Color(0xFF938B9D);

  static const Color lightDivider = Color(0xFFE3DDE9);

  // ================================================================
  // DARK THEME
  // ================================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primaryLight,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),

    // --------------------------------------------------------------
    // APP BAR
    // --------------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),

    // --------------------------------------------------------------
    // TEXT
    // --------------------------------------------------------------

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),

      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),

      displaySmall: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),

      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),

      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),

      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),

      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: TextStyle(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 15,
        height: 1.4,
      ),

      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 13,
        height: 1.4,
      ),

      bodySmall: TextStyle(
        color: textMuted,
        fontSize: 11,
        height: 1.3,
      ),

      labelLarge: TextStyle(
        color: textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),

      labelMedium: TextStyle(
        color: textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),

      labelSmall: TextStyle(
        color: textMuted,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),

    // --------------------------------------------------------------
    // INPUT FIELDS
    // --------------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,

      hintStyle: const TextStyle(
        color: textMuted,
        fontSize: 13,
      ),

      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 13,
      ),

      floatingLabelStyle: const TextStyle(
        color: primaryLight,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: border,
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: border,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primary,
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.4,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // ELEVATED BUTTON
    // --------------------------------------------------------------

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // OUTLINED BUTTON
    // --------------------------------------------------------------

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        side: const BorderSide(
          color: border,
          width: 1,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // TEXT BUTTON
    // --------------------------------------------------------------

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,

        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // --------------------------------------------------------------
    // CARD
    // --------------------------------------------------------------

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,

      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(
          color: border,
          width: 1,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // DIVIDER
    // --------------------------------------------------------------

    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),

    // --------------------------------------------------------------
    // ICONS
    // --------------------------------------------------------------

    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 23,
    ),

    // --------------------------------------------------------------
    // BOTTOM NAVIGATION
    // --------------------------------------------------------------

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMuted,

      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),

      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),

      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // --------------------------------------------------------------
    // NAVIGATION BAR — MATERIAL 3
    // --------------------------------------------------------------

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      indicatorColor: primary.withValues(alpha: 0.18),

      height: 68,

      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryLight,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            );
          }

          return const TextStyle(
            color: textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          );
        },
      ),

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryLight,
              size: 22,
            );
          }

          return const IconThemeData(
            color: textMuted,
            size: 21,
          );
        },
      ),
    ),

    // --------------------------------------------------------------
    // SWITCH
    // --------------------------------------------------------------

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }

          return textMuted;
        },
      ),

      trackColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }

          return surfaceLighter;
        },
      ),

      trackOutlineColor: WidgetStateProperty.all(
        Colors.transparent,
      ),
    ),

    // --------------------------------------------------------------
    // SLIDER
    // --------------------------------------------------------------

    sliderTheme: const SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: divider,
      thumbColor: primaryLight,

      trackHeight: 3,

      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: 6,
      ),
    ),

    // --------------------------------------------------------------
    // PROGRESS INDICATOR
    // --------------------------------------------------------------

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: divider,
    ),

    // --------------------------------------------------------------
    // DIALOG
    // --------------------------------------------------------------

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: border,
        ),
      ),

      titleTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),

      contentTextStyle: const TextStyle(
        color: textSecondary,
        fontSize: 13,
        height: 1.4,
      ),
    ),

    // --------------------------------------------------------------
    // SNACKBAR
    // --------------------------------------------------------------

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 13,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),

      behavior: SnackBarBehavior.floating,
    ),

    // --------------------------------------------------------------
    // TOOLTIP
    // --------------------------------------------------------------

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceLighter,
        borderRadius: BorderRadius.circular(8),
      ),

      textStyle: const TextStyle(
        color: textPrimary,
        fontSize: 11,
      ),
    ),
  );

  // ================================================================
  // LIGHT THEME
  // ================================================================

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor: lightBackground,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primaryDark,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
    ),

    // --------------------------------------------------------------
    // APP BAR
    // --------------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // --------------------------------------------------------------
    // TEXT
    // --------------------------------------------------------------

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),

      displayMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),

      displaySmall: TextStyle(
        color: lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),

      headlineLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),

      headlineMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),

      headlineSmall: TextStyle(
        color: lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        color: lightTextPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: TextStyle(
        color: lightTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 15,
      ),

      bodyMedium: TextStyle(
        color: lightTextSecondary,
        fontSize: 13,
      ),

      bodySmall: TextStyle(
        color: lightTextMuted,
        fontSize: 11,
      ),

      labelLarge: TextStyle(
        color: lightTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),

      labelMedium: TextStyle(
        color: lightTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),

      labelSmall: TextStyle(
        color: lightTextMuted,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),

    // --------------------------------------------------------------
    // INPUT
    // --------------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,

      hintStyle: const TextStyle(
        color: lightTextMuted,
        fontSize: 13,
      ),

      labelStyle: const TextStyle(
        color: lightTextSecondary,
        fontSize: 13,
      ),

      floatingLabelStyle: const TextStyle(
        color: primaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      prefixIconColor: lightTextSecondary,
      suffixIconColor: lightTextSecondary,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: lightDivider,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: lightDivider,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primary,
          width: 1.4,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // BUTTON
    // --------------------------------------------------------------

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        side: const BorderSide(
          color: lightDivider,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
      ),
    ),

    // --------------------------------------------------------------
    // CARD
    // --------------------------------------------------------------

    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,

      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(
          color: lightDivider,
        ),
      ),
    ),

    // --------------------------------------------------------------
    // DIVIDER
    // --------------------------------------------------------------

    dividerTheme: const DividerThemeData(
      color: lightDivider,
      thickness: 1,
    ),

    // --------------------------------------------------------------
    // ICON
    // --------------------------------------------------------------

    iconTheme: const IconThemeData(
      color: lightTextPrimary,
      size: 23,
    ),

    // --------------------------------------------------------------
    // BOTTOM NAVIGATION
    // --------------------------------------------------------------

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryDark,
      unselectedItemColor: lightTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // --------------------------------------------------------------
    // MATERIAL 3 NAVIGATION
    // --------------------------------------------------------------

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      indicatorColor: primary.withValues(alpha: 0.13),

      height: 68,

      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryDark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            );
          }

          return const TextStyle(
            color: lightTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          );
        },
      ),

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryDark,
              size: 22,
            );
          }

          return const IconThemeData(
            color: lightTextMuted,
            size: 21,
          );
        },
      ),
    ),

    // --------------------------------------------------------------
    // SWITCH
    // --------------------------------------------------------------

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }

          return lightTextMuted;
        },
      ),

      trackColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }

          return lightSurfaceSecondary;
        },
      ),
    ),

    // --------------------------------------------------------------
    // SLIDER
    // --------------------------------------------------------------

    sliderTheme: const SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: lightDivider,
      thumbColor: primaryDark,
      trackHeight: 3,

      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: 6,
      ),
    ),

    // --------------------------------------------------------------
    // PROGRESS
    // --------------------------------------------------------------

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: lightDivider,
    ),

    // --------------------------------------------------------------
    // DIALOG
    // --------------------------------------------------------------

    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      surfaceTintColor: Colors.transparent,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: lightDivider,
        ),
      ),

      titleTextStyle: const TextStyle(
        color: lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),

      contentTextStyle: const TextStyle(
        color: lightTextSecondary,
        fontSize: 13,
      ),
    ),

    // --------------------------------------------------------------
    // SNACKBAR
    // --------------------------------------------------------------

    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightTextPrimary,

      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),

      behavior: SnackBarBehavior.floating,
    ),
  );
}