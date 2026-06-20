'use strict';

const { TipoRotina, FrequenciaRotina, StatusRotina } = require('./enums');

// Entidade Rotina de Cuidado (<<entity>>) - UC003.
class Rotina {
  constructor({
    id,
    grupoId,
    tipo,
    descricao,
    horario, // 'HH:MM'
    frequencia,
    diaSemana = null, // 0-6 para frequencia SEMANAL
    diaMes = null, // 1-31 para frequencia MENSAL
    dataUnica = null, // ISO date para frequencia UNICA
    status = StatusRotina.PENDENTE,
    ativa = true,
    criadaPor,
    criadaEm = new Date(),
    statusAtualizadoEm = null,
  }) {
    this.id = id;
    this.grupoId = grupoId;
    this.tipo = tipo;
    this.descricao = descricao;
    this.horario = horario;
    this.frequencia = frequencia;
    this.diaSemana = diaSemana;
    this.diaMes = diaMes;
    this.dataUnica = dataUnica;
    this.status = status;
    this.ativa = ativa;
    this.criadaPor = criadaPor;
    this.criadaEm = criadaEm;
    this.statusAtualizadoEm = statusAtualizadoEm;
  }

  toJSON() {
    return { ...this };
  }
}

Rotina.Tipo = TipoRotina;
Rotina.Frequencia = FrequenciaRotina;
Rotina.Status = StatusRotina;

module.exports = Rotina;
