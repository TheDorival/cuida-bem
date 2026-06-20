'use strict';

const ILogAuditoriaRepository = require('../interfaces/ILogAuditoriaRepository');
const { store } = require('./store');

class LogAuditoriaRepository extends ILogAuditoriaRepository {
  async registrar(log) {
    store.logsAuditoria.push(log);
    return log;
  }

  async listarPorGrupo(grupoId) {
    return store.logsAuditoria
      .filter((l) => l.grupoId === grupoId)
      .sort((a, b) => new Date(a.registradoEm) - new Date(b.registradoEm));
  }
}

module.exports = LogAuditoriaRepository;
