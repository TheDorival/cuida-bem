'use strict';

const PDFDocument = require('pdfkit');

// Servico de geracao do PDF do relatorio de evolucao (UC007).
// Gera o documento em memoria (Buffer) e delega a persistencia ao
// IArmazenamentoService, mantendo a geracao independente do destino do arquivo.
class PdfService {
  constructor(armazenamento) {
    this.armazenamento = armazenamento;
  }

  async gerarRelatorio({ relatorioId, grupo, periodoInicio, periodoFim, categorias, entradas }) {
    const buffer = await this._montarPdf({ grupo, periodoInicio, periodoFim, categorias, entradas });
    const { url } = await this.armazenamento.salvarPdf(`${relatorioId}.pdf`, buffer);
    return { url };
  }

  _montarPdf({ grupo, periodoInicio, periodoFim, categorias, entradas }) {
    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const chunks = [];
      doc.on('data', (c) => chunks.push(c));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      doc.fontSize(20).text('CuidaBem - Relatorio de Evolucao', { align: 'center' });
      doc.moveDown(0.5);
      doc.fontSize(12).fillColor('#444')
        .text(`Idoso: ${grupo.nomeIdoso}`)
        .text(`Grupo: ${grupo.nome}`)
        .text(`Periodo: ${formatarData(periodoInicio)} a ${formatarData(periodoFim)}`)
        .text(`Categorias: ${categorias.length ? categorias.join(', ') : 'Todas'}`)
        .text(`Total de registros: ${entradas.length}`)
        .text(`Gerado em: ${formatarData(new Date())}`);
      doc.moveDown();
      doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke('#cccccc');
      doc.moveDown();

      entradas.forEach((e) => {
        doc.fillColor('#000').fontSize(11).text(
          `${formatarDataHora(e.criadaEm)}  [${e.categoria}]${e.importante ? ' *' : ''}`,
        );
        doc.fillColor('#333').fontSize(10).text(e.descricao, { indent: 12 });
        doc.fillColor('#888').fontSize(8).text(`autor: ${e.autorNome || e.autorId}`, { indent: 12 });
        doc.moveDown(0.5);
      });

      if (!entradas.length) doc.fillColor('#888').text('Nenhum registro no periodo selecionado.');
      doc.end();
    });
  }
}

function formatarData(d) {
  return new Date(d).toLocaleDateString('pt-BR');
}
function formatarDataHora(d) {
  return new Date(d).toLocaleString('pt-BR');
}

module.exports = PdfService;
