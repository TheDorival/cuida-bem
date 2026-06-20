'use strict';

// Armazenamento em memoria compartilhado entre os repositorios (dev/testes).
// Em producao, o backend Firestore substitui estas estruturas (RNF008).
const store = {
  usuarios: new Map(),
  grupos: new Map(),
  rotinas: new Map(),
  alertas: new Map(),
  entradasDiario: new Map(),
  relatorios: new Map(),
  logsAuditoria: [],
};

function limpar() {
  store.usuarios.clear();
  store.grupos.clear();
  store.rotinas.clear();
  store.alertas.clear();
  store.entradasDiario.clear();
  store.relatorios.clear();
  store.logsAuditoria.length = 0;
}

module.exports = { store, limpar };
