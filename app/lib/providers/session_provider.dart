import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/grupo_service.dart';
import '../services/rotina_service.dart';
import '../services/diario_service.dart';
import '../services/relatorio_service.dart';

/// Estado de sessao do usuario (Controller do MVC do cliente).
/// Autentica via Firebase Auth (UC001) e injeta o ID token no ApiClient.
class SessionProvider extends ChangeNotifier {
  final ApiClient api = ApiClient();
  final AuthService auth = AuthService();
  late final GrupoService grupos = GrupoService(api);
  late final RotinaService rotinas = RotinaService(api);
  late final DiarioService diario = DiarioService(api);
  late final RelatorioService relatorios = RelatorioService(api);

  bool _autenticado = false;
  bool get autenticado => _autenticado;
  String? erro;

  /// Restaura a sessao se ja houver usuario autenticado (app reaberto).
  Future<void> restaurar() async {
    if (auth.usuarioAtual != null) {
      await _aplicarToken();
    }
  }

  Future<bool> entrar(String email, String senha) async {
    return _executar(() => auth.entrar(email, senha));
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    return _executar(() => auth.cadastrar(nome, email, senha));
  }

  Future<void> sair() async {
    await auth.sair();
    api.definirToken(null);
    _autenticado = false;
    notifyListeners();
  }

  Future<bool> _executar(Future<Object?> Function() acao) async {
    erro = null;
    try {
      await acao();
      await _aplicarToken();
      return true;
    } catch (e) {
      erro = _traduzir(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> _aplicarToken() async {
    final token = await auth.idToken(forcar: true);
    api.definirToken(token);
    _autenticado = token != null;
    notifyListeners();
  }

  String _traduzir(Object e) {
    final s = e.toString();
    if (s.contains('user-not-found') || s.contains('wrong-password') || s.contains('invalid-credential')) {
      return 'E-mail ou senha invalidos';
    }
    if (s.contains('email-already-in-use')) return 'E-mail ja cadastrado';
    if (s.contains('weak-password')) return 'Senha muito fraca (minimo 6 caracteres)';
    return 'Falha na autenticacao';
  }
}
