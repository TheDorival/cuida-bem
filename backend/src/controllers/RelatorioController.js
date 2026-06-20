'use strict';

const { getContainer } = require('../container');

// Controller REST do UC007.
const RelatorioController = {
  async gerar(req, res) {
    const relatorio = await getContainer().relatorioService.gerarRelatorio(req.usuario, req.params.grupoId, req.body);
    res.status(201).json(relatorio.toJSON());
  },

  async listar(req, res) {
    const relatorios = await getContainer().relatorioService.listarRelatorios(req.usuario, req.params.grupoId);
    res.json(relatorios.map((r) => r.toJSON()));
  },
};

module.exports = RelatorioController;
