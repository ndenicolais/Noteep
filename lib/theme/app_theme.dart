import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteep/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.baseLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.baseLight,
        onPrimary: AppColors.featureDark,
        secondary: AppColors.baseDark,
        onSecondary: AppColors.baseLight,
        tertiary: AppColors.featureDark,
        onTertiary: AppColors.baseDark,
        onError: AppColors.errorColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(AppColors.baseLight),
        checkColor: WidgetStateProperty.all(AppColors.baseDark),
        side: BorderSide(
          color: AppColors.featureDark,
          width: 1,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.baseLight,
        surfaceTintColor: AppColors.featureDark,
        headerBackgroundColor: AppColors.baseDark,
        headerForegroundColor: AppColors.featureDark,
        todayBackgroundColor: WidgetStateProperty.all(AppColors.featureDark),
        todayForegroundColor: WidgetStateProperty.all(AppColors.baseDark),
        dividerColor: AppColors.baseDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.exo2(
          color: AppColors.featureDark,
        ),
        errorStyle: GoogleFonts.exo2(
          color: AppColors.errorColor,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.errorColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.baseDark,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.baseDark,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.exo2(
            color: AppColors.featureDark,
          ),
          foregroundColor: AppColors.baseDark,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.featureDark,
        selectionHandleColor: AppColors.featureDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.exo2(),
        displayMedium: GoogleFonts.exo2(),
        displaySmall: GoogleFonts.exo2(),
        headlineLarge: GoogleFonts.exo2(),
        headlineMedium: GoogleFonts.exo2(),
        headlineSmall: GoogleFonts.exo2(),
        titleLarge: GoogleFonts.exo2(),
        titleMedium: GoogleFonts.exo2(),
        titleSmall: GoogleFonts.exo2(),
        bodyLarge: GoogleFonts.exo2(),
        bodyMedium: GoogleFonts.exo2(),
        bodySmall: GoogleFonts.exo2(),
        labelLarge: GoogleFonts.exo2(),
        labelMedium: GoogleFonts.exo2(),
        labelSmall: GoogleFonts.exo2(),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.baseLight,
        dialBackgroundColor: AppColors.baseDark,
        dialHandColor: AppColors.baseLight,
        dialTextColor: AppColors.featureDark,
        helpTextStyle: GoogleFonts.exo2(
          color: AppColors.featureDark,
        ),
        hourMinuteColor: AppColors.baseDark,
        hourMinuteTextColor: AppColors.featureDark,
      ),
    );
  }

  static ThemeData darkTheme() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.baseDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.baseDark,
        onPrimary: AppColors.baseLight,
        secondary: AppColors.featureDark,
        onSecondary: AppColors.baseDark,
        tertiary: AppColors.baseLight,
        onTertiary: AppColors.featureDark,
        onError: AppColors.errorColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(AppColors.baseDark),
        checkColor: WidgetStateProperty.all(AppColors.baseLight),
        side: BorderSide(
          color: AppColors.featureDark,
          width: 1,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.baseDark,
        surfaceTintColor: AppColors.baseLight,
        headerBackgroundColor: AppColors.featureDark,
        headerForegroundColor: AppColors.baseLight,
        todayBackgroundColor: WidgetStateProperty.all(AppColors.baseLight),
        todayForegroundColor: WidgetStateProperty.all(AppColors.featureDark),
        dividerColor: AppColors.featureDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.exo2(
          color: AppColors.baseLight,
        ),
        errorStyle: GoogleFonts.exo2(
          color: AppColors.errorColor,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.errorColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.featureDark,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.featureDark,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.exo2(
            color: AppColors.baseLight,
          ),
          foregroundColor: AppColors.featureDark,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.baseLight,
        selectionHandleColor: AppColors.baseLight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.exo2(),
        displayMedium: GoogleFonts.exo2(),
        displaySmall: GoogleFonts.exo2(),
        headlineLarge: GoogleFonts.exo2(),
        headlineMedium: GoogleFonts.exo2(),
        headlineSmall: GoogleFonts.exo2(),
        titleLarge: GoogleFonts.exo2(),
        titleMedium: GoogleFonts.exo2(),
        titleSmall: GoogleFonts.exo2(),
        bodyLarge: GoogleFonts.exo2(),
        bodyMedium: GoogleFonts.exo2(),
        bodySmall: GoogleFonts.exo2(),
        labelLarge: GoogleFonts.exo2(),
        labelMedium: GoogleFonts.exo2(),
        labelSmall: GoogleFonts.exo2(),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.baseDark,
        dialBackgroundColor: AppColors.featureDark,
        dialHandColor: AppColors.baseDark,
        dialTextColor: AppColors.baseLight,
        helpTextStyle: GoogleFonts.exo2(
          color: AppColors.baseLight,
        ),
        hourMinuteColor: AppColors.featureDark,
        hourMinuteTextColor: AppColors.baseLight,
      ),
    );
  }
}
