# Plano Server (crystalserver) — Task Board isolada

## 1) Arquitetura alvo
Criar um subdomínio próprio no server, por exemplo:
- `src/io/iotaskboard.hpp/.cpp`
- `src/game/taskboard/taskboard_service.hpp/.cpp`
- `src/game/taskboard/taskboard_types.hpp`

## 2) Entidades mínimas
- `TaskBoardProfile` (saldos, config ativa por player)
- `BountySlot` (3 slots simultâneos)
- `WeeklyTask`
- `TaskBoardShopState`
- `PreferredListState`

## 3) Regras de negócio essenciais
- Geração de Bounty por dificuldade.
- Seleção exclusiva de slot ativo por regra definida.
- Progressão por kill event com validação server-side.
- Claim com cálculo de recompensa e auditoria.
- Reroll com custo e cooldown.
- Reset semanal atômico/idempotente para weekly.

## 4) Persistência (obrigatória)
Criar migration com tabelas próprias Task Board, sem misturar com Prey.

Exemplos de superfícies:
- `player_taskboard_profile`
- `player_taskboard_bounty_slots`
- `player_taskboard_weekly_tasks`
- `player_taskboard_preferred_list`
- `player_taskboard_shop_unlocks`

## 5) Protocolo
- Novos handlers `parseTaskBoard*` em `protocolgame`.
- Novos `sendTaskBoard*` para snapshots e updates incrementais.
- Versionamento/gate por feature flag explícita.

## 6) Integração com Player/Game
- Inicialização no login.
- Tick/cron para reset semanal.
- Hooks de kill e claim.

## 7) Critérios de pronto (server)
- Nenhuma dependência semântica de Prey.
- Todas as ações validadas no server.
- Persistência íntegra e recuperável após restart.
