import 'package:firebase_messaging/firebase_messaging.dart';

/// Gerencia permissao e token de notificacoes push (FCM) no cliente.
/// Usado apenas em producao; no modo demonstracao nao e acionado.
class NotificacoesPush {
  /// Pede permissao e retorna o token do dispositivo (ou null se negado/indisponivel).
  Future<String?> obterToken() async {
    final fm = FirebaseMessaging.instance;
    final settings = await fm.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return fm.getToken();
  }

  /// Stream de novos tokens (rotacao do FCM).
  Stream<String> get aoAtualizarToken => FirebaseMessaging.instance.onTokenRefresh;
}
