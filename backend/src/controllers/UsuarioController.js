'use strict';

const { getContainer } = require('../container');
const { ValidationError } = require('../utils/errors');

// Controller do usuario autenticado (perfil e tokens de dispositivo).
const UsuarioController = {
  // Dados do usuario logado.
  async eu(req, res) {
    res.json(req.usuario.toJSON ? req.usuario.toJSON() : req.usuario);
  },

  // Registra o token FCM do dispositivo para receber notificacoes push (UC006/RF013).
  async registrarToken(req, res) {
    const { token } = req.body || {};
    if (!token || typeof token !== 'string') {
      throw new ValidationError('Token de dispositivo obrigatorio', { campo: 'token' });
    }
    const { repos } = getContainer();
    const usuario = req.usuario;
    if (!Array.isArray(usuario.fcmTokens)) usuario.fcmTokens = [];
    if (!usuario.fcmTokens.includes(token)) {
      usuario.fcmTokens.push(token);
      await repos.usuarios.salvar(usuario);
    }
    res.status(204).end();
  },

  // Remove um token (logout do dispositivo).
  async removerToken(req, res) {
    const { token } = req.params;
    const { repos } = getContainer();
    const usuario = req.usuario;
    if (Array.isArray(usuario.fcmTokens)) {
      usuario.fcmTokens = usuario.fcmTokens.filter((t) => t !== token);
      await repos.usuarios.salvar(usuario);
    }
    res.status(204).end();
  },
};

module.exports = UsuarioController;
