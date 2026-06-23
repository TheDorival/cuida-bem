import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla o modo de tema (claro/escuro) com persistencia local.
/// Padrao: tema claro. So fica escuro se o usuario escolher e a preferencia
/// fica salva entre sessoes.
class TemaProvider extends ChangeNotifier {
  static const _chave = 'tema_modo';
  ThemeMode _modo = ThemeMode.light;

  ThemeMode get modo => _modo;
  bool get escuro => _modo == ThemeMode.dark;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _modo = _doTexto(prefs.getString(_chave));
    notifyListeners();
  }

  Future<void> definir(ThemeMode modo) async {
    _modo = modo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, _paraTexto(modo));
  }

  Future<void> alternar() => definir(escuro ? ThemeMode.light : ThemeMode.dark);

  ThemeMode _doTexto(String? v) {
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        // Sem preferencia salva (ou valor antigo 'system'): abre no claro.
        return ThemeMode.light;
    }
  }

  String _paraTexto(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
