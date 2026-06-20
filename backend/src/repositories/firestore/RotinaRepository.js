'use strict';

const IRotinaRepository = require('../interfaces/IRotinaRepository');
const Rotina = require('../../models/Rotina');

const COL = 'rotinas';

class RotinaRepository extends IRotinaRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async criar(rotina) {
    await this.db.collection(COL).doc(rotina.id).set({ ...rotina });
    return rotina;
  }

  async buscarPorId(id) {
    const doc = await this.db.collection(COL).doc(id).get();
    return doc.exists ? new Rotina(doc.data()) : null;
  }

  async listarPorGrupo(grupoId, filtros = {}) {
    let q = this.db.collection(COL).where('grupoId', '==', grupoId);
    if (filtros.apenasAtivas) q = q.where('ativa', '==', true);
    if (filtros.tipo) q = q.where('tipo', '==', filtros.tipo);
    const snap = await q.get();
    return snap.docs.map((d) => new Rotina(d.data())).sort((a, b) => (a.horario || '').localeCompare(b.horario || ''));
  }

  async salvar(rotina) {
    await this.db.collection(COL).doc(rotina.id).set({ ...rotina }, { merge: false });
    return rotina;
  }
}

module.exports = RotinaRepository;
