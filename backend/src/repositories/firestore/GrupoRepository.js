'use strict';

const IGrupoRepository = require('../interfaces/IGrupoRepository');
const Grupo = require('../../models/Grupo');

const COL = 'grupos';

class GrupoRepository extends IGrupoRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  // Serializa o grupo para o Firestore incluindo os campos derivados usados nas
  // consultas (array-contains): membrosIds e convitesTokens. Sem eles, o grupo
  // existe no banco mas nao e encontrado por buscarPorMembro/buscarPorTokenConvite.
  _serializar(grupo) {
    const dados = { ...grupo };
    dados.membrosIds = (grupo.membros || []).map((m) => m.usuarioId);
    dados.convitesTokens = (grupo.convites || []).map((c) => c.token);
    return dados;
  }

  async criar(grupo) {
    await this.db.collection(COL).doc(grupo.id).set(this._serializar(grupo));
    return grupo;
  }

  async buscarPorId(id) {
    const doc = await this.db.collection(COL).doc(id).get();
    return doc.exists ? new Grupo(doc.data()) : null;
  }

  async buscarPorMembro(usuarioId) {
    const snap = await this.db.collection(COL).where('membrosIds', 'array-contains', usuarioId).get();
    return snap.docs.map((d) => new Grupo(d.data()));
  }

  async buscarPorTokenConvite(token) {
    const snap = await this.db.collection(COL).where('convitesTokens', 'array-contains', token).limit(1).get();
    return snap.empty ? null : new Grupo(snap.docs[0].data());
  }

  async salvar(grupo) {
    await this.db.collection(COL).doc(grupo.id).set(this._serializar(grupo), { merge: false });
    return grupo;
  }
}

module.exports = GrupoRepository;
