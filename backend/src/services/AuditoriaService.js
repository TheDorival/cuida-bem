'use strict';

const LogAuditoria = require('../models/LogAuditoria');
const { novoId } = require('../utils/id');

// Servico transversal de auditoria (RN010). Registra operacoes sensiveis de
// forma imutavel para rastreabilidade.
class AuditoriaService {
  constructor({ logsAuditoria }) {
    this.repo = logsAuditoria;
  }

  async registrar({ grupoId = null, usuarioId = null, acao, detalhes = {} }) {
    const log = new LogAuditoria({ id: novoId('log'), grupoId, usuarioId, acao, detalhes });
    return this.repo.registrar(log);
  }

  async listarPorGrupo(grupoId) {
    return this.repo.listarPorGrupo(grupoId);
  }
}

module.exports = AuditoriaService;
