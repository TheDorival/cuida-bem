'use strict';

// Job de disparo de alertas (UC006). Pode ser executado:
//  - como script unico (cron / Cloud Scheduler -> Cloud Run job): `node src/jobs/dispatchAlertas.js`
//  - periodicamente em processo (ver iniciarAgendadorEmProcesso).
const { getContainer } = require('../container');

async function dispararAlertasVencidos() {
  const { alertaService } = getContainer();
  const resultado = await alertaService.dispararPendentes(new Date());
  return resultado;
}

// Agendador em processo (alternativa simples ao cron externo).
function iniciarAgendadorEmProcesso(intervaloMs = 60000) {
  return setInterval(() => {
    dispararAlertasVencidos().catch((e) => {
      // eslint-disable-next-line no-console
      console.error('[job alertas] falha:', e.message);
    });
  }, intervaloMs);
}

module.exports = { dispararAlertasVencidos, iniciarAgendadorEmProcesso };

// Execucao direta como script.
if (require.main === module) {
  dispararAlertasVencidos()
    .then((r) => {
      // eslint-disable-next-line no-console
      console.log('[job alertas]', r);
      process.exit(0);
    })
    .catch((e) => {
      // eslint-disable-next-line no-console
      console.error('[job alertas] erro:', e);
      process.exit(1);
    });
}
