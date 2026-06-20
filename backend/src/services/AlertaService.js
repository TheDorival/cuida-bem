'use strict';

const Alerta = require('../models/Alerta');
const { novoId } = require('../utils/id');
const { calcularProximoDisparo } = require('../utils/agendamento');

// Servico de alertas (UC006). Agenda e dispara notificacoes push das rotinas.
class AlertaService {
  constructor(repos, notificacao) {
    this.repos = repos;
    this.notificacao = notificacao;
  }

  // Passo 7 do UC003: agenda alertas conforme horario e frequencia (RN005).
  async agendarParaRotina(rotina) {
    await this.repos.alertas.cancelarPorRotina(rotina.id);
    const proximo = calcularProximoDisparo(rotina);
    if (!proximo) return null;

    const alerta = new Alerta({
      id: novoId('alr'),
      rotinaId: rotina.id,
      grupoId: rotina.grupoId,
      horario: rotina.horario,
      frequencia: rotina.frequencia,
      proximoDisparo: proximo.toISOString(),
      ativo: true,
    });
    await this.repos.alertas.criar(alerta);
    return alerta;
  }

  async cancelarParaRotina(rotinaId) {
    await this.repos.alertas.cancelarPorRotina(rotinaId);
  }

  // Job: dispara todos os alertas vencidos e reagenda (executado por cron/Cloud Scheduler).
  async dispararPendentes(agora = new Date()) {
    const vencidos = await this.repos.alertas.listarVencidos(agora);
    let total = 0;
    for (const alerta of vencidos) {
      const r = await this.dispararAlerta(alerta);
      total += r.enviados || 0;
    }
    return { alertas: vencidos.length, notificacoesEnviadas: total };
  }

  // Coleta os tokens FCM dos membros do grupo e dispara a notificacao.
  async dispararAlerta(alerta) {
    const grupo = await this.repos.grupos.buscarPorId(alerta.grupoId);
    const rotina = await this.repos.rotinas.buscarPorId(alerta.rotinaId);
    if (!grupo || !rotina) return { enviados: 0 };

    const tokens = [];
    for (const m of grupo.membros) {
      const u = await this.repos.usuarios.buscarPorId(m.usuarioId);
      if (u && u.fcmTokens) tokens.push(...u.fcmTokens);
    }

    const resultado = await this.notificacao.enviar(tokens, {
      titulo: `Lembrete: ${rotina.descricao}`,
      corpo: `${rotina.tipo} as ${rotina.horario}`,
      dados: { rotinaId: rotina.id, grupoId: grupo.id, tipo: 'ROTINA' },
    });

    // Reagenda o proximo disparo (exceto rotina unica).
    const proximo = calcularProximoDisparo(rotina, new Date(Date.now() + 60000));
    if (proximo) {
      alerta.proximoDisparo = proximo.toISOString();
      await this.repos.alertas.salvar(alerta);
    } else {
      alerta.ativo = false;
      await this.repos.alertas.salvar(alerta);
    }
    return resultado;
  }
}

module.exports = AlertaService;
