'use strict';

const { Router } = require('express');
const GrupoController = require('../controllers/GrupoController');
const { asyncHandler } = require('../middlewares/asyncHandler');

const router = Router();

// UC002 - Gestao de Grupo de Cuidado
router.post('/', asyncHandler(GrupoController.criar));
router.get('/', asyncHandler(GrupoController.listar));
router.get('/:grupoId', asyncHandler(GrupoController.obter));
router.post('/:grupoId/convites', asyncHandler(GrupoController.convidar));
router.post('/convites/:token/aceitar', asyncHandler(GrupoController.aceitarConvite));
router.delete('/:grupoId/membros/:usuarioId', asyncHandler(GrupoController.removerMembro));

module.exports = router;
