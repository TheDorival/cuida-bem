'use strict';

const IEntradaDiarioRepository = require('../interfaces/IEntradaDiarioRepository');
const EntradaDiario = require('../../models/EntradaDiario');

const COL = 'entradas_diario';

class EntradaDiarioRepository extends IEntradaDiarioRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async criar(entrada) {
    await this.db.collection(COL).doc(entrada.id).set({ ...entrada });
    return entrada;
  }

  async buscarPorId(id) {
    const doc = await this.db.collection(COL).doc(id).get();
    return doc.exists ? new EntradaDiario(doc.data()) : null;
  }

  async listarPorGrupo(grupoId, filtros = {}) {
    let q = this.db.collection(COL).where('grupoId', '==', grupoId);
    if (filtros.dataInicio) q = q.where('criadaEm', '>=', new Date(filtros.dataInicio));
    if (filtros.dataFim) q = q.where('criadaEm', '<=', new Date(filtros.dataFim));
    const snap = await q.orderBy('criadaEm', 'asc').get();
    let lista = snap.docs.map((d) => new EntradaDiario(d.data()));
    if (filtros.categorias && filtros.categorias.length) {
      lista = lista.filter((e) => filtros.categorias.includes(e.categoria));
    }
    return lista;
  }
}

module.exports = EntradaDiarioRepository;
