'use strict';

process.env.DATA_BACKEND = 'memory';
process.env.NODE_ENV = 'test';

const { limpar } = require('../src/repositories/memory/store');
const { getRepositorios } = require('../src/repositories');
const { getContainer } = require('../src/container');
const Usuario = require('../src/models/Usuario');
const { PerfilUsuario } = require('../src/models/enums');

async function setup() {
  limpar();
  const repos = getRepositorios();
  const principal = new Usuario({ id: 'principal', nome: 'Ana', email: 'ana@ex.com', perfil: PerfilUsuario.CUIDADOR_PRINCIPAL, fcmTokens: ['tok-ana'] });
  const auxiliar = new Usuario({ id: 'auxiliar', nome: 'Bia', email: 'bia@ex.com', perfil: PerfilUsuario.CUIDADOR_AUXILIAR, fcmTokens: ['tok-bia'] });
  const familiar = new Usuario({ id: 'familiar', nome: 'Caio', email: 'caio@ex.com', perfil: PerfilUsuario.FAMILIAR, fcmTokens: [] });
  await repos.usuarios.salvar(principal);
  await repos.usuarios.salvar(auxiliar);
  await repos.usuarios.salvar(familiar);
  return { repos, container: getContainer(), principal, auxiliar, familiar };
}

module.exports = { setup };
