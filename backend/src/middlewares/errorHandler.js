'use strict';

const { AppError } = require('../utils/errors');

// Rota nao encontrada (404).
function notFoundHandler(req, res, _next) {
  res.status(404).json({
    error: { code: 'NOT_FOUND', message: `Rota nao encontrada: ${req.method} ${req.originalUrl}` },
  });
}

// Tratamento centralizado de erros.
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, _next) {
  if (err instanceof AppError) {
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, details: err.details || undefined },
    });
  }

  // eslint-disable-next-line no-console
  console.error('[erro nao tratado]', err);
  return res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'Erro interno do servidor' },
  });
}

module.exports = { notFoundHandler, errorHandler };
