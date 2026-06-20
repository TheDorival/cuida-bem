'use strict';

const { Router } = require('express');
const { autenticar } = require('../middlewares/auth');
const grupoRoutes = require('./grupoRoutes');

const router = Router();

router.get('/', (req, res) => {
  res.json({
    api: 'CuidaBem 1.0',
    versao: 'v1',
    recursos: ['/grupos', '/rotinas', '/diario', '/relatorios'],
  });
});

// Todas as rotas de recurso exigem autenticacao (UC001).
router.use('/grupos', autenticar, grupoRoutes);

module.exports = router;
