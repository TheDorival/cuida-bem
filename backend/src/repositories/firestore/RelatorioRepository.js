'use strict';

const IRelatorioRepository = require('../interfaces/IRelatorioRepository');
const Relatorio = require('../../models/Relatorio');

const COL = 'relatorios';

class RelatorioRepository extends IRelatorioRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async criar(relatorio) {
    await this.db.collection(COL).doc(relatorio.id).set({ ...relatorio });
    return relatorio;
  }

  async listarPorGrupo(grupoId) {
    const snap = await this.db.collection(COL).where('grupoId', '==', grupoId).orderBy('geradoEm', 'desc').get();
    return snap.docs.map((d) => new Relatorio(d.data()));
  }

  async contarVersoesPeriodo(grupoId, periodoInicio, periodoFim) {
    const snap = await this.db
      .collection(COL)
      .where('grupoId', '==', grupoId)
      .where('periodoInicio', '==', periodoInicio)
      .where('periodoFim', '==', periodoFim)
      .get();
    return snap.size;
  }
}

module.exports = RelatorioRepository;
