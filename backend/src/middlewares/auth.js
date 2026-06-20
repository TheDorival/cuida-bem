'use strict';

const env = require('../config/env');
const { UnauthorizedError } = require('../utils/errors');
const { getRepositorios } = require('../repositories');
const Usuario = require('../models/Usuario');
const { PerfilUsuario } = require('../models/enums');

// Verifica o token do cabecalho Authorization: Bearer <token>.
// Em producao (firebase) valida o ID token via Firebase Auth.
// Em desenvolvimento (memory) aceita um header simplificado para testes locais.
async function autenticar(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new UnauthorizedError('Token de autenticacao ausente');

    let usuario;
    if (env.useFirebase) {
      const admin = require('firebase-admin');
      const { initFirebase } = require('../config/firebase');
      initFirebase();
      const decoded = await admin.auth().verifyIdToken(token);
      const repos = getRepositorios();
      usuario = await repos.usuarios.buscarPorId(decoded.uid);
      if (!usuario) {
        usuario = new Usuario({
          id: decoded.uid,
          nome: decoded.name || decoded.email || 'Usuario',
          email: decoded.email || '',
          perfil: PerfilUsuario.CUIDADOR_AUXILIAR,
        });
        await repos.usuarios.salvar(usuario);
      }
    } else {
      // Dev: token = id do usuario previamente cadastrado no store de memoria.
      const repos = getRepositorios();
      usuario = await repos.usuarios.buscarPorId(token);
      if (!usuario) throw new UnauthorizedError('Usuario de desenvolvimento nao encontrado para o token informado');
    }

    req.usuario = usuario;
    return next();
  } catch (err) {
    if (err.status) return next(err);
    return next(new UnauthorizedError('Falha na autenticacao'));
  }
}

module.exports = { autenticar };
