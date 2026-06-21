'use strict';

const fs = require('fs');
const path = require('path');
const IArmazenamentoService = require('./IArmazenamentoService');
const env = require('../../config/env');

const DIR_RELATORIOS = path.join(process.cwd(), 'reports');

// Implementacao de desenvolvimento: grava o PDF em disco e expoe via /reports.
class LocalArmazenamentoService extends IArmazenamentoService {
  constructor() {
    super();
    if (!fs.existsSync(DIR_RELATORIOS)) fs.mkdirSync(DIR_RELATORIOS, { recursive: true });
  }

  async salvarPdf(nomeArquivo, buffer) {
    const caminho = path.join(DIR_RELATORIOS, nomeArquivo);
    await fs.promises.writeFile(caminho, buffer);
    const base = (env.appBaseUrl || '').replace(/\/$/, '');
    return { url: `${base}/reports/${nomeArquivo}` };
  }
}

module.exports = LocalArmazenamentoService;
