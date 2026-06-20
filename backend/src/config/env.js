'use strict';

require('dotenv').config();

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 3000),
  // 'memory' (dev/testes) ou 'firebase' (producao)
  dataBackend: (process.env.DATA_BACKEND || 'memory').toLowerCase(),
  appBaseUrl: process.env.APP_BASE_URL || 'http://localhost:3000',
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
    credentialsPath: process.env.GOOGLE_APPLICATION_CREDENTIALS || '',
  },
};

env.isProduction = env.nodeEnv === 'production';
env.useFirebase = env.dataBackend === 'firebase';

module.exports = env;
