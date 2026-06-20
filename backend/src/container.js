'use strict';

// Injecao de dependencias: instancia repositorios, servicos transversais e
// servicos de negocio de cada caso de uso. Centraliza o wiring do MVC.
const { getRepositorios } = require('./repositories');
const { getNotificacaoService } = require('./services/notificacao');
const AuditoriaService = require('./services/AuditoriaService');
const GrupoService = require('./services/GrupoService');
const AlertaService = require('./services/AlertaService');
const RotinaService = require('./services/RotinaService');
const DiarioService = require('./services/DiarioService');
const RelatorioService = require('./services/RelatorioService');
const PdfService = require('./services/PdfService');

let container = null;

function getContainer() {
  if (container) return container;
  const repos = getRepositorios();
  const auditoria = new AuditoriaService(repos);
  const notificacao = getNotificacaoService();
  const alertaService = new AlertaService(repos, notificacao);
  const pdfService = new PdfService();

  container = {
    repos,
    auditoria,
    notificacao,
    alertaService,
    grupoService: new GrupoService(repos, auditoria),
    rotinaService: new RotinaService(repos, alertaService, auditoria),
    diarioService: new DiarioService(repos, notificacao, auditoria),
    relatorioService: new RelatorioService(repos, pdfService, auditoria),
  };
  return container;
}

module.exports = { getContainer };
