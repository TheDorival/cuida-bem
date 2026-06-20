'use strict';

// Interface de persistencia de Rotinas (UC003) - IRotinaRepository da arquitetura (Figura 15).
class IRotinaRepository {
  async criar(rotina) { throw new Error('nao implementado'); }
  async buscarPorId(id) { throw new Error('nao implementado'); }
  async listarPorGrupo(grupoId, filtros = {}) { throw new Error('nao implementado'); }
  async salvar(rotina) { throw new Error('nao implementado'); }
}

module.exports = IRotinaRepository;
