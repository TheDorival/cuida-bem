'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

test('Usuario: registra e remove token FCM idempotente', async () => {
  const { repos, principal } = await setup();
  if (!Array.isArray(principal.fcmTokens)) principal.fcmTokens = [];
  // simula registrarToken
  const token = 'tok-dispositivo-1';
  if (!principal.fcmTokens.includes(token)) principal.fcmTokens.push(token);
  await repos.usuarios.salvar(principal);
  // idempotente
  if (!principal.fcmTokens.includes(token)) principal.fcmTokens.push(token);
  const u = await repos.usuarios.buscarPorId('principal');
  assert.equal(u.fcmTokens.filter((t) => t === token).length, 1);

  // remover
  u.fcmTokens = u.fcmTokens.filter((t) => t !== token);
  await repos.usuarios.salvar(u);
  const u2 = await repos.usuarios.buscarPorId('principal');
  assert.ok(!u2.fcmTokens.includes(token));
});
