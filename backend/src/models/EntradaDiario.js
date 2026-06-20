'use strict';

const { CategoriaDiario } = require('./enums');

// Entidade EntradaDiario (<<entity>>) - UC004.
class EntradaDiario {
  constructor({
    id,
    grupoId,
    categoria,
    descricao,
    importante = false,
    autorId,
    autorNome = null,
    criadaEm = new Date(),
  }) {
    this.id = id;
    this.grupoId = grupoId;
    this.categoria = categoria;
    this.descricao = descricao;
    this.importante = importante;
    this.autorId = autorId; // nao alteravel apos salvar (FE/passo 5)
    this.autorNome = autorNome;
    this.criadaEm = criadaEm; // preenchida automaticamente, nao alteravel
  }

  toJSON() {
    return { ...this };
  }
}

EntradaDiario.Categoria = CategoriaDiario;

module.exports = EntradaDiario;
