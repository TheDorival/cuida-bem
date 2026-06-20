'use strict';

const IRelatorioRepository = require('../interfaces/IRelatorioRepository');
const { store } = require('./store');

class RelatorioRepository extends IRelatorioRepository {
  async criar(relatorio) {
    store.relatorios.set(relatorio.id, relatorio);
    return relatorio;
  }

  async listarPorGrupo(grupoId) {
    return [...store.relatorios.values()]
      .filter((r) => r.grupoId === grupoId)
      .sort((a, b) => new Date(b.geradoEm) - new Date(a.geradoEm));
  }

  async contarVersoesPeriodo(grupoId, periodoInicio, periodoFim) {
    return [...store.relatorios.values()].filter(
      (r) => r.grupoId === grupoId && r.periodoInicio === periodoInicio && r.periodoFim === periodoFim,
    ).length;
  }
}

module.exports = RelatorioRepository;
