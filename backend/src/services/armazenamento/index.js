'use strict';

const env = require('../../config/env');

// Fabrica do servico de armazenamento conforme o backend configurado.
let instancia = null;
function getArmazenamentoService() {
  if (instancia) return instancia;
  if (env.useFirebaseStorage) {
    const admin = require('firebase-admin');
    const { initFirebase } = require('../../config/firebase');
    initFirebase();
    instancia = new (require('./FirebaseStorageService'))(admin.storage());
  } else {
    instancia = new (require('./LocalArmazenamentoService'))();
  }
  return instancia;
}

module.exports = { getArmazenamentoService };
