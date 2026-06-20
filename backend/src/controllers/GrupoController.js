'use strict';

const { getContainer } = require('../container');

// Controller REST do UC002 (camada Controller do MVC no servidor).
const GrupoController = {
  async criar(req, res) {
    const grupo = await getContainer().grupoService.criarGrupo(req.usuario, req.body);
    res.status(201).json(grupo.toJSON());
  },

  async listar(req, res) {
    const grupos = await getContainer().grupoService.listarGruposDoUsuario(req.usuario);
    res.json(grupos.map((g) => g.toJSON()));
  },

  async obter(req, res) {
    const grupo = await getContainer().grupoService.obterGrupo(req.usuario, req.params.grupoId);
    res.json(grupo.toJSON());
  },

  async convidar(req, res) {
    const convite = await getContainer().grupoService.convidarMembro(req.usuario, req.params.grupoId, req.body);
    res.status(201).json(convite);
  },

  async aceitarConvite(req, res) {
    const grupo = await getContainer().grupoService.aceitarConvite(req.usuario, req.params.token);
    res.json(grupo.toJSON());
  },

  async removerMembro(req, res) {
    const grupo = await getContainer().grupoService.removerMembro(
      req.usuario,
      req.params.grupoId,
      req.params.usuarioId,
    );
    res.json(grupo.toJSON());
  },
};

module.exports = GrupoController;
