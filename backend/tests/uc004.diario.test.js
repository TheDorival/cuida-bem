'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const { setup } = require('./helpers');

test('UC004: registra entrada e filtra por categoria', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  await container.diarioService.registrarEntrada(principal, grupo.id, { categoria: 'SAUDE', descricao: 'Pressao ok' });
  await container.diarioService.registrarEntrada(principal, grupo.id, { categoria: 'HUMOR', descricao: 'Bem disposto' });

  const saude = await container.diarioService.listarEntradas(principal, grupo.id, { categorias: ['SAUDE'] });
  assert.equal(saude.length, 1);
  assert.equal(saude[0].categoria, 'SAUDE');
});

test('UC004: FE01 rejeita descricao acima de 500 caracteres', async () => {
  const { container, principal } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  await assert.rejects(
    () => container.diarioService.registrarEntrada(principal, grupo.id, { categoria: 'SAUDE', descricao: 'x'.repeat(501) }),
    (e) => e.code === 'VALIDATION_ERROR',
  );
});

test('UC004: FA02 familiar remoto e somente leitura', async () => {
  const { container, principal, familiar } = await setup();
  const grupo = await container.grupoService.criarGrupo(principal, { nome: 'G', nomeIdoso: 'I' });
  const convite = await container.grupoService.convidarMembro(principal, grupo.id, { email: 'caio@ex.com', perfil: 'FAMILIAR' });
  await container.grupoService.aceitarConvite(familiar, convite.token);

  await assert.rejects(
    () => container.diarioService.registrarEntrada(familiar, grupo.id, { categoria: 'SAUDE', descricao: 'x' }),
    (e) => e.code === 'FORBIDDEN',
  );
  const lista = await container.diarioService.listarEntradas(familiar, grupo.id, {});
  assert.ok(Array.isArray(lista));
});
