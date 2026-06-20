'use strict';

// Interface de persistencia de Alertas agendados (UC006).
class IAlertaRepository {
  async criar(alerta) { throw new Error('nao implementado'); }
  async listarPorRotina(rotinaId) { throw new Error('nao implementado'); }
  async cancelarPorRotina(rotinaId) { throw new Error('nao implementado'); }
  async listarVencidos(agora) { throw new Error('nao implementado'); }
  async salvar(alerta) { throw new Error('nao implementado'); }
}

module.exports = IAlertaRepository;
