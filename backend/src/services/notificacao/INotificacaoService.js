'use strict';

// Interface INotificacaoService (Figura 15). Abstrai o envio de notificacoes push,
// permitindo trocar FCM por outra infraestrutura sem impacto nos controllers.
class INotificacaoService {
  // destinatarios: lista de tokens FCM; payload: { titulo, corpo, dados }
  async enviar(destinatarios, payload) { throw new Error('nao implementado'); }
}

module.exports = INotificacaoService;
