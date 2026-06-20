/// Configuracao de acesso a API REST do CuidaBem.
/// A comunicacao ocorre exclusivamente via HTTPS/TLS em producao (RNF003).
class ApiConfig {
  /// Sobrescreva via --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
