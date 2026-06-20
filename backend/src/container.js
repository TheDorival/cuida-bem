'use strict';

// Injecao de dependencias: instancia repositorios, servicos transversais e
// servicos de negocio de cada caso de uso. Centraliza o wiring do MVC.
const { getRepositorios } = require('./repositories');
const { getNotificacaoService } = require('./services/notificacao');
const AuditoriaService = require('./services/AuditoriaService');
const GrupoService = require('./services/GrupoService');

let container = null;

function getContainer() {
  if (container) return container;
  const repos = getRepositorios();
  const auditoria = new AuditoriaService(repos);
  const notificacao = getNotificacaoService();

  container = {
    repos,
    auditoria,
    notificacao,
    grupoService: new GrupoService(repos, auditoria),
  };
  return container;
}

module.exports = { getContainer };
