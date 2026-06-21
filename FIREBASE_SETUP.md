# Tirar o CuidaBem do modo demonstração — runbook

Passo a passo com os comandos exatos para conectar o app e o back-end a um
projeto Firebase real. O que precisa ser feito na sua conta Google está marcado
com **[você]**; o resto é copiar e colar.

Ao longo do guia, substitua `SEU-PROJECT-ID` pelo id do seu projeto.

---

## 0. Pré-requisitos (uma vez)

```bash
# Node 18+ e Flutter já instalados. Agora as CLIs:
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login          # [você] abre o navegador e autentica
```

---

## 1. Criar o projeto e habilitar os serviços  [você]

1. Acesse https://console.firebase.google.com e clique em **Adicionar projeto**.
2. Dê um nome (ex.: `cuidabem`), conclua a criação e copie o **Project ID**.
3. No menu lateral, habilite:
   - **Build > Authentication** → aba *Sign-in method* → ative **E-mail/senha**.
   - **Build > Firestore Database** → *Criar banco* → modo de **produção** → região `southamerica-east1`.
   - **Build > Storage** → *Começar* → modo de produção.
   - **Engage > Messaging** (Cloud Messaging) já vem habilitado.

---

## 2. Conectar o aplicativo Flutter

Na pasta `app`, gere o `firebase_options.dart` real (substitui o stub):

```bash
cd app
flutterfire configure --project=SEU-PROJECT-ID
```

Selecione as plataformas (Android, iOS e/ou Web). Isso cria/atualiza
`lib/firebase_options.dart` e os arquivos de plataforma. Depois:

```bash
flutter pub get
```

---

## 3. Publicar regras e índices do Firestore/Storage

Edite `firebase/.firebaserc` trocando `SUBSTITUIR-PELO-ID-DO-PROJETO` pelo seu id e:

```bash
cd ../firebase
firebase use SEU-PROJECT-ID
firebase deploy --only firestore:rules,firestore:indexes,storage
```

---

## 4. Configurar o back-end

### 4.1. Gerar a chave de serviço  [você]

Console Firebase → **engrenagem (Configurações do projeto) > Contas de serviço**
→ **Gerar nova chave privada**. Guarde o JSON com segurança (NÃO comite).

### 4.2. Criar o `.env` do back-end

Na pasta `backend`, copie o exemplo e preencha:

```bash
cd ../backend
cp .env.example .env
```

Edite o `.env` com:

```
NODE_ENV=production
PORT=3000
DATA_BACKEND=firebase
APP_BASE_URL=https://SEU-DOMINIO

FIREBASE_PROJECT_ID=SEU-PROJECT-ID
FIREBASE_CLIENT_EMAIL=<client_email do JSON>
FIREBASE_PRIVATE_KEY="<private_key do JSON, com os \n>"
FIREBASE_STORAGE_BUCKET=SEU-PROJECT-ID.appspot.com

JOB_SECRET=<gere um segredo forte>
ALERTAS_EM_PROCESSO=false
```

> Alternativa às 3 variáveis `FIREBASE_*`: aponte `GOOGLE_APPLICATION_CREDENTIALS`
> para o caminho do JSON da conta de serviço.

### 4.3. Testar localmente contra o Firebase real

```bash
npm install
npm start
# Em outro terminal:
curl http://localhost:3000/health   # deve responder "backend":"firebase"
```

---

## 5. Deploy do back-end (Google Cloud Run)

O `backend/Dockerfile` já está pronto. Com a CLI do gcloud autenticada:

```bash
cd backend
gcloud run deploy cuidabem-api \
  --source . \
  --region southamerica-east1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production,DATA_BACKEND=firebase,FIREBASE_PROJECT_ID=SEU-PROJECT-ID,FIREBASE_STORAGE_BUCKET=SEU-PROJECT-ID.appspot.com
```

Defina `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` e `JOB_SECRET` como
*secrets* (não como env em texto). Anote a URL pública gerada (ex.:
`https://cuidabem-api-xxxx.run.app`) — é o seu `API_BASE_URL` + `/api/v1`.

> Render, Railway e Fly.io também funcionam com o mesmo `Dockerfile`.
> Exigência: a API deve ficar somente sob **HTTPS/TLS** (RNF003).

---

## 6. Agendar o disparo de alertas (UC006)

Cloud Scheduler chamando o endpoint protegido a cada minuto:

```bash
gcloud scheduler jobs create http cuidabem-alertas \
  --schedule "* * * * *" \
  --uri "https://SEU-DOMINIO/api/v1/jobs/alertas/disparar" \
  --http-method POST \
  --headers "X-Job-Secret=<o mesmo JOB_SECRET>" \
  --location southamerica-east1
```

---

## 7. Compilar o app apontando para a produção

O modo demonstração é desligado por padrão (`DEMO=false`), então basta **não**
passar `--dart-define=DEMO=true` e informar a URL da API:

```bash
cd app
flutter build apk --release --dart-define=API_BASE_URL=https://SEU-DOMINIO/api/v1
# ou Web:
flutter build web --dart-define=API_BASE_URL=https://SEU-DOMINIO/api/v1
```

O `.apk` fica em `build/app/outputs/flutter-apk/app-release.apk`.

Para rodar em desenvolvimento contra a produção (sem build):

```bash
flutter run --dart-define=API_BASE_URL=https://SEU-DOMINIO/api/v1
```

---

## 8. Checklist final

- [ ] Projeto Firebase criado; Auth (E-mail/senha), Firestore, Storage e FCM habilitados
- [ ] `flutter pub get` rodado e `lib/firebase_options.dart` gerado pelo `flutterfire configure`
- [ ] Regras e índices publicados (`firebase deploy`)
- [ ] Chave de serviço gerada e `.env` do back-end preenchido
- [ ] `/health` respondendo `"backend":"firebase"`
- [ ] Back-end no ar sob HTTPS (Cloud Run/Render/…)
- [ ] Cloud Scheduler disparando alertas (ou `ALERTAS_EM_PROCESSO=true`)
- [ ] App compilado com `API_BASE_URL` de produção e sem `DEMO=true`
- [ ] Login real funciona (cria conta, recebe permissão de notificação)

---

## O que o código já entrega para produção

- App inicializa o Firebase e registra o handler de mensagens em segundo plano.
- No login real, pede permissão de notificação e registra o token FCM no back-end
  (`POST /api/v1/usuarios/me/fcm-token`), renovando-o automaticamente.
- Back-end troca de memória para Firestore/Auth/FCM apenas com `DATA_BACKEND=firebase`,
  sem mudar código (interfaces de repositório e de notificação).
- PDFs de relatório vão para o Firebase Storage com URL assinada.
- Regras de segurança negam acesso direto de clientes; tudo passa pelo back-end.
