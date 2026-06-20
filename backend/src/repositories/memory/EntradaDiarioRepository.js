'use strict';

const IEntradaDiarioRepository = require('../interfaces/IEntradaDiarioRepository');
const { store } = require('./store');

class EntradaDiarioRepository extends IEntradaDiarioRepository {
  async criar(entrada) {
    store.entradasDiario.set(entrada.id, entrada);
    return entrada;
  }

  async buscarPorId(id) {
    return store.entradasDiario.get(id) || null;
  }

  async listarPorGrupo(grupoId, filtros = {}) {
    let lista = [...store.entradasDiario.values()].filter((e) => e.grupoId === grupoId);
    if (filtros.categorias && filtros.categorias.length) {
      lista = lista.filter((e) => filtros.categorias.includes(e.categoria));
    }
    if (filtros.dataInicio) {
      const ini = new Date(filtros.dataInicio);
      lista = lista.filter((e) => new Date(e.criadaEm) >= ini);
    }
    if (filtros.dataFim) {
      const fim = new Date(filtros.dataFim);
      lista = lista.filter((e) => new Date(e.criadaEm) <= fim);
    }
    return lista.sort((a, b) => new Date(a.criadaEm) - new Date(b.criadaEm));
  }
}

module.exports = EntradaDiarioRepository;
