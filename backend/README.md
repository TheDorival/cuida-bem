# CuidaBem 1.0 - Back-end

API REST do CuidaBem 1.0, sistema de apoio ao cuidado de idosos desenvolvido na
disciplina de Engenharia de Software (Bacharelado em Sistemas de Informacao - IFAL).
Implementa os casos de uso da Especificacao do Projeto (AV2) sobre arquitetura MVC.

## Arquitetura

Padrao MVC com inversao de dependencia (SOLID / RNF008):

- **Model**: entidades de dominio em `src/models` (Usuario, Grupo, Rotina, EntradaDiario,
  Alerta, Relatorio, LogAuditoria), persistidas via repositorios.
- **Controller**: controllers Express em `src/controllers` orquestram os servicos de negocio.
- **Services**: regras de negocio de cada caso de uso em `src/services`.
- **Repositories**: persistencia abstraida por interfaces (`src/repositories/interfaces`),
  com implementacoes em memoria (`memory`) e Firestore (`firestore`). A troca de
  infraestrutura nao impacta controllers nem servicos.

Servicos transversais: autenticacao (`middlewares/auth`), auditoria (RN010) e
notificacoes push (`services/notificacao`, interface `INotificacaoService` com
implementacoes FCM e console).

## Casos de uso implementados

| UC    | Recurso                              | Endpoints base                         |
|-------|--------------------------------------|----------------------------------------|
| UC002 | Gestao de Grupo de Cuidado           | `/api/v1/grupos`                       |
| UC003 | Gestao de Rotinas (+ alertas UC006)  | `/api/v1/grupos/:grupoId/rotinas`      |
| UC004 | Diario de Saude do Idoso             | `/api/v1/grupos/:grupoId/diario`       |
| UC007 | Geracao de Relatorio de Evolucao     | `/api/v1/grupos/:grupoId/relatorios`   |

## Backends de dados

Controlado pela variavel `DATA_BACKEND`:

- `memory` (padrao): repositorios em memoria + notificacoes no console. Nao exige
  credenciais; ideal para desenvolvimento e testes.
- `firebase`: Firestore (persistencia), Firebase Auth (identidade) e FCM (push).
  Para producao. Configure as credenciais no `.env` (ver `.env.example`).

## Como executar

```bash
cd backend
cp .env.example .env
npm install
npm start        # sobe a API em http://localhost:3000
npm test         # executa os testes (node:test)
```

## Autenticacao

Todas as rotas de recurso exigem `Authorization: Bearer <token>`.

- Em `firebase`, o token e o ID token do Firebase Auth.
- Em `memory`, o token e o `id` de um usuario previamente cadastrado no store
  (facilita testes locais).

## Endpoints principais

```
POST   /api/v1/grupos                                   cria grupo (UC002)
GET    /api/v1/grupos                                   lista grupos do usuario
POST   /api/v1/grupos/:grupoId/convites                 convida membro
POST   /api/v1/grupos/convites/:token/aceitar           aceita convite
DELETE /api/v1/grupos/:grupoId/membros/:usuarioId       remove membro

POST   /api/v1/grupos/:grupoId/rotinas                  cria rotina (UC003)
GET    /api/v1/grupos/:grupoId/rotinas                  lista rotinas
PATCH  /api/v1/grupos/:grupoId/rotinas/:rotinaId        edita rotina
POST   /api/v1/grupos/:grupoId/rotinas/:rotinaId/concluir
POST   /api/v1/grupos/:grupoId/rotinas/:rotinaId/desativar

POST   /api/v1/grupos/:grupoId/diario                   registra entrada (UC004)
GET    /api/v1/grupos/:grupoId/diario                   lista/filtra entradas

POST   /api/v1/grupos/:grupoId/relatorios               gera relatorio PDF (UC007)
GET    /api/v1/grupos/:grupoId/relatorios               lista relatorios
```

## Equipe

Robert (UC003), Iago (UC004), Leonardo (UC002), Ledayara (UC007).
