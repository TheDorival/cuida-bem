import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Excecao de API com mensagem amigavel vinda do back-end.
class ApiException implements Exception {
  final int status;
  final String message;
  final String? code;
  ApiException(this.status, this.message, [this.code]);
  @override
  String toString() => message;
}

/// Cliente HTTP central do app (camada de servico do MVC do cliente).
/// Adiciona o token de autenticacao (Bearer) e trata erros do back-end.
class ApiClient {
  String? _token;

  void definirToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path) => _enviar(() => http.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _enviar(() => http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) =>
      _enviar(() => http.patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> delete(String path) => _enviar(() => http.delete(_uri(path), headers: _headers));

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
