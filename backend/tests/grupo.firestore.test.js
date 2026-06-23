'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const GrupoRepository = require('../src/repositories/firestore/GrupoRepository');
const Grupo = require('../src/models/Grupo');

// Firestore falso que captura o que foi gravado em cada documento.
function fakeDb(store) {
  return {
    collection() {
      return {
        doc(id) {
          return {
            async set(dados) {
              store[id] = dados;
            },
            async get() {
              const dados = store[id];
              return { exists: !!dados, data: () => dados };
            },
          };
        },
        where(campo, _op, valor) {
          return {
            limit() {
              return this;
            },
            async get() {
              const docs = Object.values(store)
                .filter((d) => Array.isArray(d[campo]) && d[campo].includes(valor))
                .map((d) => ({ data: () => d }));
              return { docs, empty: docs.length === 0 };
            },
          };
        },
      };
    },
  };
}

test('GrupoRepository.criar grava membrosIds para a busca por membro funcionar', async () => {
  const store = {};
  const repo = new GrupoRepository(fakeDb(store));
  const grupo = new Grupo({
    id: 'g1',
    nome: 'Familia',
    nomeIdoso: 'Dona Maria',
    cuidadorPrincipalId: 'u1',
    membros: [{ usuarioId: 'u1', perfil: 'CUIDADOR_PRINCIPAL', ingressoEm: new Date() }],
  });

  await repo.criar(grupo);

  // O documento gravado deve conter o campo derivado usado na consulta.
  assert.deepStrictEqual(store['g1'].membrosIds, ['u1']);

  // E a busca por membro deve devolver o grupo recem-criado (regressao do bug).
  const encontrados = await repo.buscarPorMembro('u1');
  assert.strictEqual(encontrados.length, 1);
  assert.strictEqual(encontrados[0].id, 'g1');
});
