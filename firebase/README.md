# Firebase - CuidaBem

Configuracao de infraestrutura para o ambiente de producao.

## Pre-requisitos

- Conta Google e um projeto criado no console Firebase (https://console.firebase.google.com).
- Firebase CLI: `npm install -g firebase-tools` e `firebase login`.

## Servicos a habilitar no console

1. **Authentication** -> metodo E-mail/Senha.
2. **Firestore Database** -> modo de producao.
3. **Storage** -> bucket padrao.
4. **Cloud Messaging** (FCM) -> ja habilitado por padrao.

## Deploy das regras e indices

A partir desta pasta (ajuste o id do projeto em `.firebaserc`):

```bash
cd firebase
firebase use SUBSTITUIR-PELO-ID-DO-PROJETO
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Observacao de seguranca

O acesso direto de clientes ao Firestore e ao Storage e negado: todo o acesso aos
dados passa pelo back-end (Admin SDK), que valida a identidade (verifyIdToken) e as
regras de negocio (RN001..RN010) antes de qualquer operacao.
