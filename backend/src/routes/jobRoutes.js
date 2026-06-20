'use strict';

const { Router } = require('express');
const { asyncHandler } = require('../middlewares/asyncHandler');
const { dispararAlertasVencidos } = require('../jobs/dispatchAlertas');
const { UnauthorizedError } = require('../utils/errors');

const router = Router();

// Protecao por segredo compartilhado (Cloud Scheduler envia o header X-Job-Secret).
function exigirSegredo(req, _res, next) {
  const segredo = process.env.JOB_SECRET || '';
  if (!segredo || req.headers['x-job-secret'] !== segredo) {
    return next(new UnauthorizedError('Segredo de job invalido'));
  }
  return next();
}

// POST /api/v1/jobs/alertas/disparar -> dispara alertas vencidos (UC006)
router.post('/alertas/disparar', exigirSegredo, asyncHandler(async (req, res) => {
  const resultado = await dispararAlertasVencidos();
  res.json(resultado);
}));

module.exports = router;
