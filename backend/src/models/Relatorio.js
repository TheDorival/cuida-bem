'use strict';

// Entidade Relatorio de Evolucao (<<entity>>) - UC007.
class Relatorio {
  constructor({
    id,
    grupoId,
    periodoInicio, // ISO date
    periodoFim, // ISO date
    categorias = [], // vazio = todas
    urlPdf = null,
    totalEntradas = 0,
    versao = 1,
    geradoPor,
    geradoEm = new Date(),
  }) {
    this.id = id;
    this.grupoId = grupoId;
    this.periodoInicio = periodoInicio;
    this.periodoFim = periodoFim;
    this.categorias = categorias;
    this.urlPdf = urlPdf;
    this.totalEntradas = totalEntradas;
    this.versao = versao;
    this.geradoPor = geradoPor;
    this.geradoEm = geradoEm;
  }

  toJSON() {
    return { ...this };
  }
}

module.exports = Relatorio;
