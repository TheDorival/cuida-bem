'use strict';

const { Router } = require('express');
const RotinaController = require('../controllers/RotinaController');
const { asyncHandler } = require('../middlewares/asyncHandler');

// mergeParams para acessar :grupoId quando montado sob /grupos/:grupoId
const router = Router({ mergeParams: true });

// UC003 - Gestao de Rotinas de Cuidado
router.post('/', asyncHandler(RotinaController.criar));
router.get('/', asyncHandler(RotinaController.listar));
router.patch('/:rotinaId', asyncHandler(RotinaController.editar));
router.post('/:rotinaId/concluir', asyncHandler(RotinaController.concluir));
router.post('/:rotinaId/desativar', asyncHandler(RotinaController.desativar));

module.exports = router;
