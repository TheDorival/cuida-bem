'use strict';

const { PerfilUsuario } = require('./enums');

// Entidade Usuario (<<entity>>). Identidade gerida pelo Firebase Auth.
class Usuario {
  constructor({ id, nome, email, perfil = PerfilUsuario.CUIDADOR_AUXILIAR, fcmTokens = [], criadoEm = new Date() }) {
    this.id = id;
    this.nome = nome;
    this.email = email;
    this.perfil = perfil;
    this.fcmTokens = fcmTokens; // tokens de dispositivo para push (FCM)
    this.criadoEm = criadoEm;
  }

  toJSON() {
    return {
      id: this.id,
      nome: this.nome,
      email: this.email,
      perfil: this.perfil,
      criadoEm: this.criadoEm,
    };
  }
}

module.exports = Usuario;
