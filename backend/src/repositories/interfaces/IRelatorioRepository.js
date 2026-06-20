'use strict';

// Interface de persistencia de Relatorios de Evolucao (UC007).
class IRelatorioRepository {
  async criar(relatorio) { throw new Error('nao implementado'); }
  async listarPorGrupo(grupoId) { throw new Error('nao implementado'); }
  async contarVersoesPeriodo(grupoId, periodoInicio, periodoFim) { throw new Error('nao implementado'); }
}

module.exports = IRelatorioRepository;
