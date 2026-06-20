'use strict';

const Rotina = require('../models/Rotina');
const { novoId } = require('../utils/id');
const { TipoRotina, FrequenciaRotina, StatusRotina, PerfilUsuario, AcaoAuditoria } = require('../models/enums');
const { exigirTexto, exigirHorario, exigirEnum, exigir } = require('../utils/validators');
const { NotFoundError, ForbiddenError, ConflictError } = require('../utils/errors');

// Servico de negocio do UC003 - Gestao de Rotinas de Cuidado.
class RotinaService {
  constructor(repos, alertaService, auditoria) {
    this.repos = repos;
    this.alertaService = alertaService;
    this.auditoria = auditoria;
  }

  // Passos 1-8: cadastrar nova rotina e agendar alertas.
  async criarRotina(usuario, grupoId, dados) {
    const grupo = await this._exigirMembro(usuario, grupoId);

    const rotina = new Rotina({
      id: novoId('rot'),
      grupoId: grupo.id,
      tipo: exigirEnum(dados.tipo, TipoRotina, 'tipo'),
      descricao: exigirTexto(dados.descricao, 'descricao', 200),
      horario: exigirHorario(dados.horario),
      frequencia: exigirEnum(dados.frequencia, FrequenciaRotina, 'frequencia'),
      diaSemana: dados.diaSemana ?? null,
      diaMes: dados.diaMes ?? null,
      dataUnica: dados.dataUnica ?? null,
      status: StatusRotina.PENDENTE,
      ativa: true,
      criadaPor: usuario.id,
    });
    this._validarParametrosFrequencia(rotina);

    await this.repos.rotinas.criar(rotina);
    const alerta = await this.alertaService.agendarParaRotina(rotina);

    await this.auditoria.registrar({
      grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.ROTINA_CRIADA,
      detalhes: { rotinaId: rotina.id, tipo: rotina.tipo },
    });

    return { rotina, alertaAgendado: Boolean(alerta) };
  }

  async listarRotinas(usuario, grupoId, filtros = {}) {
    await this._exigirMembro(usuario, grupoId);
    return this.repos.rotinas.listarPorGrupo(grupoId, filtros);
  }

  // FA01: editar rotina e recalcular alertas.
  async editarRotina(usuario, rotinaId, dados) {
    const rotina = await this._exigirRotina(rotinaId);
    await this._exigirMembro(usuario, rotina.grupoId);

    if (dados.tipo !== undefined) rotina.tipo = exigirEnum(dados.tipo, TipoRotina, 'tipo');
    if (dados.descricao !== undefined) rotina.descricao = exigirTexto(dados.descricao, 'descricao', 200);
    if (dados.horario !== undefined) rotina.horario = exigirHorario(dados.horario);
    if (dados.frequencia !== undefined) rotina.frequencia = exigirEnum(dados.frequencia, FrequenciaRotina, 'frequencia');
    if (dados.diaSemana !== undefined) rotina.diaSemana = dados.diaSemana;
    if (dados.diaMes !== undefined) rotina.diaMes = dados.diaMes;
    if (dados.dataUnica !== undefined) rotina.dataUnica = dados.dataUnica;
    this._validarParametrosFrequencia(rotina);

    await this.repos.rotinas.salvar(rotina);
    await this.alertaService.agendarParaRotina(rotina);

    await this.auditoria.registrar({
      grupoId: rotina.grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.ROTINA_EDITADA,
      detalhes: { rotinaId: rotina.id },
    });
    return rotina;
  }

  // FA02: concluir rotina. Conclusao nao pode ser revertida (RN004).
  async concluirRotina(usuario, rotinaId) {
    const rotina = await this._exigirRotina(rotinaId);
    await this._exigirMembro(usuario, rotina.grupoId);
    if (rotina.status === StatusRotina.CONCLUIDA) {
      throw new ConflictError('Rotina ja concluida; a conclusao nao pode ser revertida (RN004)');
    }
    rotina.status = StatusRotina.CONCLUIDA;
    rotina.statusAtualizadoEm = new Date();
    await this.repos.rotinas.salvar(rotina);

    await this.auditoria.registrar({
      grupoId: rotina.grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.ROTINA_CONCLUIDA,
      detalhes: { rotinaId: rotina.id },
    });
    return rotina;
  }

  // FA03: desativar rotina; cancela alertas futuros e mantem historico.
  async desativarRotina(usuario, rotinaId) {
    const rotina = await this._exigirRotina(rotinaId);
    await this._exigirMembro(usuario, rotina.grupoId);
    rotina.ativa = false;
    rotina.status = StatusRotina.DESATIVADA;
    await this.repos.rotinas.salvar(rotina);
    await this.alertaService.cancelarParaRotina(rotina.id);

    await this.auditoria.registrar({
      grupoId: rotina.grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.ROTINA_DESATIVADA,
      detalhes: { rotinaId: rotina.id },
    });
    return rotina;
  }

  // RN004: reseta o status diario das rotinas concluidas (executado por job diario).
  async resetarStatusDiario(grupoId) {
    const rotinas = await this.repos.rotinas.listarPorGrupo(grupoId, { apenasAtivas: true });
    for (const r of rotinas) {
      if (r.status === StatusRotina.CONCLUIDA && r.frequencia !== FrequenciaRotina.UNICA) {
        r.status = StatusRotina.PENDENTE;
        r.statusAtualizadoEm = new Date();
        await this.repos.rotinas.salvar(r);
      }
    }
  }

  _validarParametrosFrequencia(rotina) {
    if (rotina.frequencia === FrequenciaRotina.SEMANAL) {
      exigir(Number.isInteger(rotina.diaSemana) && rotina.diaSemana >= 0 && rotina.diaSemana <= 6,
        "Frequencia semanal exige 'diaSemana' (0-6)", 'diaSemana');
    }
    if (rotina.frequencia === FrequenciaRotina.MENSAL) {
      exigir(Number.isInteger(rotina.diaMes) && rotina.diaMes >= 1 && rotina.diaMes <= 31,
        "Frequencia mensal exige 'diaMes' (1-31)", 'diaMes');
    }
    if (rotina.frequencia === FrequenciaRotina.UNICA) {
      exigir(Boolean(rotina.dataUnica), "Frequencia unica exige 'dataUnica'", 'dataUnica');
    }
  }

  async _exigirRotina(rotinaId) {
    const rotina = await this.repos.rotinas.buscarPorId(rotinaId);
    if (!rotina) throw new NotFoundError('Rotina nao encontrada');
    return rotina;
  }

  async _exigirMembro(usuario, grupoId) {
    const grupo = await this.repos.grupos.buscarPorId(grupoId);
    if (!grupo) throw new NotFoundError('Grupo nao encontrado');
    if (!grupo.ehMembro(usuario.id)) throw new ForbiddenError('Usuario nao pertence ao grupo (RN003)');
    return grupo;
  }
}

module.exports = RotinaService;
