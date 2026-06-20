'use strict';

const env = require('./config/env');
const { createApp } = require('./app');
const { iniciarAgendadorEmProcesso } = require('./jobs/dispatchAlertas');

const app = createApp();

// Agendador de alertas em processo (opcional; em producao prefira Cloud Scheduler).
if (process.env.ALERTAS_EM_PROCESSO === 'true') {
  iniciarAgendadorEmProcesso(Number(process.env.ALERTAS_INTERVALO_MS || 60000));
}

const server = app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`CuidaBem backend ouvindo na porta ${env.port} (backend de dados: ${env.dataBackend})`);
});

process.on('SIGTERM', () => server.close(() => process.exit(0)));
process.on('SIGINT', () => server.close(() => process.exit(0)));

module.exports = server;
