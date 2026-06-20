'use strict';

const INotificacaoService = require('./INotificacaoService');

// Implementacao de producao: FcmNotificacaoService (Figura 15).
// Envia notificacoes push via Firebase Cloud Messaging.
class FcmNotificacaoService extends INotificacaoService {
  constructor(messaging) {
    super();
    this.messaging = messaging;
  }

  async enviar(destinatarios, payload) {
    const tokens = (destinatarios || []).filter(Boolean);
    if (!tokens.length) return { enviados: 0, sucesso: true };

    const mensagem = {
      tokens,
      notification: { title: payload.titulo, body: payload.corpo },
      data: Object.fromEntries(
        Object.entries(payload.dados || {}).map(([k, v]) => [k, String(v)]),
      ),
    };

    const resp = await this.messaging.sendEachForMulticast(mensagem);
    return { enviados: resp.successCount, sucesso: resp.failureCount === 0 };
  }
}

module.exports = FcmNotificacaoService;
