'use strict';

const ILogAuditoriaRepository = require('../interfaces/ILogAuditoriaRepository');
const LogAuditoria = require('../../models/LogAuditoria');

const COL = 'logs_auditoria';

class LogAuditoriaRepository extends ILogAuditoriaRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async registrar(log) {
    await this.db.collection(COL).doc(log.id).set({ ...log });
    return log;
  }

  async listarPorGrupo(grupoId) {
    const snap = await this.db.collection(COL).where('grupoId', '==', grupoId).orderBy('registradoEm', 'asc').get();
    return snap.docs.map((d) => new LogAuditoria(d.data()));
  }
}

module.exports = LogAuditoriaRepository;
