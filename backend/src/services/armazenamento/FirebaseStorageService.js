'use strict';

const IArmazenamentoService = require('./IArmazenamentoService');

// Implementacao de producao: envia o PDF ao Firebase Storage (bucket padrao)
// e retorna uma URL assinada de leitura.
class FirebaseStorageService extends IArmazenamentoService {
  constructor(storage) {
    super();
    this.storage = storage;
  }

  async salvarPdf(nomeArquivo, buffer) {
    const bucket = this.storage.bucket();
    const arquivo = bucket.file(`relatorios/${nomeArquivo}`);
    await arquivo.save(buffer, { contentType: 'application/pdf', resumable: false });
    const [url] = await arquivo.getSignedUrl({
      action: 'read',
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 dias
    });
    return { url };
  }
}

module.exports = FirebaseStorageService;
