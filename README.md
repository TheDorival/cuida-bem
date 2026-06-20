# CuidaBem 1.0

Sistema de apoio ao cuidado de idosos desenvolvido na disciplina de Engenharia de
Software (Bacharelado em Sistemas de Informacao - IFAL). Implementa os casos de uso
da Especificacao do Projeto (AV2) com arquitetura MVC em duas camadas.

## Estrutura

- `backend/` - API REST em Node.js + Express. Persistencia abstraida por interfaces,
  com implementacoes em memoria (dev/testes) e Firebase Firestore (producao).
  Inclui Firebase Auth (identidade) e FCM (notificacoes push). Ver `backend/README.md`.
- `app/` - Aplicativo mobile em Flutter (Dart), padrao MVC do cliente (View +
  Controller via providers), consumindo a API do back-end.

## Casos de uso

| UC    | Nome                              | Responsavel |
|-------|-----------------------------------|-------------|
| UC002 | Gestao de Grupo de Cuidado        | Leonardo    |
| UC003 | Gestao de Rotinas de Cuidado      | Robert      |
| UC004 | Diario de Saude do Idoso          | Iago        |
| UC007 | Geracao de Relatorio de Evolucao  | Ledayara    |

## Tecnologias

Flutter (Dart) no cliente; Node.js + Express no servidor; Firebase (Firestore, Auth,
FCM) como infraestrutura. Comunicacao via HTTPS/TLS (RNF003). Aderencia a SOLID com
inversao de dependencia (RNF008): a infraestrutura pode ser substituida sem impacto
nos controllers.

## Executando

```bash
# back-end
cd backend && cp .env.example .env && npm install && npm start

# app (requer Flutter SDK)
cd app && flutter pub get && flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```
