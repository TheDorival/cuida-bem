import 'package:flutter/material.dart';

/// Tema visual do CuidaBem (View - MVC do cliente), claro e escuro.
/// Direcao acolhedora e acessivel: tipografia maior, botoes grandes, alto
/// contraste e cantos arredondados - adequado a cuidadores e idosos.
class CuidaBemTheme {
  static const Color semente = Color(0xFF2E7D6B); // verde-petroleo

  static ThemeData get light => _construir(Brightness.light);
  static ThemeData get dark => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brilho) {
    final claro = brilho == Brightness.light;
    final esquema = ColorScheme.fromSeed(seedColor: semente, brightness: brilho);
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);

    return base.copyWith(
      scaffoldBackgroundColor: claro ? const Color(0xFFF6F8F7) : esquema.surface,
      visualDensity: VisualDensity.comfortable,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: claro ? esquema.primary : esquema.surfaceContainerHigh,
        foregroundColor: claro ? esquema.onPrimary : esquema.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: claro ? esquema.onPrimary : esquema.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: claro ? Colors.white : esquema.surfaceContainerHighest,
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
        fillColor: claro ? Colors.white : esquema.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: claro ? Colors.white : esquema.surfaceContainerHigh,
        indicatorColor: esquema.primaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
