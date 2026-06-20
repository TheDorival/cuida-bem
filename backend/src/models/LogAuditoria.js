'use strict';

// Entidade LogAuditoria (<<entity>>) - RN010. Registro imutavel de operacoes sensiveis.
class LogAuditoria {
  constructor({ id, grupoId = null, usuarioId = null, acao, detalhes = {}, registradoEm = new Date() }) {
    this.id = id;
    this.grupoId = grupoId;
    this.usuarioId = usuarioId;
    this.acao = acao;
    this.detalhes = detalhes;
    this.registradoEm = registradoEm;
  }

  toJSON() {
    return { ...this };
  }
}

module.exports = LogAuditoria;
