'use strict';

// Entidade Alerta (<<entity>>) - UC006, agendado a partir de uma Rotina.
class Alerta {
  constructor({
    id,
    rotinaId,
    grupoId,
    horario, // 'HH:MM'
    frequencia,
    proximoDisparo, // ISO datetime
    ativo = true,
    criadoEm = new Date(),
  }) {
    this.id = id;
    this.rotinaId = rotinaId;
    this.grupoId = grupoId;
    this.horario = horario;
    this.frequencia = frequencia;
    this.proximoDisparo = proximoDisparo;
    this.ativo = ativo;
    this.criadoEm = criadoEm;
  }

  toJSON() {
    return { ...this };
  }
}

module.exports = Alerta;
