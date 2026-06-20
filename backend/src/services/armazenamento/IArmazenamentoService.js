'use strict';

// Interface de armazenamento de arquivos (UC007). Abstrai onde o PDF do
// relatorio e persistido, permitindo trocar disco local por Firebase Storage
// sem impacto no RelatorioService (RNF008/SOLID).
class IArmazenamentoService {
  // Recebe um Buffer e retorna { url } publico/assinado do arquivo salvo.
  async salvarPdf(nomeArquivo, buffer) { throw new Error('nao implementado'); }
}

module.exports = IArmazenamentoService;
