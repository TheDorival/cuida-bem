'use strict';

const { ValidationError } = require('./errors');

const REGEX_HORARIO = /^([01]\d|2[0-3]):[0-5]\d$/;
const REGEX_EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function exigir(condicao, mensagem, campo) {
  if (!condicao) throw new ValidationError(mensagem, campo ? { campo } : null);
}

function exigirTexto(valor, campo, max = null) {
  exigir(typeof valor === 'string' && valor.trim().length > 0, `Campo '${campo}' e obrigatorio`, campo);
  if (max) exigir(valor.trim().length <= max, `Campo '${campo}' excede ${max} caracteres`, campo);
  return valor.trim();
}

function exigirHorario(valor, campo = 'horario') {
  exigir(REGEX_HORARIO.test(valor || ''), `Campo '${campo}' deve estar no formato HH:MM`, campo);
  return valor;
}

function exigirEmail(valor, campo = 'email') {
  exigir(REGEX_EMAIL.test(valor || ''), `E-mail invalido`, campo);
  return valor.trim().toLowerCase();
}

function exigirEnum(valor, enumObj, campo) {
  const validos = Object.values(enumObj);
  exigir(validos.includes(valor), `Campo '${campo}' invalido. Valores: ${validos.join(', ')}`, campo);
  return valor;
}

function exigirData(valor, campo) {
  const d = new Date(valor);
  exigir(valor && !Number.isNaN(d.getTime()), `Campo '${campo}' deve ser uma data valida`, campo);
  return d;
}

module.exports = {
  REGEX_HORARIO,
  REGEX_EMAIL,
  exigir,
  exigirTexto,
  exigirHorario,
  exigirEmail,
  exigirEnum,
  exigirData,
};
