'use strict';

const { Router } = require('express');
const { autenticar } = require('../middlewares/auth');
const grupoRoutes = require('./grupoRoutes');
const rotinaRoutes = require('./rotinaRoutes');
const diarioRoutes = require('./diarioRoutes');
const relatorioRoutes = require('./relatorioRoutes');
const jobRoutes = require('./jobRoutes');

const router = Router();

router.get('/', (req, res) => {
  res.json({
    api: 'CuidaBem 1.0',
    versao: 'v1',
    recursos: ['/grupos', '/grupos/:grupoId/rotinas', '/grupos/:grupoId/diario', '/grupos/:grupoId/relatorios'],
  });
});

// Todas as rotas de recurso exigem autenticacao (UC001).
router.use('/grupos', autenticar, grupoRoutes);
router.use('/grupos/:grupoId/rotinas', autenticar, rotinaRoutes);
router.use('/grupos/:grupoId/diario', autenticar, diarioRoutes);
router.use('/grupos/:grupoId/relatorios', autenticar, relatorioRoutes);
router.use('/jobs', jobRoutes);

module.exports = router;
