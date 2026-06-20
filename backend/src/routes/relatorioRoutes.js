'use strict';

const { Router } = require('express');
const RelatorioController = require('../controllers/RelatorioController');
const { asyncHandler } = require('../middlewares/asyncHandler');

const router = Router({ mergeParams: true });

// UC007 - Geracao de Relatorio de Evolucao
router.post('/', asyncHandler(RelatorioController.gerar));
router.get('/', asyncHandler(RelatorioController.listar));

module.exports = router;
