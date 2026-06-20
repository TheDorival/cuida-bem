'use strict';

const env = require('./config/env');
const { createApp } = require('./app');

const app = createApp();

const server = app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`CuidaBem backend ouvindo na porta ${env.port} (backend de dados: ${env.dataBackend})`);
});

process.on('SIGTERM', () => server.close(() => process.exit(0)));
process.on('SIGINT', () => server.close(() => process.exit(0)));

module.exports = server;
