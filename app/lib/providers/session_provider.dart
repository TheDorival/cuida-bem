import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/grupo_service.dart';
import '../services/rotina_service.dart';
import '../services/diario_service.dart';
import '../services/relatorio_service.dart';

/// Estado de sessao do usuario (Controller do MVC do cliente).
/// Mantem o token de autenticacao e expoe os servicos configurados.
class SessionProvider extends ChangeNotifier {
  final ApiClient api = ApiClient();
  late final GrupoService grupos = GrupoService(api);
  late final RotinaService rotinas = RotinaService(api);
  late final DiarioService diario = DiarioService(api);
  late final RelatorioService relatorios = RelatorioService(api);

  String? _token;
  String? get token => _token;
  bool get autenticado => _token != null;

  /// Em desenvolvimento o token e o id do usuario; em producao, o ID token do Firebase Auth.
  void entrar(String token) {
    _token = token;
    api.definirToken(token);
    notifyListeners();
  }

  void sair() {
    _token = null;
    api.definirToken(null);
    notifyListeners();
  }
}
