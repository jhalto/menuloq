import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      tertiary: AppColors.info,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    textTheme: _textTheme(
      primary: AppColors.textPrimary,
      secondary: AppColors.textSecondary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    cardTheme: _cardTheme(
      color: AppColors.card,
      borderColor: AppColors.cardBorder,
      shadowColor: AppColors.lightShadow,
    ),

    inputDecorationTheme: _inputDecorationTheme(
      fillColor: AppColors.surface,
      borderColor: AppColors.border,
      focusedBorderColor: AppColors.accent,
      errorColor: AppColors.error,
      hintColor: AppColors.textMuted,
      textColor: AppColors.textPrimary,
    ),

    elevatedButtonTheme: _elevatedButtonTheme(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.white,
    ),

    filledButtonTheme: _filledButtonTheme(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.white,
    ),

    outlinedButtonTheme: _outlinedButtonTheme(
      foregroundColor: AppColors.primary,
      borderColor: AppColors.border,
    ),

    textButtonTheme: _textButtonTheme(AppColors.accent),

    iconTheme: const IconThemeData(color: AppColors.textSecondary),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.sidebar,
      surfaceTintColor: Colors.transparent,
    ),

    navigationBarTheme: _navigationBarTheme(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.navUnselected,
      indicatorColor: AppColors.primaryLight,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    chipTheme: _chipTheme(
      backgroundColor: AppColors.fill,
      selectedColor: AppColors.primaryLight,
      labelColor: AppColors.textPrimary,
      borderColor: AppColors.border,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      circularTrackColor: AppColors.fill,
      linearTrackColor: AppColors.fill,
    ),

    snackBarTheme: _snackBarTheme(
      backgroundColor: AppColors.textPrimary,
      contentColor: AppColors.white,
    ),

    scrollbarTheme: _scrollbarTheme(thumbColor: AppColors.textMuted),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
      tertiary: AppColors.info,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkBackground,
      onSecondary: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.black,
    ),

    textTheme: _textTheme(
      primary: AppColors.darkTextPrimary,
      secondary: AppColors.darkTextSecondary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    ),

    cardTheme: _cardTheme(
      color: AppColors.darkCard,
      borderColor: AppColors.darkCardBorder,
      shadowColor: AppColors.darkShadow,
    ),

    inputDecorationTheme: _inputDecorationTheme(
      fillColor: AppColors.darkFill,
      borderColor: AppColors.darkBorder,
      focusedBorderColor: AppColors.darkAccent,
      errorColor: AppColors.darkError,
      hintColor: AppColors.darkTextMuted,
      textColor: AppColors.darkTextPrimary,
    ),
    elevatedButtonTheme: _elevatedButtonTheme(
      backgroundColor: AppColors.darkAccent,
      foregroundColor: AppColors.darkBackground,
    ),

    filledButtonTheme: _filledButtonTheme(
      backgroundColor: AppColors.darkAccent,
      foregroundColor: AppColors.darkBackground,
    ),

    outlinedButtonTheme: _outlinedButtonTheme(
      foregroundColor: AppColors.darkPrimary,
      borderColor: AppColors.darkBorder,
    ),

    textButtonTheme: _textButtonTheme(AppColors.darkAccent),
    iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.sidebarDark,
      surfaceTintColor: Colors.transparent,
    ),

    navigationBarTheme: _navigationBarTheme(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.darkPrimary,
      unselectedColor: AppColors.darkNavUnselected,
      indicatorColor: AppColors.darkPrimaryLight,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.darkTextSecondary,
      textColor: AppColors.darkTextPrimary,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      subtitleTextStyle: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    chipTheme: _chipTheme(
      backgroundColor: AppColors.darkFill,
      selectedColor: AppColors.darkPrimaryLight,
      labelColor: AppColors.darkTextPrimary,
      borderColor: AppColors.darkBorder,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.darkPrimary,
      circularTrackColor: AppColors.darkFill,
      linearTrackColor: AppColors.darkFill,
    ),

    snackBarTheme: _snackBarTheme(
      backgroundColor: AppColors.darkTextPrimary,
      contentColor: AppColors.darkBackground,
    ),

    scrollbarTheme: _scrollbarTheme(thumbColor: AppColors.darkTextMuted),
  );

  static TextTheme _textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        color: primary,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineLarge: TextStyle(
        color: primary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: secondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: secondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        color: secondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static CardThemeData _cardTheme({
    required Color color,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return CardThemeData(
      color: color,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor, width: 1),
      ),
      shadowColor: shadowColor,
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color errorColor,
    required Color hintColor,
    required Color textColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: TextStyle(
        color: hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: focusedBorderColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      errorStyle: TextStyle(
        color: errorColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focusedBorderColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorColor, width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor.withAlpha(128), width: 1),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withAlpha(102),
        disabledForegroundColor: foregroundColor.withAlpha(166),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withAlpha(102),
        disabledForegroundColor: foregroundColor.withAlpha(166),
        minimumSize: const Size(120, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor, width: 1),
        minimumSize: const Size(120, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color foregroundColor) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme({
    required Color backgroundColor,
    required Color selectedColor,
    required Color unselectedColor,
    required Color indicatorColor,
  }) {
    return NavigationBarThemeData(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 70,
      indicatorColor: indicatorColor,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: selectedColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          );
        }

        return TextStyle(
          color: unselectedColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: selectedColor, size: 24);
        }

        return IconThemeData(color: unselectedColor, size: 23);
      }),
    );
  }

  static ChipThemeData _chipTheme({
    required Color backgroundColor,
    required Color selectedColor,
    required Color labelColor,
    required Color borderColor,
  }) {
    return ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      disabledColor: backgroundColor.withAlpha(128),
      labelStyle: TextStyle(
        color: labelColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: TextStyle(
        color: labelColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  static SnackBarThemeData _snackBarTheme({
    required Color backgroundColor,
    required Color contentColor,
  }) {
    return SnackBarThemeData(
      backgroundColor: backgroundColor,
      contentTextStyle: TextStyle(
        color: contentColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  static ScrollbarThemeData _scrollbarTheme({required Color thumbColor}) {
    return ScrollbarThemeData(
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(99),
      thumbColor: WidgetStateProperty.all(thumbColor.withAlpha(166)),
    );
  }
}
