import 'package:flutter/material.dart';

class AppButtonThemes {
  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(colors.primary),
        foregroundColor: WidgetStateProperty.all(colors.onPrimary),
        shadowColor: WidgetStateProperty.all(colors.shadow),

        // Border
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // Padding
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),

        // Press Animation
        overlayColor: WidgetStateProperty.all(
          colors.onPrimary.withOpacity(0.08),
        ),

        // Typography
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14, // labelLarge
          ),
        ),
      ),
    );
  }
}
