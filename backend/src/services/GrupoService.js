'use strict';

const Grupo = require('../models/Grupo');
const { novoId, novoToken } = require('../utils/id');
const { PerfilUsuario, StatusConvite, AcaoAuditoria } = require('../models/enums');
const { exigirTexto, exigirEmail, exigirEnum } = require('../utils/validators');
const { NotFoundError, ForbiddenError, ConflictError, ValidationError } = require('../utils/errors');
const env = require('../config/env');

const DIAS_VALIDADE_CONVITE = 7;

// Servico de negocio do UC002 - Gestao de Grupo de Cuidado.
class GrupoService {
  constructor(repos, auditoria) {
    this.repos = repos;
    this.auditoria = auditoria;
  }

  // Passos 1-4: criar grupo. Apenas Cuidador Principal (pre-condicao).
  async criarGrupo(usuario, { nome, nomeIdoso }) {
    if (usuario.perfil !== PerfilUsuario.CUIDADOR_PRINCIPAL) {
      throw new ForbiddenError('Apenas o Cuidador Principal pode criar grupos (RN002)');
    }
    const nomeOk = exigirTexto(nome, 'nome', 80);
    const idosoOk = exigirTexto(nomeIdoso, 'nomeIdoso', 100);

    const grupo = new Grupo({
      id: novoId('grp'),
      nome: nomeOk,
      nomeIdoso: idosoOk,
      cuidadorPrincipalId: usuario.id,
      membros: [{ usuarioId: usuario.id, perfil: PerfilUsuario.CUIDADOR_PRINCIPAL, ingressoEm: new Date() }],
      convites: [],
    });
    await this.repos.grupos.criar(grupo);

    await this.auditoria.registrar({
      grupoId: grupo.id,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.GRUPO_CRIADO,
      detalhes: { nome: grupo.nome },
    });
    return grupo;
  }

  // RN001: usuario pode pertencer a varios grupos.
  async listarGruposDoUsuario(usuario) {
    return this.repos.grupos.buscarPorMembro(usuario.id);
  }

  async obterGrupo(usuario, grupoId) {
    const grupo = await this._exigirGrupo(grupoId);
    if (!grupo.ehMembro(usuario.id)) {
      await this.auditoria.registrar({
        grupoId,
        usuarioId: usuario.id,
        acao: AcaoAuditoria.ACESSO_NEGADO,
        detalhes: { recurso: 'grupo' },
      });
      throw new ForbiddenError('Usuario nao pertence ao grupo (RN003)');
    }
    return grupo;
  }

  // Passos 5-6: convidar membro por e-mail ou link. Exclusivo do Cuidador Principal (RN002).
  async convidarMembro(usuario, grupoId, { email, perfil = PerfilUsuario.CUIDADOR_AUXILIAR }) {
    const grupo = await this._exigirGrupoGerenciavel(usuario, grupoId);
    exigirEnum(perfil, PerfilUsuario, 'perfil');
    let emailOk = null;
    if (email) emailOk = exigirEmail(email, 'email');

    const expiraEm = new Date(Date.now() + DIAS_VALIDADE_CONVITE * 24 * 60 * 60 * 1000);
    const convite = {
      token: novoToken(),
      email: emailOk,
      perfil,
      status: StatusConvite.PENDENTE,
      criadoEm: new Date(),
      expiraEm,
    };
    grupo.convites.push(convite);
    await this.repos.grupos.salvar(grupo);

    await this.auditoria.registrar({
      grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.CONVITE_ENVIADO,
      detalhes: { email: emailOk, perfil },
    });

    const link = `${env.appBaseUrl}/convite/${convite.token}`;
    return { link, token: convite.token, email: emailOk, perfil, expiraEm };
  }

  // Passo 7: aceitar convite e ingressar no grupo com o perfil definido.
  async aceitarConvite(usuario, token) {
    const grupo = await this.repos.grupos.buscarPorTokenConvite(token);
    if (!grupo) throw new NotFoundError('Convite nao encontrado');

    const convite = grupo.conviteValido(token);
    if (!convite) throw new ConflictError('Convite expirado ou revogado. Solicite um novo convite');

    if (grupo.ehMembro(usuario.id)) {
      throw new ConflictError('Usuario ja e membro do grupo');
    }

    grupo.membros.push({ usuarioId: usuario.id, perfil: convite.perfil, ingressoEm: new Date() });
    convite.status = StatusConvite.ACEITO;
    await this.repos.grupos.salvar(grupo);

    await this.auditoria.registrar({
      grupoId: grupo.id,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.MEMBRO_INGRESSOU,
      detalhes: { perfil: convite.perfil },
    });
    return grupo;
  }

  // FA01: remover membro. Mantem historico (RN008). Exclusivo do Cuidador Principal (RN002).
  async removerMembro(usuario, grupoId, usuarioRemovidoId) {
    const grupo = await this._exigirGrupoGerenciavel(usuario, grupoId);
    if (usuarioRemovidoId === grupo.cuidadorPrincipalId) {
      throw new ValidationError('O Cuidador Principal nao pode ser removido do grupo');
    }
    const antes = grupo.membros.length;
    grupo.membros = grupo.membros.filter((m) => m.usuarioId !== usuarioRemovidoId);
    if (grupo.membros.length === antes) throw new NotFoundError('Membro nao encontrado no grupo');

    await this.repos.grupos.salvar(grupo);
    await this.auditoria.registrar({
      grupoId,
      usuarioId: usuario.id,
      acao: AcaoAuditoria.MEMBRO_REMOVIDO,
      detalhes: { membroRemovido: usuarioRemovidoId },
    });
    return grupo;
  }

  async _exigirGrupo(grupoId) {
    const grupo = await this.repos.grupos.buscarPorId(grupoId);
    if (!grupo) throw new NotFoundError('Grupo nao encontrado');
    return grupo;
  }

  // FE02: bloqueia gestao por perfil nao autorizado e registra a tentativa (RN002/RN010).
  async _exigirGrupoGerenciavel(usuario, grupoId) {
    const grupo = await this._exigirGrupo(grupoId);
    if (!grupo.ehCuidadorPrincipal(usuario.id)) {
      await this.auditoria.registrar({
        grupoId,
        usuarioId: usuario.id,
        acao: AcaoAuditoria.ACESSO_NEGADO,
        detalhes: { operacao: 'gestao_membros' },
      });
      throw new ForbiddenError('Operacao exclusiva do Cuidador Principal (RN002)');
    }
    return grupo;
  }
}

module.exports = GrupoService;
