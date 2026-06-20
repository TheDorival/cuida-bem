import 'package:flutter/material.dart';

/// Tema visual do CuidaBem (View - MVC do cliente).
class CuidaBemTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D6B),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}
