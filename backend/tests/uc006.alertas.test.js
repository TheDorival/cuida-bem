'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

test('UC006: dispara alertas vencidos e reagenda', async () => {
  const { container, repos, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  const { rotina } = await container.rotinaService.criarRotina(principal, grupo.id, {
    tipo: 'MEDICACAO', descricao: 'Remedio', horario: '08:00', frequencia: 'DIARIA',
  });

  // forca o alerta a estar vencido
  const alertas = await repos.alertas.listarPorRotina(rotina.id);
  assert.equal(alertas.length, 1);
  alertas[0].proximoDisparo = new Date(Date.now() - 1000).toISOString();
  await repos.alertas.salvar(alertas[0]);

  const r = await container.alertaService.dispararPendentes(new Date());
  assert.equal(r.alertas, 1);
  assert.ok(r.notificacoesEnviadas >= 1); // principal tem token fcm

  // reagendou para o futuro
  const depois = await repos.alertas.listarPorRotina(rotina.id);
  assert.ok(new Date(depois[0].proximoDisparo) > new Date());
});
