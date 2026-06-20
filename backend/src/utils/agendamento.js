'use strict';

const { FrequenciaRotina } = require('../models/enums');

// Calcula o proximo horario de disparo de um alerta a partir da frequencia,
// do horario (HH:MM) e dos parametros de dia (RN005).
function calcularProximoDisparo(rotina, base = new Date()) {
  const [h, m] = (rotina.horario || '00:00').split(':').map(Number);
  const proximo = new Date(base);
  proximo.setSeconds(0, 0);
  proximo.setHours(h, m, 0, 0);

  switch (rotina.frequencia) {
    case FrequenciaRotina.DIARIA:
      if (proximo <= base) proximo.setDate(proximo.getDate() + 1);
      return proximo;

    case FrequenciaRotina.SEMANAL: {
      const alvo = Number.isInteger(rotina.diaSemana) ? rotina.diaSemana : proximo.getDay();
      let delta = (alvo - proximo.getDay() + 7) % 7;
      if (delta === 0 && proximo <= base) delta = 7;
      proximo.setDate(proximo.getDate() + delta);
      return proximo;
    }

    case FrequenciaRotina.MENSAL: {
      const dia = Number.isInteger(rotina.diaMes) ? rotina.diaMes : proximo.getDate();
      proximo.setDate(dia);
      if (proximo <= base) proximo.setMonth(proximo.getMonth() + 1);
      proximo.setDate(dia);
      return proximo;
    }

    case FrequenciaRotina.UNICA: {
      if (!rotina.dataUnica) return null;
      const d = new Date(rotina.dataUnica);
      d.setHours(h, m, 0, 0);
      return d > base ? d : null;
    }

    default:
      return null;
  }
}

module.exports = { calcularProximoDisparo };
