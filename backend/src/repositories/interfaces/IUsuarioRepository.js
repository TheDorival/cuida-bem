'use strict';

// Interface de persistencia de Usuarios (identidade via Firebase Auth).
class IUsuarioRepository {
  async buscarPorId(id) { throw new Error('nao implementado'); }
  async buscarPorEmail(email) { throw new Error('nao implementado'); }
  async salvar(usuario) { throw new Error('nao implementado'); }
}

module.exports = IUsuarioRepository;
