import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_button_themes.dart';
import 'app_colors.dart';
import 'app_input_themes.dart';
import 'app_typography.dart';

class AppTheme {
  //color theme
  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    // Color.fromARGB(255, 103, 101, 101)
    surface: AppColors.background2,
    onSurface: AppColors.onSurface,
    outline: AppColors.border,
  );

  static final ThemeData mainTheme = ThemeData(
    colorScheme: colorScheme,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: AppTypography.createTextTheme(colorScheme),
    elevatedButtonTheme: AppButtonThemes.elevatedButtonTheme(colorScheme),
    inputDecorationTheme: AppInputThemes.inputTheme(colorScheme),
  );
}
