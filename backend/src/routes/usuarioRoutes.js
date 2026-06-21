'use strict';

const { Router } = require('express');
const UsuarioController = require('../controllers/UsuarioController');
const { asyncHandler } = require('../middlewares/asyncHandler');

const router = Router();

router.get('/me', asyncHandler(UsuarioController.eu));
router.post('/me/fcm-token', asyncHandler(UsuarioController.registrarToken));
router.delete('/me/fcm-token/:token', asyncHandler(UsuarioController.removerToken));

module.exports = router;
