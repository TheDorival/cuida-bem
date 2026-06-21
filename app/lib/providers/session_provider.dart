import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/fake_api_client.dart';
import '../services/auth_service.dart';
import '../services/notificacoes_push.dart';
import '../services/grupo_service.dart';
import '../services/rotina_service.dart';
import '../services/diario_service.dart';
import '../services/relatorio_service.dart';

/// Estado de sessao do usuario (Controller do MVC do cliente).
/// Em producao autentica via Firebase Auth (UC001) e injeta o ID token no
/// ApiClient. Em modo demonstracao usa um FakeApiClient e dispensa o Firebase.
class SessionProvider extends ChangeNotifier {
  final bool demo;
  late final ApiClient api;
  late final GrupoService grupos = GrupoService(api);
  late final RotinaService rotinas = RotinaService(api);
  late final DiarioService diario = DiarioService(api);
  late final RelatorioService relatorios = RelatorioService(api);

  AuthService? _auth;
  AuthService get auth => _auth ??= AuthService();

  bool _autenticado = false;
  bool _pushConfigurado = false;
  bool get autenticado => _autenticado;

  /// Id do usuario atual (uid do Firebase em producao; 'demo-user' no modo demo).
  String? get usuarioId => demo ? 'demo-user' : auth.usuarioAtual?.uid;
  String get nomeUsuario => demo ? 'Usuario (demo)' : (auth.usuarioAtual?.displayName ?? auth.usuarioAtual?.email ?? 'Usuario');
  String? erro;

  SessionProvider({this.demo = false, ApiClient? apiClient}) {
    api = apiClient ?? (demo ? FakeApiClient() : ApiClient());
  }

  /// Restaura a sessao se ja houver usuario autenticado (app reaberto).
  Future<void> restaurar() async {
    if (demo) return;
    if (auth.usuarioAtual != null) await _aplicarToken();
  }

  Future<bool> entrar(String email, String senha) async {
    if (demo) return _entrarDemo();
    return _executar(() => auth.entrar(email, senha));
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    if (demo) return _entrarDemo();
    return _executar(() => auth.cadastrar(nome, email, senha));
  }

  Future<void> sair() async {
    if (!demo) await auth.sair();
    api.definirToken(null);
    _autenticado = false;
    notifyListeners();
  }

  bool _entrarDemo() {
    api.definirToken('demo');
    _autenticado = true;
    erro = null;
    notifyListeners();
    return true;
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
    if (_autenticado) _registrarPush();
  }

  // Registra o token FCM do dispositivo no backend (somente producao).
  Future<void> _registrarPush() async {
    if (demo) return;
    final push = NotificacoesPush();
    try {
      final tokenPush = await push.obterToken();
      if (tokenPush != null) {
        await api.post('/usuarios/me/fcm-token', {'token': tokenPush});
      }
    } catch (_) {
      // falha em push nao deve impedir o uso do app
    }
    // Renova o registro quando o FCM rotaciona o token (uma unica vez).
    if (!_pushConfigurado) {
      _pushConfigurado = true;
      push.aoAtualizarToken.listen((novo) async {
        try {
          await api.post('/usuarios/me/fcm-token', {'token': novo});
        } catch (_) {}
      });
    }
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
