'use strict';

const INotificacaoService = require('./INotificacaoService');

// Implementacao de desenvolvimento: registra a notificacao no console.
// Usada quando DATA_BACKEND=memory (sem credenciais FCM).
class ConsoleNotificacaoService extends INotificacaoService {
  async enviar(destinatarios, payload) {
    // eslint-disable-next-line no-console
    console.log('[notificacao]', {
      destinatarios: destinatarios.length,
      titulo: payload.titulo,
      corpo: payload.corpo,
    });
    return { enviados: destinatarios.length, sucesso: true };
  }
}

module.exports = ConsoleNotificacaoService;
