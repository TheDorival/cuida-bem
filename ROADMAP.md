# CuidaBem — Plano de continuidade (deploy + implementações futuras)

Documento para retomarmos o projeto de onde paramos. Resume o estado atual, os
passos que faltam para o deploy e o backlog de implementações futuras, priorizado.

Última atualização: junho/2026.

---

## 1. Onde estamos (estado atual)

**Back-end (Node.js + Express, MVC)** — completo e testado (14 testes passando).
Casos de uso UC002 (grupos), UC003 (rotinas) + UC006 (alertas), UC004 (diário) e
UC007 (relatórios), além de UC001 (auth) e auditoria (RN010). Persistência e
notificação abstraídas por interfaces (memória/Firestore, console/FCM, local/Storage).

**App (Flutter, MVC)** — completo, com identidade visual e telas redesenhadas:
carrossel de apresentação no login, dashboard com resumo, gestão de membros e
convites, rotinas (criar/editar/concluir/desativar), diário com filtros, relatórios
com abertura de PDF, modo demonstração e resiliência offline de leitura. Login com
validação de formulário e mensagens de erro específicas.

**Firebase** — projeto `cuida-bem-5dcab` criado; app conectado via `firebase_options.dart`;
back-end rodando localmente contra Firestore/Auth (`/health` → `"backend":"firebase"`).
Credenciais (`serviceAccountKey.json` + `.env`) configuradas localmente (fora do Git).

**Pendências conhecidas** — itens deixados de propósito para depois (ver seção 3):
sincronização offline de escrita, deep link de convite, FCM na web, testes de widget.

---

## 2. Concluir o deploy (passos restantes)

Referência detalhada de comandos: `FIREBASE_SETUP.md`. Resumo do que falta, em ordem:

### 2.1. Publicar regras e índices do Firestore  [pendente]
```
cd firebase
firebase use cuida-bem-5dcab
firebase deploy --only firestore:rules,firestore:indexes
```
Necessário para o diário (filtro por período) e relatórios (índices compostos).

### 2.2. Validar o app contra o back-end local  [em andamento]
- Rodar back-end (`npm start`) + app (`flutter run -d web-server --dart-define=API_BASE_URL=http://localhost:3000/api/v1`).
- Criar conta → criar grupo → conferir a coleção `grupos` no Firestore.
- Testar rotina, diário e geração de relatório.

### 2.3. Deploy do back-end (Cloud Run)  [pendente]
- `gcloud run deploy cuidabem-api --source . --region southamerica-east1 --allow-unauthenticated`
- Definir como **secrets**: `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` (ou subir o
  `serviceAccountKey.json` via Secret Manager e apontar `GOOGLE_APPLICATION_CREDENTIALS`),
  `JOB_SECRET`.
- Variáveis: `NODE_ENV=production`, `DATA_BACKEND=firebase`, `STORAGE_BACKEND=local`,
  `FIREBASE_PROJECT_ID=cuida-bem-5dcab`, `APP_BASE_URL=<url do Cloud Run>`.
- Anotar a URL pública → vira o `API_BASE_URL` (+ `/api/v1`).
- Alternativas equivalentes: Render, Railway, Fly.io (mesmo `Dockerfile`).

### 2.4. Agendar o disparo de alertas (UC006)  [pendente]
- Cloud Scheduler chamando `POST /api/v1/jobs/alertas/disparar` a cada minuto,
  com header `X-Job-Secret`. (Ou `ALERTAS_EM_PROCESSO=true` para um único processo.)

### 2.5. Publicar o app  [pendente]
- **Web:** `flutter build web --dart-define=API_BASE_URL=<API>/api/v1` e `firebase deploy --only hosting`
  (configurar Firebase Hosting) ou outro host estático.
- **Android:** `flutter build apk --release --dart-define=API_BASE_URL=<API>/api/v1`.
- Garantir que **não** passa `--dart-define=DEMO=true`.

### 2.6. Publicar o código  [pendente]
- `git push --force origin main` (o histórico foi reescrito para português).

---

## 3. Implementações futuras (backlog priorizado)

### Prioridade alta (fecham lacunas da especificação)
- **Sincronização offline de escrita (FE02 dos UC003/UC004):** fila local de operações
  (sqflite/drift) que envia ao back-end ao reconectar; indicador "pendente de sincronização".
- **FCM na web:** chave VAPID + service worker (`firebase-messaging-sw.js`) para o push
  funcionar no navegador (hoje funciona no Android; na web precisa desse passo).
- **Recuperação de senha:** fluxo "Esqueci minha senha" (Firebase `sendPasswordResetEmail`).

### Prioridade média (experiência e completude)
- **Deep link de convite:** abrir o app direto pelo link (`app_links`/`uni_links`) e
  pré-preencher o código (hoje há entrada manual do código).
- **Tela de perfil/conta:** editar nome, trocar senha, sair de um grupo, excluir conta.
- **Gestão de membros avançada:** alterar perfil de um membro, reenviar/revogar convite,
  ver convites pendentes.
- **Visualização do relatório no app:** pré-visualizar o PDF embutido, além de abrir/compartilhar.
- **Modo escuro:** o tema já é Material 3; adicionar `darkTheme` e alternância.

### Prioridade baixa (qualidade e operação)
- **Testes de widget e integração no Flutter** (hoje só há teste do `FakeApiClient`).
- **CI/CD (GitHub Actions):** rodar `npm test` do back-end e `flutter analyze`/`flutter test` a cada push.
- **Observabilidade:** logs estruturados no back-end, métricas e healthcheck no Cloud Run.
- **Rate limiting e hardening** no back-end (ex.: `express-rate-limit`).
- **Paginação** no diário e nos logs de auditoria para grupos com muitos registros.

---

## 4. Segurança e conformidade (antes de uso real)

- Dados de idosos são **sensíveis** — revisar privacidade/LGPD (consentimento, retenção,
  exclusão de conta e dados).
- Manter as regras do Firestore/Storage negando acesso direto de clientes (já configurado);
  todo acesso passa pelo back-end com `verifyIdToken`.
- Rotacionar o `serviceAccountKey.json` se houver qualquer exposição; nunca comitar segredos.
- Validar entradas no back-end (já há validações por caso de uso) e revisar limites.

---

## 5. Como retomar o ambiente local (rápido)

```bash
# back-end
cd backend
npm install
npm start            # precisa de .env + serviceAccountKey.json (locais)

# app (em outro terminal)
cd app
flutter pub get
flutter run -d web-server --dart-define=API_BASE_URL=http://localhost:3000/api/v1
# abrir a URL impressa no navegador
```

Modo demonstração (sem Firebase/back-end): `flutter run -d web-server --dart-define=DEMO=true`.

---

## 6. Rastreabilidade com a especificação (AV2)

| Caso de uso | Back-end | App | Observação |
|---|---|---|---|
| UC001 Autenticação | ok | ok | Firebase Auth + validação de formulário |
| UC002 Grupo de cuidado | ok | ok | criar, convidar, aceitar, remover membro |
| UC003 Rotinas | ok | ok | criar/editar/concluir/desativar |
| UC004 Diário | ok | ok | filtros por categoria e período |
| UC006 Alertas | ok | parcial | back-end dispara; falta scheduler em produção e FCM web |
| UC007 Relatórios | ok | ok | PDF (local ou Storage), abrir/compartilhar |
| Offline (FE02) | n/a | parcial | leitura resiliente; falta fila de escrita |
