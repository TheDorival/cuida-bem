'use strict';

// Enumeracoes do dominio CuidaBem, alinhadas a ERS v1.0 e a Especificacao AV2.

const PerfilUsuario = Object.freeze({
  CUIDADOR_PRINCIPAL: 'CUIDADOR_PRINCIPAL',
  CUIDADOR_AUXILIAR: 'CUIDADOR_AUXILIAR',
  FAMILIAR: 'FAMILIAR',
  PROFISSIONAL_SAUDE: 'PROFISSIONAL_SAUDE',
});

const TipoRotina = Object.freeze({
  MEDICACAO: 'MEDICACAO',
  ALIMENTACAO: 'ALIMENTACAO',
  HIGIENE: 'HIGIENE',
  OUTRO: 'OUTRO',
});

const FrequenciaRotina = Object.freeze({
  DIARIA: 'DIARIA',
  SEMANAL: 'SEMANAL',
  MENSAL: 'MENSAL',
  UNICA: 'UNICA',
});

const StatusRotina = Object.freeze({
  PENDENTE: 'PENDENTE',
  CONCLUIDA: 'CONCLUIDA',
  DESATIVADA: 'DESATIVADA',
});

const CategoriaDiario = Object.freeze({
  SAUDE: 'SAUDE',
  MEDICACAO: 'MEDICACAO',
  ALIMENTACAO: 'ALIMENTACAO',
  HUMOR: 'HUMOR',
  OCORRENCIA: 'OCORRENCIA',
  OUTRO: 'OUTRO',
});

const StatusConvite = Object.freeze({
  PENDENTE: 'PENDENTE',
  ACEITO: 'ACEITO',
  EXPIRADO: 'EXPIRADO',
  REVOGADO: 'REVOGADO',
});

const AcaoAuditoria = Object.freeze({
  GRUPO_CRIADO: 'GRUPO_CRIADO',
  CONVITE_ENVIADO: 'CONVITE_ENVIADO',
  MEMBRO_INGRESSOU: 'MEMBRO_INGRESSOU',
  MEMBRO_REMOVIDO: 'MEMBRO_REMOVIDO',
  ROTINA_CRIADA: 'ROTINA_CRIADA',
  ROTINA_EDITADA: 'ROTINA_EDITADA',
  ROTINA_CONCLUIDA: 'ROTINA_CONCLUIDA',
  ROTINA_DESATIVADA: 'ROTINA_DESATIVADA',
  DIARIO_REGISTRADO: 'DIARIO_REGISTRADO',
  RELATORIO_GERADO: 'RELATORIO_GERADO',
  ACESSO_NEGADO: 'ACESSO_NEGADO',
});

function valores(enumObj) {
  return Object.values(enumObj);
}

module.exports = {
  PerfilUsuario,
  TipoRotina,
  FrequenciaRotina,
  StatusRotina,
  CategoriaDiario,
  StatusConvite,
  AcaoAuditoria,
  valores,
};
