'use strict';

const IAlertaRepository = require('../interfaces/IAlertaRepository');
const { store } = require('./store');

class AlertaRepository extends IAlertaRepository {
  async criar(alerta) {
    store.alertas.set(alerta.id, alerta);
    return alerta;
  }

  async listarPorRotina(rotinaId) {
    return [...store.alertas.values()].filter((a) => a.rotinaId === rotinaId);
  }

  async cancelarPorRotina(rotinaId) {
    for (const a of store.alertas.values()) {
      if (a.rotinaId === rotinaId) a.ativo = false;
    }
  }

  async salvar(alerta) {
    store.alertas.set(alerta.id, alerta);
    return alerta;
  }
}

module.exports = AlertaRepository;
