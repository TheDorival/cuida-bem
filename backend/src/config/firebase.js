'use strict';

const env = require('./env');

let app = null;
let firestore = null;
let messaging = null;

// Inicializa o Firebase Admin sob demanda (apenas quando DATA_BACKEND=firebase).
// Mantem o backend de memoria livre de dependencia de credenciais.
function initFirebase() {
  if (app) return app;

  // eslint-disable-next-line global-require
  const admin = require('firebase-admin');

  let credential;
  if (env.firebase.projectId && env.firebase.clientEmail && env.firebase.privateKey) {
    credential = admin.credential.cert({
      projectId: env.firebase.projectId,
      clientEmail: env.firebase.clientEmail,
      privateKey: env.firebase.privateKey,
    });
  } else {
    // Usa GOOGLE_APPLICATION_CREDENTIALS (arquivo de service account).
    credential = admin.credential.applicationDefault();
  }

  app = admin.initializeApp({
    credential,
    storageBucket: env.firebase.storageBucket || undefined,
  });
  firestore = admin.firestore();
  messaging = admin.messaging();
  return app;
}

function getFirestore() {
  if (!firestore) initFirebase();
  return firestore;
}

function getMessaging() {
  if (!messaging) initFirebase();
  return messaging;
}

module.exports = { initFirebase, getFirestore, getMessaging };
