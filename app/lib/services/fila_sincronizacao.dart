import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// Uma operacao de escrita pendente (feita offline) a ser reenviada.
class OperacaoPendente {
  final String metodo;
  final String path;
  final Map<String, dynamic>? body;
  OperacaoPendente({required this.metodo, required this.path, this.body});

  Map<String, dynamic> toJson() => {'metodo': metodo, 'path': path, 'body': body};

  factory OperacaoPendente.fromJson(Map<String, dynamic> j) => OperacaoPendente(
        metodo: j['metodo'] as String,
        path: j['path'] as String,
        body: (j['body'] as Map?)?.cast<String, dynamic>(),
      );
}

/// Fila persistente de escritas feitas offline; sincroniza ao reconectar (FE02
/// dos UC003/UC004). Persiste em SharedPreferences para sobreviver a reinicios.
class FilaSincronizacao extends ChangeNotifier {
  static const _chave = 'fila_sincronizacao';
  final List<OperacaoPendente> _ops = [];
  bool _processando = false;

  int get quantidade => _ops.length;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave);
    if (raw != null) {
      final lista = jsonDecode(raw) as List;
      _ops
        ..clear()
        ..addAll(lista.map((e) => OperacaoPendente.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> enfileirar(OperacaoPendente op) async {
    _ops.add(op);
    await _salvar();
    notifyListeners();
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(_ops.map((e) => e.toJson()).toList()));
  }

  /// Reenvia as operacoes pendentes em ordem. Mantem na fila as que falharem
  /// por falta de conexao; descarta as rejeitadas pelo servidor.
  Future<int> processar(ApiClient api) async {
    if (_processando || _ops.isEmpty) return 0;
    _processando = true;
    var enviados = 0;
    try {
      while (_ops.isNotEmpty) {
        final op = _ops.first;
        try {
          await api.enviarDireto(op.metodo, op.path, op.body);
          _ops.removeAt(0);
          enviados++;
        } on ApiException {
          _ops.removeAt(0); // servidor rejeitou: descarta (nao adianta repetir)
        } catch (_) {
          break; // sem conexao: tenta novamente depois
        }
      }
      await _salvar();
    } finally {
      _processando = false;
      notifyListeners();
    }
    return enviados;
  }
}
