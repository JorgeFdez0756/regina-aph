import 'package:flutter/material.dart';

abstract final class ReginaTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
    scaffoldBackgroundColor: const Color(0xFFFFFBF3),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      ),
    ),
  );
}
