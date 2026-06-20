'use strict';

const { PerfilUsuario, StatusConvite } = require('./enums');

// Entidade Grupo de Cuidado (<<entity>>) - UC002.
class Grupo {
  constructor({
    id,
    nome,
    nomeIdoso,
    cuidadorPrincipalId,
    membros = [],
    convites = [],
    ativo = true,
    criadoEm = new Date(),
  }) {
    this.id = id;
    this.nome = nome;
    this.nomeIdoso = nomeIdoso;
    this.cuidadorPrincipalId = cuidadorPrincipalId;
    // membros: [{ usuarioId, perfil, ingressoEm }]
    this.membros = membros;
    // convites: [{ token, email, perfil, status, criadoEm, expiraEm }]
    this.convites = convites;
    this.ativo = ativo;
    this.criadoEm = criadoEm;
  }

  ehMembro(usuarioId) {
    return this.membros.some((m) => m.usuarioId === usuarioId);
  }

  ehCuidadorPrincipal(usuarioId) {
    return this.cuidadorPrincipalId === usuarioId;
  }

  conviteValido(token) {
    const c = this.convites.find((conv) => conv.token === token);
    if (!c) return null;
    if (c.status !== StatusConvite.PENDENTE) return null;
    if (c.expiraEm && new Date(c.expiraEm) < new Date()) return null;
    return c;
  }

  toJSON() {
    return {
      id: this.id,
      nome: this.nome,
      nomeIdoso: this.nomeIdoso,
      cuidadorPrincipalId: this.cuidadorPrincipalId,
      membros: this.membros,
      convites: this.convites.map((c) => ({ ...c, token: undefined })),
      ativo: this.ativo,
      criadoEm: this.criadoEm,
    };
  }
}

Grupo.PerfilUsuario = PerfilUsuario;

module.exports = Grupo;
