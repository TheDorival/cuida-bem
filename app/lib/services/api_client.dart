import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'fila_sincronizacao.dart';

/// Excecao de API com mensagem amigavel vinda do back-end.
class ApiException implements Exception {
  final int status;
  final String message;
  final String? code;
  ApiException(this.status, this.message, [this.code]);
  @override
  String toString() => message;
}

/// Lancada quando uma escrita falha por falta de conexao e e guardada na fila.
class OfflineException implements Exception {
  @override
  String toString() => 'Sem conexao. A alteracao foi salva e sera sincronizada ao reconectar.';
}

/// Cliente HTTP central do app (camada de servico do MVC do cliente).
/// Adiciona o token de autenticacao (Bearer) e trata erros do back-end.
/// Escritas (POST/PATCH/DELETE) feitas offline sao enfileiradas para sincronizar.
class ApiClient {
  String? _token;

  /// Fila de sincronizacao offline (injetada; ausente no modo demo).
  FilaSincronizacao? fila;

  void definirToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path) => _enviar(() => http.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _comFila('POST', path, body);

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) =>
      _comFila('PATCH', path, body);

  Future<dynamic> delete(String path) => _comFila('DELETE', path, null);

  /// Tenta a escrita; se falhar por falta de conexao, enfileira e lanca OfflineException.
  /// Erros de servidor (HTTP) sao repassados normalmente (nao enfileira).
  Future<dynamic> _comFila(String metodo, String path, Map<String, dynamic>? body) async {
    try {
      return await enviarDireto(metodo, path, body);
    } on ApiException {
      rethrow;
    } catch (_) {
      if (fila != null) {
        await fila!.enfileirar(OperacaoPendente(metodo: metodo, path: path, body: body));
        throw OfflineException();
      }
      rethrow;
    }
  }

  /// Executa a requisicao sem passar pela fila (usado pela propria fila ao sincronizar).
  Future<dynamic> enviarDireto(String metodo, String path, Map<String, dynamic>? body) {
    switch (metodo) {
      case 'POST':
        return _enviar(() => http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));
      case 'PATCH':
        return _enviar(() => http.patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));
      case 'DELETE':
        return _enviar(() => http.delete(_uri(path), headers: _headers));
      default:
        return _enviar(() => http.get(_uri(path), headers: _headers));
    }
  }

  Future<dynamic> _enviar(Future<http.Response> Function() req) async {
    final resp = await req();
    final corpo = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
    if (resp.statusCode >= 200 && resp.statusCode < 300) return corpo;

    final erro = (corpo is Map && corpo['error'] is Map) ? corpo['error'] : null;
    throw ApiException(
      resp.statusCode,
      erro?['message']?.toString() ?? 'Erro ${resp.statusCode}',
      erro?['code']?.toString(),
    );
  }
}
