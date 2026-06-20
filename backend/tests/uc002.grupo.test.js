'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

test('UC002: cria grupo, convida e aceita membro', async () => {
  const { container, principal, auxiliar } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'Familia Silva', nomeIdoso: 'Seu Jose' });
  assert.equal(grupo.membros.length, 1);

  const convite = await container.grupoService.convidarMembro(principal, grupo.id, { email: 'bia@ex.com' });
  assert.ok(convite.token);

  const atualizado = await container.grupoService.aceitarConvite(auxiliar, convite.token);
  assert.equal(atualizado.membros.length, 2);
});

test('UC002: RN002 bloqueia gestao por perfil nao autorizado', async () => {
  const { container, principal, auxiliar } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  const convite = await container.grupoService.convidarMembro(principal, grupo.id, { email: 'bia@ex.com' });
  await container.grupoService.aceitarConvite(auxiliar, convite.token);

  await assert.rejects(
    () => container.grupoService.removerMembro(auxiliar, grupo.id, 'principal'),
    (e) => e.code === 'FORBIDDEN',
  );
});

test('UC002: FA01 remove membro mantendo log de auditoria (RN008/RN010)', async () => {
  const { container, principal, auxiliar } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  const convite = await container.grupoService.convidarMembro(principal, grupo.id, { email: 'bia@ex.com' });
  await container.grupoService.aceitarConvite(auxiliar, convite.token);

  const out = await container.grupoService.removerMembro(principal, grupo.id, 'auxiliar');
  assert.equal(out.membros.length, 1);
  const logs = await container.auditoria.listarPorGrupo(grupo.id);
  assert.ok(logs.some((l) => l.acao === 'MEMBRO_REMOVIDO'));
});
