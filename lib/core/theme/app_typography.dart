import 'package:flutter/material.dart';

class AppFontSize {
  // Display
  static const double displayLarge = 57;
  static const double displayMedium = 45;
  static const double displaySmall = 36;

  // Headline
  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;

  // Title
  static const double titleLarge = 22;
  static const double titleMedium = 16;
  static const double titleSmall = 14;

  // Body
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;

  // Label
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 11;
}

/// Factory tạo TextTheme dựa vào size ở trên.
/// Dễ chỉnh fontFamily, weight, color.
class AppTypography {
  static TextTheme createTextTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppFontSize.displayLarge,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: AppFontSize.displayMedium,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: AppFontSize.displaySmall,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),

      headlineLarge: TextStyle(
        fontSize: AppFontSize.headlineLarge,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: AppFontSize.headlineMedium,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: AppFontSize.headlineSmall,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),

      titleLarge: TextStyle(
        fontSize: AppFontSize.titleLarge,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: AppFontSize.titleMedium,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: AppFontSize.titleSmall,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),

      bodyLarge: TextStyle(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: FontWeight.w400,
        color: colors.onSurface.withOpacity(.87),
      ),
      bodySmall: TextStyle(
        fontSize: AppFontSize.bodySmall,
        fontWeight: FontWeight.w400,
        color: colors.onSurface.withOpacity(.60),
      ),

      labelLarge: TextStyle(
        fontSize: AppFontSize.labelLarge,
        fontWeight: FontWeight.w600,
        color: colors.onPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: AppFontSize.labelMedium,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: AppFontSize.labelSmall,
        fontWeight: FontWeight.w600,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
