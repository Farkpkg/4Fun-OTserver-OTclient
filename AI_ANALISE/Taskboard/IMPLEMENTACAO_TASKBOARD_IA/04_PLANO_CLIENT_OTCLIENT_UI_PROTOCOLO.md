# Plano Client (otclient) — Task Board isolada

## 1) Módulo dedicado
Criar `otclient/modules/game_taskboard/`:
- `taskboard.otmod`
- `taskboard.lua`
- `taskboard.otui`
- `styles/style.otui`
- `images/*`

## 2) Padrões de UI permitidos
- Reusar padrões visuais e widgets recorrentes do projeto.
- Reusar mecânicas genéricas de janela/tabs/cards.
- **Não referenciar lógica de Prey no módulo.**

## 3) Contrato de parse
Adicionar callbacks dedicados:
- `g_game.onTaskBoardOpen(snapshot)`
- `g_game.onTaskBoardBountyUpdate(data)`
- `g_game.onTaskBoardWeeklyUpdate(data)`
- `g_game.onTaskBoardShopUpdate(data)`
- `g_game.onTaskBoardCurrencies(data)`

## 4) Contrato de send
Adicionar APIs de intenção:
- `sendTaskBoardOpen()`
- `sendTaskBoardSelectBounty(slotId, taskId)`
- `sendTaskBoardReroll(slotId, rerollType)`
- `sendTaskBoardClaim(slotId)`
- `sendTaskBoardWeeklyClaim(taskId)`
- `sendTaskBoardBuy(shopItemId)`
- `sendTaskBoardPreferredUpdate(payload)`

## 5) Modelo local Lua
```lua
TaskBoardModel = {
  tabs = { current = 'bounty' },
  bounty = { slots = {}, active = nil },
  weekly = { tasks = {}, multiplier = 1.0, resetAt = 0 },
  shop = { offers = {}, owned = {} },
  preferred = { likes = {}, dislikes = {}, limits = {} },
  currencies = { bountyPoints = 0, huntingPoints = 0, soulseals = 0, rerollTokens = 0 }
}
```

## 6) Entrada UX
- Context menu: nova entrada “Task Board”.
- Hotkey opcional dedicada.

## 7) Critérios de pronto (client)
- Fluxo completo nas 3 abas.
- Atualizações reativas por pacote server.
- Zero acoplamento funcional com Prey.
