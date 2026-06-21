import 'package:flutter/material.dart';

/// Tema visual do CuidaBem (View - MVC do cliente).
/// Direcao acolhedora e acessivel: tipografia maior, botoes grandes, alto
/// contraste e cantos arredondados - adequado a cuidadores e idosos.
class CuidaBemTheme {
  static const Color semente = Color(0xFF2E7D6B); // verde-petroleo

  static ThemeData get light {
    final esquema = ColorScheme.fromSeed(seedColor: semente, brightness: Brightness.light);
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      visualDensity: VisualDensity.comfortable,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: esquema.onPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: Colors.white,
        indicatorColor: esquema.primaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
