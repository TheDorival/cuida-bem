'use strict';

const { Router } = require('express');

const router = Router();

router.get('/', (req, res) => {
  res.json({
    api: 'CuidaBem 1.0',
    versao: 'v1',
    recursos: ['/grupos', '/rotinas', '/diario', '/relatorios'],
  });
});

module.exports = router;
