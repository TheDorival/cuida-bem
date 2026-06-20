'use strict';

const IUsuarioRepository = require('../interfaces/IUsuarioRepository');
const Usuario = require('../../models/Usuario');

const COL = 'usuarios';

class UsuarioRepository extends IUsuarioRepository {
  constructor(db) {
    super();
    this.db = db;
  }

  async buscarPorId(id) {
    const doc = await this.db.collection(COL).doc(id).get();
    return doc.exists ? new Usuario(doc.data()) : null;
  }

  async buscarPorEmail(email) {
    const snap = await this.db.collection(COL).where('email', '==', email).limit(1).get();
    return snap.empty ? null : new Usuario(snap.docs[0].data());
  }

  async salvar(usuario) {
    await this.db.collection(COL).doc(usuario.id).set({ ...usuario }, { merge: true });
    return usuario;
  }
}

module.exports = UsuarioRepository;
