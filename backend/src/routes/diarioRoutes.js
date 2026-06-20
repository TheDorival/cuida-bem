'use strict';

const { Router } = require('express');
const DiarioController = require('../controllers/DiarioController');
const { asyncHandler } = require('../middlewares/asyncHandler');

const router = Router({ mergeParams: true });

// UC004 - Diario de Saude do Idoso
router.post('/', asyncHandler(DiarioController.registrar));
router.get('/', asyncHandler(DiarioController.listar));

module.exports = router;
