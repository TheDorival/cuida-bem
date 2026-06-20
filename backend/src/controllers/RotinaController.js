'use strict';

const { getContainer } = require('../container');

// Controller REST do UC003.
const RotinaController = {
  async criar(req, res) {
    const out = await getContainer().rotinaService.criarRotina(req.usuario, req.params.grupoId, req.body);
    res.status(201).json({ rotina: out.rotina.toJSON(), alertaAgendado: out.alertaAgendado });
  },

  async listar(req, res) {
    const filtros = {
      apenasAtivas: req.query.ativas === 'true',
      tipo: req.query.tipo || undefined,
    };
    const rotinas = await getContainer().rotinaService.listarRotinas(req.usuario, req.params.grupoId, filtros);
    res.json(rotinas.map((r) => r.toJSON()));
  },

  async editar(req, res) {
    const rotina = await getContainer().rotinaService.editarRotina(req.usuario, req.params.rotinaId, req.body);
    res.json(rotina.toJSON());
  },

  async concluir(req, res) {
    const rotina = await getContainer().rotinaService.concluirRotina(req.usuario, req.params.rotinaId);
    res.json(rotina.toJSON());
  },

  async desativar(req, res) {
    const rotina = await getContainer().rotinaService.desativarRotina(req.usuario, req.params.rotinaId);
    res.json(rotina.toJSON());
  },
};

module.exports = RotinaController;
