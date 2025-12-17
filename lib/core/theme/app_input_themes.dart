import 'package:flutter/material.dart';

class AppInputThemes {
  static InputDecorationTheme inputTheme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest,

      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

      // Label
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: colors.primary,
        fontWeight: FontWeight.w600,
      ),

      // Hint
      hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),

      // Text
      counterStyle: TextStyle(color: colors.onSurfaceVariant),

      // Enabled border
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(11),
      ),

      // Focused border
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
        borderRadius: BorderRadius.circular(11),
      ),

      // Error border
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.error),
        borderRadius: BorderRadius.circular(11),
      ),

      // Error focused border
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.error, width: 2),
        borderRadius: BorderRadius.circular(11),
      ),

      // Disabled border
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.onSurface.withOpacity(.12)),
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }
}
