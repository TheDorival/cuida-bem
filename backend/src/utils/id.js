'use strict';

const { randomUUID } = require('crypto');

// Gera identificadores unicos para entidades e tokens de convite.
function novoId(prefixo = '') {
  const id = randomUUID();
  return prefixo ? `${prefixo}_${id}` : id;
}

function novoToken() {
  return randomUUID().replace(/-/g, '');
}

module.exports = { novoId, novoToken };
