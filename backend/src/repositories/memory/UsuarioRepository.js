'use strict';

const IUsuarioRepository = require('../interfaces/IUsuarioRepository');
const { store } = require('./store');

class UsuarioRepository extends IUsuarioRepository {
  async buscarPorId(id) {
    return store.usuarios.get(id) || null;
  }

  async buscarPorEmail(email) {
    return [...store.usuarios.values()].find((u) => u.email === email) || null;
  }

  async salvar(usuario) {
    store.usuarios.set(usuario.id, usuario);
    return usuario;
  }
}

module.exports = UsuarioRepository;
