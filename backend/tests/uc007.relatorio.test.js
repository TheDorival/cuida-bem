'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

test('UC007: gera relatorio com registros no periodo', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  await container.diarioService.registrarEntrada(principal, grupo.id, { categoria: 'SAUDE', descricao: 'Consulta' });

  const hoje = new Date();
  const ontem = new Date(Date.now() - 86400000);
  const amanha = new Date(Date.now() + 86400000);
  const rel = await container.relatorioService.gerarRelatorio(principal, grupo.id, {
    periodoInicio: ontem.toISOString(), periodoFim: amanha.toISOString(),
  });
  assert.equal(rel.totalEntradas, 1);
  assert.ok(rel.urlPdf.endsWith('.pdf'));
  assert.equal(rel.versao, 1);
});

test('UC007: RN006 nao gera relatorio sem registros', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  const ontem = new Date(Date.now() - 86400000);
  const amanha = new Date(Date.now() + 86400000);
  await assert.rejects(
    () => container.relatorioService.gerarRelatorio(principal, grupo.id, {
      periodoInicio: ontem.toISOString(), periodoFim: amanha.toISOString(),
    }),
    (e) => e.code === 'VALIDATION_ERROR',
  );
});

test('UC007: FE02 rejeita periodo invalido', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  await assert.rejects(
    () => container.relatorioService.gerarRelatorio(principal, grupo.id, {
      periodoInicio: new Date().toISOString(), periodoFim: new Date(Date.now() - 86400000).toISOString(),
    }),
    (e) => e.code === 'VALIDATION_ERROR',
  );
});

test('UC007: relatorio de um unico dia inclui entradas do mesmo dia (fim do dia)', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  await container.diarioService.registrarEntrada(principal, grupo.id, { categoria: 'SAUDE', descricao: 'Hoje' });

  const hoje = new Date();
  const inicioDia = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate(), 0, 0, 0);
  const fimDia = new Date(hoje.getFullYear(), hoje.getMonth(), hoje.getDate(), 0, 0, 0);
  const rel = await container.relatorioService.gerarRelatorio(principal, grupo.id, {
    periodoInicio: inicioDia.toISOString(), periodoFim: fimDia.toISOString(),
  });
  assert.equal(rel.totalEntradas, 1);
});
