'use strict';

const Relatorio = require('../models/Relatorio');
const { novoId } = require('../utils/id');
const { CategoriaDiario, PerfilUsuario, AcaoAuditoria } = require('../models/enums');
const { exigirData, exigir } = require('../utils/validators');
const { NotFoundError, ForbiddenError, ValidationError, AppError } = require('../utils/errors');

// Servico de negocio do UC007 - Geracao de Relatorio de Evolucao.
class RelatorioService {
  constructor(repos, pdfService, auditoria) {
    this.repos = repos;
    this.pdfService = pdfService;
    this.auditoria = auditoria;
  }

  // Passos 1-8: gerar relatorio PDF a partir do diario (<<include>> UC004).
  async gerarRelatorio(usuario, grupoId, dados) {
    const grupo = await this._exigirGrupo(grupoId);
    // Geracao restrita ao Cuidador Principal (ator principal do UC007).
    if (!grupo.ehCuidadorPrincipal(usuario.id)) {
      throw new ForbiddenError('Apenas o Cuidador Principal pode gerar relatorios');
    }

    const inicio = exigirData(dados.periodoInicio, 'periodoInicio');
    const fim = exigirData(dados.periodoFim, 'periodoFim');
    // FE02: data inicial nao pode ser posterior a final.
    if (inicio > fim) throw new ValidationError('A data inicial nao pode ser posterior a final', { campo: 'periodo' });

    const categorias = Array.isArray(dados.categorias) ? dados.categorias.filter((c) => CategoriaDiario[c]) : [];

    // Passo 5: consulta entradas do diario no intervalo e categorias (<<include>> UC004).
    const entradas = await this.repos.entradasDiario.listarPorGrupo(grupoId, {
      dataInicio: inicio,
      dataFim: fim,
      categorias: categorias.length ? categorias : null,
    });

    // FE01 / RN006: exige ao menos um registro no periodo.
    if (!entradas.length) {
      throw new ValidationError('Nao ha registros no periodo selecionado; relatorio nao gerado (RN006)');
    }

    const versaoAnterior = await this.repos.relatorios.contarVersoesPeriodo(
      grupoId,
      inicio.toISOString(),
      fim.toISOString(),
    );

    const relatorioId = novoId('rel');
    let pdf;
    try {
      // Passo 6: compila os registros e gera o PDF.
      pdf = await this.pdfService.gerarRelatorio({
        relatorioId,
        grupo,
        periodoInicio: inicio,
        periodoFim: fim,
        categorias,
        entradas,
      });
    } catch (err) {
      // FE03: falha na geracao nao registra relatorio incompleto.
      throw new AppError('Falha ao gerar o PDF do relatorio; tente novamente', 502, 'PDF_FAILURE');
    }

    // Passo 7: persiste metadados e registra no log (RN010).
    const relatorio = new Relatorio({
      id: relatorioId,
      grupoId,
      periodoInicio: inicio.toISOString(),
      periodoFim: fim.toISOString(),
      categorias,
      urlPdf: pdf.url,
      totalEntradas: entradas.length,
      versao: versaoAnterior + 1, // FA02: nova versao mantendo as anteriores
      geradoPor: usuario.id,
    });
    await this.repos.relatorios.criar(relatorio);

    await this.auditoria.registrar({
      grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.RELATORIO_GERADO,
      detalhes: { relatorioId, totalEntradas: entradas.length, versao: relatorio.versao },
    });

    return relatorio;
  }

  async listarRelatorios(usuario, grupoId) {
    const grupo = await this._exigirGrupo(grupoId);
    if (!grupo.ehMembro(usuario.id)) throw new ForbiddenError('Usuario nao pertence ao grupo (RN003)');
    return this.repos.relatorios.listarPorGrupo(grupoId);
  }

  async _exigirGrupo(grupoId) {
    const grupo = await this.repos.grupos.buscarPorId(grupoId);
    if (!grupo) throw new NotFoundError('Grupo nao encontrado');
    return grupo;
  }
}

module.exports = RelatorioService;
