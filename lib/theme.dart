import 'package:flutter/material.dart';

class GlutTheme {
  static const ember   = Color(0xFFE8621A);
  static const ash     = Color(0xFF141412);
  static const coal    = Color(0xFF2A2A26);
  static const moss    = Color(0xFF7BC47B);
  static const linen   = Color(0xFFF5F0E8);
  static const logBrown = Color(0xFF6B4E2A);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ash,
    primaryColor: ember,
    colorScheme: const ColorScheme.dark(
      primary: ember,
      surface: coal,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Georgia',
        color: linen,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(color: linen),
      bodySmall: TextStyle(color: Colors.white54),
    ),
  );
}