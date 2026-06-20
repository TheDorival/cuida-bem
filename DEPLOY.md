# Guia de Implantação — CuidaBem 1.0

Passo a passo para colocar o CuidaBem em produção: instalação do Flutter, criação
da infraestrutura Firebase, deploy do back-end e build do aplicativo.

## 1. Instalar o Flutter (sua máquina — Windows)

No PowerShell:

```powershell
winget install --id=Google.Flutter -e
```

Se o `winget` não tiver o pacote, baixe o SDK em https://docs.flutter.dev/get-started/install/windows
e adicione a pasta `flutter\bin` ao PATH. Depois confirme o ambiente:

```powershell
flutter doctor
```

Resolva o que o `flutter doctor` apontar (Android Studio + Android SDK para rodar no
emulador/aparelho). Para build Android você também precisa aceitar as licenças:

```powershell
flutter doctor --android-licenses
```

## 2. Gerar as pastas de plataforma do app

O diretório `app/` já contém `pubspec.yaml` e `lib/`, mas ainda não tem as pastas de
plataforma (android/ios/web). Gere-as sem sobrescrever o código:

```powershell
cd app
flutter create .
flutter pub get
```

> iOS exige macOS com Xcode; no Windows você trabalha com Android e/ou Web.

## 3. Criar o projeto Firebase

1. Acesse https://console.firebase.google.com e crie um projeto.
2. Habilite: **Authentication** (E-mail/Senha), **Firestore** (produção),
   **Storage** e **Cloud Messaging**.
3. Instale a CLI e o FlutterFire:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

4. Conecte o app ao projeto (gera o `lib/firebase_options.dart` real, substituindo o stub):

```powershell
cd app
flutterfire configure
```

5. Publique as regras e índices (ajuste o id em `firebase/.firebaserc`):

```powershell
cd ../firebase
firebase use SEU-PROJECT-ID
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 4. Configurar e implantar o back-end

### 4.1. Credenciais

No console Firebase: **Configurações do projeto > Contas de serviço > Gerar nova
chave privada**. Guarde o JSON com segurança (não comite).

### 4.2. Variáveis de ambiente (produção)

```
NODE_ENV=production
DATA_BACKEND=firebase
PORT=3000
APP_BASE_URL=https://SEU-DOMINIO
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=SEU-PROJECT-ID.appspot.com
JOB_SECRET=um-segredo-forte
```

> Alternativa às três variáveis `FIREBASE_*`: monte o JSON da conta de serviço e
> aponte `GOOGLE_APPLICATION_CREDENTIALS` para ele.

### 4.3. Deploy (Cloud Run, via Docker)

O `backend/Dockerfile` já está pronto. Exemplo com Google Cloud Run:

```bash
cd backend
gcloud run deploy cuida-bem-api \
  --source . \
  --region southamerica-east1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production,DATA_BACKEND=firebase,FIREBASE_PROJECT_ID=...,FIREBASE_STORAGE_BUCKET=...,JOB_SECRET=...
```

Defina `FIREBASE_CLIENT_EMAIL` e `FIREBASE_PRIVATE_KEY` como *secrets*. Serviços como
Render, Railway ou Fly.io também funcionam usando o mesmo Dockerfile. A API deve ficar
exclusivamente sob **HTTPS/TLS** (RNF003).

### 4.4. Agendar o disparo de alertas (UC006)

Crie um Cloud Scheduler chamando o endpoint protegido a cada minuto:

```bash
gcloud scheduler jobs create http disparo-alertas \
  --schedule "* * * * *" \
  --uri "https://SEU-DOMINIO/api/v1/jobs/alertas/disparar" \
  --http-method POST \
  --headers "X-Job-Secret=um-segredo-forte" \
  --location southamerica-east1
```

> Alternativa simples: defina `ALERTAS_EM_PROCESSO=true` para o próprio servidor rodar
> o agendador interno (adequado a um único processo).

## 5. Apontar o app para a API de produção

Compile o app com a URL da API:

```powershell
cd app
flutter build apk --release --dart-define=API_BASE_URL=https://SEU-DOMINIO/api/v1
# ou Web:
flutter build web --dart-define=API_BASE_URL=https://SEU-DOMINIO/api/v1
```

O `.apk` fica em `build/app/outputs/flutter-apk/`.

## 6. Checklist final

- [ ] `flutter doctor` sem pendências bloqueantes
- [ ] `firebase_options.dart` gerado pelo `flutterfire configure`
- [ ] Regras e índices publicados no Firebase
- [ ] Back-end no ar sob HTTPS com `DATA_BACKEND=firebase`
- [ ] Cloud Scheduler (ou `ALERTAS_EM_PROCESSO`) disparando alertas
- [ ] App compilado apontando para a API de produção
