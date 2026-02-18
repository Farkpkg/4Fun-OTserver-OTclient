# How to Create a New System

## 1) Definir fronteira arquitetural

- Identificar se o sistema é:
  - server-only,
  - client-only,
  - cross (client ⇄ server).

## 2) Implementar núcleo no server (quando aplicável)

- Criar domínio em C++ (`src/game`, `src/creatures`, `src/items` ou `src/io`).
- Expor hooks Lua somente quando necessário.
- Registrar eventos em RevScriptSys/API existente.

## 3) Implementar módulo client (quando aplicável)

- Criar pasta `otclient/modules/game_<nome>/`.
- Declarar `.otmod` com dependências e prioridade coerentes.
- Implementar UI/handlers de protocolo.

## 4) Contrato de protocolo

- Reusar opcode existente ou criar contrato novo.
- Para payload custom, usar extended opcode com ID único e payload validado.

## 5) Persistência

- Adicionar migração em `crystalserver/data/migrations` antes de usar nova tabela/coluna.

## 6) Documentação obrigatória

- Atualizar:
  - `04-systems/<sistema>.md`
  - `05-protocol/*` (se houver mudança de comunicação)
  - `06-database/*` (se houver mudança relacional)
