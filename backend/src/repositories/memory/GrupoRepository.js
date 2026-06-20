'use strict';

const IGrupoRepository = require('../interfaces/IGrupoRepository');
const { store } = require('./store');

class GrupoRepository extends IGrupoRepository {
  async criar(grupo) {
    store.grupos.set(grupo.id, grupo);
    return grupo;
  }

  async buscarPorId(id) {
    return store.grupos.get(id) || null;
  }

  async buscarPorMembro(usuarioId) {
    return [...store.grupos.values()].filter((g) => g.ehMembro(usuarioId));
  }

  async buscarPorTokenConvite(token) {
    return [...store.grupos.values()].find((g) => g.convites.some((c) => c.token === token)) || null;
  }

  async salvar(grupo) {
    store.grupos.set(grupo.id, grupo);
    return grupo;
  }
}

module.exports = GrupoRepository;
