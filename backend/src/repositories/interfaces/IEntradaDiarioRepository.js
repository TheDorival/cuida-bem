'use strict';

// Interface de persistencia de Entradas do Diario (UC004).
class IEntradaDiarioRepository {
  async criar(entrada) { throw new Error('nao implementado'); }
  async buscarPorId(id) { throw new Error('nao implementado'); }
  async listarPorGrupo(grupoId, filtros = {}) { throw new Error('nao implementado'); }
}

module.exports = IEntradaDiarioRepository;
