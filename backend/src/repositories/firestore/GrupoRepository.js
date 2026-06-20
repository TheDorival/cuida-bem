'use strict';

const IGrupoRepository = require('../interfaces/IGrupoRepository');
const Grupo = require('../../models/Grupo');

const COL = 'grupos';

class GrupoRepository extends IGrupoRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async criar(grupo) {
    await this.db.collection(COL).doc(grupo.id).set({ ...grupo });
    return grupo;
  }

  async buscarPorId(id) {
    const doc = await this.db.collection(COL).doc(id).get();
    return doc.exists ? new Grupo(doc.data()) : null;
  }

  async buscarPorMembro(usuarioId) {
    // Firestore: membros sao armazenados tambem como array de ids para query.
    const snap = await this.db.collection(COL).where('membrosIds', 'array-contains', usuarioId).get();
    return snap.docs.map((d) => new Grupo(d.data()));
  }

  async buscarPorTokenConvite(token) {
    const snap = await this.db.collection(COL).where('convitesTokens', 'array-contains', token).limit(1).get();
    return snap.empty ? null : new Grupo(snap.docs[0].data());
  }

  async salvar(grupo) {
    const dados = { ...grupo };
    dados.membrosIds = grupo.membros.map((m) => m.usuarioId);
    dados.convitesTokens = grupo.convites.map((c) => c.token);
    await this.db.collection(COL).doc(grupo.id).set(dados, { merge: false });
    return grupo;
  }
}

module.exports = GrupoRepository;
