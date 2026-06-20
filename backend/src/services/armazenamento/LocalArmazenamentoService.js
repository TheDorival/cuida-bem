'use strict';

const fs = require('fs');
const path = require('path');
const IArmazenamentoService = require('./IArmazenamentoService');

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
    return { url: `/reports/${nomeArquivo}` };
  }
}

module.exports = LocalArmazenamentoService;
