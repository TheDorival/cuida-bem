'use strict';

const IAlertaRepository = require('../interfaces/IAlertaRepository');
const Alerta = require('../../models/Alerta');

const COL = 'alertas';

class AlertaRepository extends IAlertaRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async criar(alerta) {
    await this.db.collection(COL).doc(alerta.id).set({ ...alerta });
    return alerta;
  }

  async listarPorRotina(rotinaId) {
    const snap = await this.db.collection(COL).where('rotinaId', '==', rotinaId).get();
    return snap.docs.map((d) => new Alerta(d.data()));
  }

  async cancelarPorRotina(rotinaId) {
    const snap = await this.db.collection(COL).where('rotinaId', '==', rotinaId).get();
    const batch = this.db.batch();
    snap.docs.forEach((d) => batch.update(d.ref, { ativo: false }));
    await batch.commit();
  }

  async listarVencidos(agora = new Date()) {
    const snap = await this.db
      .collection(COL)
      .where('ativo', '==', true)
      .where('proximoDisparo', '<=', agora.toISOString())
      .get();
    return snap.docs.map((d) => new Alerta(d.data()));
  }

  async salvar(alerta) {
    await this.db.collection(COL).doc(alerta.id).set({ ...alerta }, { merge: false });
    return alerta;
  }
}

module.exports = AlertaRepository;
