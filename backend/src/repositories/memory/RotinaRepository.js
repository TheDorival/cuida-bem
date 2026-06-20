'use strict';

const IRotinaRepository = require('../interfaces/IRotinaRepository');
const { store } = require('./store');

class RotinaRepository extends IRotinaRepository {
  async criar(rotina) {
    store.rotinas.set(rotina.id, rotina);
    return rotina;
  }

  async buscarPorId(id) {
    return store.rotinas.get(id) || null;
  }

  async listarPorGrupo(grupoId, filtros = {}) {
    let lista = [...store.rotinas.values()].filter((r) => r.grupoId === grupoId);
    if (filtros.apenasAtivas) lista = lista.filter((r) => r.ativa);
    if (filtros.tipo) lista = lista.filter((r) => r.tipo === filtros.tipo);
    return lista.sort((a, b) => (a.horario || '').localeCompare(b.horario || ''));
  }

  async salvar(rotina) {
    store.rotinas.set(rotina.id, rotina);
    return rotina;
  }
}

module.exports = RotinaRepository;
