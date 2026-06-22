import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_client.dart';
import '../services/fila_sincronizacao.dart';
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

  /// Fila de sincronizacao de escritas offline (FE02).
  final FilaSincronizacao fila = FilaSincronizacao();

  bool _autenticado = false;
  bool _pushConfigurado = false;
  bool get autenticado => _autenticado;

  /// Id do usuario atual (uid do Firebase em producao; 'demo-user' no modo demo).
  String? get usuarioId => demo ? 'demo-user' : auth.usuarioAtual?.uid;
  String get nomeUsuario =>
      demo ? 'Usuario (demo)' : (auth.usuarioAtual?.displayName ?? auth.usuarioAtual?.email ?? 'Usuario');
  String get emailUsuario => demo ? 'demo@cuidabem.app' : (auth.usuarioAtual?.email ?? '');
  String? erro;

  SessionProvider({this.demo = false, ApiClient? apiClient}) {
    api = apiClient ?? (demo ? FakeApiClient() : ApiClient());
    if (!demo) api.fila = fila;
  }

  /// Restaura a sessao se ja houver usuario autenticado (app reaberto).
  Future<void> restaurar() async {
    if (demo) return;
    await fila.carregar();
    _ouvirConexao();
    if (auth.usuarioAtual != null) await _aplicarToken();
    if (_autenticado) await fila.processar(api);
  }

  // Sincroniza a fila sempre que a conexao voltar.
  void _ouvirConexao() {
    Connectivity().onConnectivityChanged.listen((resultados) {
      final online = resultados.any((r) => r != ConnectivityResult.none);
      if (online && _autenticado) fila.processar(api);
    });
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

  /// Envia e-mail de redefinicao de senha.
  Future<bool> recuperarSenha(String email) async {
    erro = null;
    if (demo) return true;
    try {
      await auth.recuperarSenha(email);
      return true;
    } catch (e) {
      erro = _traduzir(e);
      notifyListeners();
      return false;
    }
  }

  /// Atualiza o nome de exibicao do usuario.
  Future<bool> atualizarNome(String nome) async {
    erro = null;
    if (demo) return true;
    try {
      await auth.atualizarNome(nome);
      notifyListeners();
      return true;
    } catch (e) {
      erro = _traduzir(e);
      notifyListeners();
      return false;
    }
  }

  /// Atualiza a senha (pode exigir login recente).
  Future<bool> atualizarSenha(String novaSenha) async {
    erro = null;
    if (demo) return true;
    try {
      await auth.atualizarSenha(novaSenha);
      return true;
    } catch (e) {
      erro = _traduzir(e);
      notifyListeners();
      return false;
    }
  }

  /// Exclui a conta do usuario (pode exigir login recente).
  Future<bool> excluirConta() async {
    erro = null;
    if (demo) {
      _autenticado = false;
      notifyListeners();
      return true;
    }
    try {
      await auth.excluirConta();
      api.definirToken(null);
      _autenticado = false;
      notifyListeners();
      return true;
    } catch (e) {
      erro = _traduzir(e);
      notifyListeners();
      return false;
    }
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
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail invalido. Verifique o formato (ex.: nome@email.com)';
        case 'user-not-found':
          return 'Nao encontramos uma conta com esse e-mail';
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos';
        case 'email-already-in-use':
          return 'Este e-mail ja esta cadastrado. Tente entrar';
        case 'weak-password':
          return 'A senha deve ter ao menos 6 caracteres';
        case 'missing-password':
          return 'Informe a senha';
        case 'requires-recent-login':
          return 'Por seguranca, saia e entre de novo para concluir esta acao';
        case 'no-current-user':
          return 'Sua sessao expirou. Entre novamente';
        case 'user-disabled':
          return 'Esta conta foi desativada';
        case 'too-many-requests':
          return 'Muitas tentativas. Aguarde um momento e tente de novo';
        case 'network-request-failed':
          return 'Sem conexao com a internet';
        case 'operation-not-allowed':
          return 'Login por e-mail/senha nao esta habilitado no servidor';
        default:
          return 'Nao foi possivel autenticar (${e.code})';
      }
    }
    return 'Nao foi possivel autenticar. Tente novamente';
  }
}
