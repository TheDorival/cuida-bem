'use strict';

const env = require('../config/env');

// Fabrica de repositorios: seleciona a implementacao conforme DATA_BACKEND.
// 'memory' para dev/testes; 'firebase' (Firestore) para producao (RNF008).
function criarRepositorios() {
  if (env.useFirebase) {
    const { getFirestore } = require('../config/firebase');
    const db = getFirestore();
    return {
      usuarios: new (require('./firestore/UsuarioRepository'))(db),
      grupos: new (require('./firestore/GrupoRepository'))(db),
      rotinas: new (require('./firestore/RotinaRepository'))(db),
      alertas: new (require('./firestore/AlertaRepository'))(db),
      entradasDiario: new (require('./firestore/EntradaDiarioRepository'))(db),
      relatorios: new (require('./firestore/RelatorioRepository'))(db),
      logsAuditoria: new (require('./firestore/LogAuditoriaRepository'))(db),
    };
  }

  return {
    usuarios: new (require('./memory/UsuarioRepository'))(),
    grupos: new (require('./memory/GrupoRepository'))(),
    rotinas: new (require('./memory/RotinaRepository'))(),
    alertas: new (require('./memory/AlertaRepository'))(),
    entradasDiario: new (require('./memory/EntradaDiarioRepository'))(),
    relatorios: new (require('./memory/RelatorioRepository'))(),
    logsAuditoria: new (require('./memory/LogAuditoriaRepository'))(),
  };
}

// Instancia unica (singleton) reutilizada pelos servicos.
let repositorios = null;
function getRepositorios() {
  if (!repositorios) repositorios = criarRepositorios();
  return repositorios;
}

module.exports = { criarRepositorios, getRepositorios };
