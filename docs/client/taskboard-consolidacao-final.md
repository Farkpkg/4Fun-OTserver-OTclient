<!-- REVIEW: Este documento contém referências históricas de módulos legados (`game_weeklytasks`, `weekly_tasks.lua`) que não existem no snapshot atual. Tratar como contexto de migração, não como estado vigente. -->

# TaskBoard — Consolidação Final (Sistema Único)

## Objetivo
Consolidar TaskBoard como **única stack ativa** para Weekly/Bounty/Shop, removendo o legado e mantendo apenas o fluxo unificado cliente+servidor via ExtendedOpcode 242.

---

## Cliente — Itens Legacy Detectados
Itens legacy identificados antes da remoção:
- `otclient/modules/game_weeklytasks/game_weeklytasks.lua`
- `otclient/modules/game_weeklytasks/game_weeklytasks.otmod`
- `otclient/modules/game_weeklytasks/game_weeklytasks.otui`
- Referência no loader: `otclient/modules/game_interface/interface.otmod` (`- game_weeklytasks`)
- Uso de opcodes legacy no módulo weekly antigo:
  - `OPCODE_ACTION = 240`
  - `OPCODE_EVENT = 241`

## Cliente — Remoção executada
- Removido diretório completo `otclient/modules/game_weeklytasks/`.
- Removida referência `game_weeklytasks` do `interface.otmod`.

Resultado: cliente mantém apenas `modules/game_taskboard` para TaskBoard.

---

## Servidor — Itens Legacy Detectados
Itens legacy identificados antes da remoção:
- `crystalserver/data/scripts/lib/weekly_tasks.lua`
- `crystalserver/data/scripts/creaturescripts/player/weekly_tasks.lua`
- `crystalserver/data/scripts/globalevents/weekly_tasks_reset.lua`
- `crystalserver/data/weeklytasks/` (pools/configs do sistema antigo)
- ExtendedOpcodes legacy do weekly antigo:
  - action `240`
  - event `241`

## Servidor — Remoção executada
- Removido `weekly_tasks.lua` (lib legacy).
- Removido creaturescript do weekly legacy.
- Removido globalevent de reset legacy.
- Removida pasta `data/weeklytasks/` legacy.

Resultado: servidor mantém apenas a stack `data/modules/taskboard/*` para Weekly/Bounty/Shop.

---

## Validação de cobertura funcional (TaskBoard unificado)
Cobertura confirmada no TaskBoard atual:
- Weekly kill tasks ✅
- Weekly delivery tasks ✅
- Shop por pontos ✅
- Multiplicador ✅
- Reroll ✅
- Claim individual de bounty ✅
- Claim diário de bounties ✅
- Reset semanal por `weekKey` (`ensureWeek`) ✅

---

## Protocolo final (sem legado)
- Opcode ativo do TaskBoard: **242**.
- Ações ativas: `open`, `selectDifficulty`, `reroll`, `deliver`, `buy`, `claimBounty`, `claimDaily`.
- Não há mais registro ativo do weekly legacy via opcodes 240/241 em scripts de weekly.

---

## Limpeza adicional executada
- Ajuste de consistência de payload no servidor para `multiplier` (objeto/metadata, não número puro), evitando divergência com consumo do cliente.
- Mantido bootstrap do taskboard como carregamento oficial da stack única.

---

## Itens remanescentes (não ativos no runtime de legado)
- Migrações SQL históricas relacionadas a `player_weekly_tasks` continuam no histórico de migração (`data/migrations/64.lua` e `65.lua`), mas não representam stack legacy ativa.

---

## Conclusão
- Apenas **um TaskBoard** permanece ativo (cliente + servidor).
- Apenas **uma stack de domínio** permanece para Weekly/Bounty/Shop.
- Apenas **um ExtendedOpcode** permanece para TaskBoard (**242**).
- Não há coexistência operacional com weekly legacy.

