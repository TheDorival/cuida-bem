'use strict';

const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');

const DIR_RELATORIOS = path.join(process.cwd(), 'reports');

// Servico de geracao de PDF do relatorio de evolucao (UC007).
// Em producao, o arquivo pode ser enviado ao Firebase Storage; aqui e
// persistido localmente e exposto via URL relativa.
class PdfService {
  constructor() {
    if (!fs.existsSync(DIR_RELATORIOS)) fs.mkdirSync(DIR_RELATORIOS, { recursive: true });
  }

  async gerarRelatorio({ relatorioId, grupo, periodoInicio, periodoFim, categorias, entradas }) {
    const nomeArquivo = `${relatorioId}.pdf`;
    const caminho = path.join(DIR_RELATORIOS, nomeArquivo);

    await new Promise((resolve, reject) => {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const stream = fs.createWriteStream(caminho);
      stream.on('finish', resolve);
      stream.on('error', reject);
      doc.pipe(stream);

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
          { continued: false },
        );
        doc.fillColor('#333').fontSize(10).text(e.descricao, { indent: 12 });
        doc.fillColor('#888').fontSize(8).text(`autor: ${e.autorNome || e.autorId}`, { indent: 12 });
        doc.moveDown(0.5);
      });

      if (!entradas.length) {
        doc.fillColor('#888').text('Nenhum registro no periodo selecionado.');
      }

      doc.end();
    });

    return { caminho, url: `/reports/${nomeArquivo}` };
  }
}

function formatarData(d) {
  return new Date(d).toLocaleDateString('pt-BR');
}
function formatarDataHora(d) {
  return new Date(d).toLocaleString('pt-BR');
}

module.exports = PdfService;
