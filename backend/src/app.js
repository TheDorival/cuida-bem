'use strict';

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const env = require('./config/env');
const routes = require('./routes');
const { notFoundHandler, errorHandler } = require('./middlewares/errorHandler');

// Monta a aplicacao Express (Controller do servidor no MVC).
function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: '1mb' }));
  if (!env.isProduction) {
    app.use(morgan('dev'));
  }

  app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'cuida-bem-backend', backend: env.dataBackend });
  });

  app.use('/api/v1', routes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
