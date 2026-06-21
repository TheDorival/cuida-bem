'use strict';

require('dotenv').config();

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 3000),
  // 'memory' (dev/testes) ou 'firebase' (producao)
  dataBackend: (process.env.DATA_BACKEND || 'memory').toLowerCase(),
  // Armazenamento de PDFs independente do backend de dados: 'local' ou 'firebase'.
  // Permite usar Firestore/Auth/FCM (gratuitos) sem o Storage (que exige Blaze).
  storageBackend: (process.env.STORAGE_BACKEND || process.env.DATA_BACKEND || 'memory').toLowerCase(),
  appBaseUrl: process.env.APP_BASE_URL || 'http://localhost:3000',
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
    credentialsPath: process.env.GOOGLE_APPLICATION_CREDENTIALS || '',
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || '',
  },
};

env.isProduction = env.nodeEnv === 'production';
env.useFirebase = env.dataBackend === 'firebase';
env.useFirebaseStorage = env.storageBackend === 'firebase';

module.exports = env;
