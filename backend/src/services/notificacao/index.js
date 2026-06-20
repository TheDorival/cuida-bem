'use strict';

const env = require('../../config/env');

// Fabrica do servico de notificacao conforme o backend configurado.
let instancia = null;
function getNotificacaoService() {
  if (instancia) return instancia;
  if (env.useFirebase) {
    const { getMessaging } = require('../../config/firebase');
    instancia = new (require('./FcmNotificacaoService'))(getMessaging());
  } else {
    instancia = new (require('./ConsoleNotificacaoService'))();
  }
  return instancia;
}

module.exports = { getNotificacaoService };
