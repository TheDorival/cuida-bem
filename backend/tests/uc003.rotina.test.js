'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

async function comGrupo(container, principal) {
  return container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
}

test('UC003: cria rotina diaria e agenda alerta', async () => {
  const { container, principal } = await setup();
  const grupo = await comGrupo(container, principal);
  const out = await container.rotinaService.criarRotina(principal, grupo.id, {
    tipo: 'MEDICACAO', descricao: 'Tomar Losartana', horario: '08:00', frequencia: 'DIARIA',
  });
  assert.equal(out.rotina.status, 'PENDENTE');
  assert.equal(out.alertaAgendado, true);
});

test('UC003: FE01 rejeita horario invalido', async () => {
  const { container, principal } = await setup();
  const grupo = await comGrupo(container, principal);
  await assert.rejects(
    () => container.rotinaService.criarRotina(principal, grupo.id, {
      tipo: 'MEDICACAO', descricao: 'X', horario: '25:99', frequencia: 'DIARIA',
    }),
    (e) => e.code === 'VALIDATION_ERROR',
  );
});

test('UC003: RN004 conclusao nao pode ser revertida', async () => {
  const { container, principal } = await setup();
  const grupo = await comGrupo(container, principal);
  const { rotina } = await container.rotinaService.criarRotina(principal, grupo.id, {
    tipo: 'HIGIENE', descricao: 'Banho', horario: '07:00', frequencia: 'DIARIA',
  });
  await container.rotinaService.concluirRotina(principal, rotina.id);
  await assert.rejects(
    () => container.rotinaService.concluirRotina(principal, rotina.id),
    (e) => e.code === 'CONFLICT',
  );
});
