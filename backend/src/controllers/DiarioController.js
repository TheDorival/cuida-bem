'use strict';

const { getContainer } = require('../container');

// Controller REST do UC004.
const DiarioController = {
  async registrar(req, res) {
    const entrada = await getContainer().diarioService.registrarEntrada(req.usuario, req.params.grupoId, req.body);
    res.status(201).json(entrada.toJSON());
  },

  async listar(req, res) {
    const categorias = req.query.categorias ? String(req.query.categorias).split(',').filter(Boolean) : null;
    const filtros = {
      categorias,
      dataInicio: req.query.dataInicio || null,
      dataFim: req.query.dataFim || null,
    };
    const entradas = await getContainer().diarioService.listarEntradas(req.usuario, req.params.grupoId, filtros);
    res.json(entradas.map((e) => e.toJSON()));
  },
};

module.exports = DiarioController;
