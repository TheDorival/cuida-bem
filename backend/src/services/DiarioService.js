'use strict';

const EntradaDiario = require('../models/EntradaDiario');
const { novoId } = require('../utils/id');
const { CategoriaDiario, PerfilUsuario, AcaoAuditoria } = require('../models/enums');
const { exigirTexto, exigirEnum, exigir } = require('../utils/validators');
const { NotFoundError, ForbiddenError } = require('../utils/errors');

const PERFIS_ESCRITA = [PerfilUsuario.CUIDADOR_PRINCIPAL, PerfilUsuario.CUIDADOR_AUXILIAR];

// Servico de negocio do UC004 - Diario de Saude do Idoso.
class DiarioService {
  constructor(repos, notificacao, auditoria) {
    this.repos = repos;
    this.notificacao = notificacao;
    this.auditoria = auditoria;
  }

  // Passos 1-8: registrar nova entrada e, se importante, notificar o grupo (RF013).
  async registrarEntrada(usuario, grupoId, dados) {
    const { grupo, membro } = await this._exigirMembro(usuario, grupoId);

    // FA02 / controle de acesso por perfil (UC009): Familiar Remoto e somente leitura.
    if (!PERFIS_ESCRITA.includes(membro.perfil)) {
      await this.auditoria.registrar({
        grupoId,
        usuarioId: usuario.id,
        acao: AcaoAuditoria.ACESSO_NEGADO,
        detalhes: { operacao: 'registrar_diario', perfil: membro.perfil },
      });
      throw new ForbiddenError('Perfil somente leitura nao pode registrar entradas no diario');
    }

    const categoria = exigirEnum(dados.categoria, CategoriaDiario, 'categoria');
    const descricao = exigirTexto(dados.descricao, 'descricao', 500);

    const entrada = new EntradaDiario({
      id: novoId('dia'),
      grupoId: grupo.id,
      categoria,
      descricao,
      importante: Boolean(dados.importante),
      autorId: usuario.id, // nao alteravel apos salvar (passo 5)
      autorNome: usuario.nome,
      criadaEm: new Date(),
    });
    await this.repos.entradasDiario.criar(entrada);

    await this.auditoria.registrar({
      grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.DIARIO_REGISTRADO,
      detalhes: { entradaId: entrada.id, importante: entrada.importante },
    });

    if (entrada.importante) {
      await this._notificarGrupo(grupo, usuario, entrada);
    }
    return entrada;
  }

  // Passo 1 / FA01: consultar historico com filtros por data e categoria (RF005).
  async listarEntradas(usuario, grupoId, filtros = {}) {
    await this._exigirMembro(usuario, grupoId);
    let dataFim = filtros.dataFim || null;
    if (dataFim) {
      dataFim = new Date(dataFim);
      dataFim.setHours(23, 59, 59, 999); // periodo inclusivo do dia final
    }
    const normalizado = {
      categorias: filtros.categorias && filtros.categorias.length ? filtros.categorias : null,
      dataInicio: filtros.dataInicio || null,
      dataFim,
    };
    return this.repos.entradasDiario.listarPorGrupo(grupoId, normalizado);
  }

  async _notificarGrupo(grupo, autor, entrada) {
    const tokens = [];
    for (const m of grupo.membros) {
      if (m.usuarioId === autor.id) continue;
      const u = await this.repos.usuarios.buscarPorId(m.usuarioId);
      if (u && u.fcmTokens) tokens.push(...u.fcmTokens);
    }
    await this.notificacao.enviar(tokens, {
      titulo: 'Nova entrada importante no diario',
      corpo: `${autor.nome}: ${entrada.descricao.slice(0, 80)}`,
      dados: { entradaId: entrada.id, grupoId: grupo.id, tipo: 'DIARIO' },
    });
  }

  async _exigirMembro(usuario, grupoId) {
    const grupo = await this.repos.grupos.buscarPorId(grupoId);
    if (!grupo) throw new NotFoundError('Grupo nao encontrado');
    const membro = grupo.membros.find((m) => m.usuarioId === usuario.id);
    if (!membro) {
      // FE02: registra tentativa de acesso indevido (RN003/RN010).
      await this.auditoria.registrar({
        grupoId,
        usuarioId: usuario.id,
        acao: AcaoAuditoria.ACESSO_NEGADO,
        detalhes: { recurso: 'diario' },
      });
      throw new ForbiddenError('Usuario nao pertence ao grupo (RN003)');
    }
    return { grupo, membro };
  }
}

module.exports = DiarioService;
