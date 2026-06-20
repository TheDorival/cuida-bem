'use strict';

// Interface de persistencia do Log de Auditoria (RN010).
class ILogAuditoriaRepository {
  async registrar(log) { throw new Error('nao implementado'); }
  async listarPorGrupo(grupoId) { throw new Error('nao implementado'); }
}

module.exports = ILogAuditoriaRepository;
