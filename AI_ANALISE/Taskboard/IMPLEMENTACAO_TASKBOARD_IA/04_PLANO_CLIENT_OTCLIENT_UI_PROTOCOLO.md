# Plano Client (otclient) — Task Board isolada

## 1) Módulo dedicado
Criar `otclient/modules/game_taskboard/`:
- `taskboard.otmod`
- `taskboard.lua`
- `taskboard.otui`
- `styles/style.otui`
- `images/*`

## 2) Padrões de UI permitidos (explícito)
- Reusar padrões visuais e widgets recorrentes do projeto.
- Reusar mecânicas genéricas de janela/tabs/cards.
- **Não referenciar lógica de Prey no módulo.**
- Seguir as regras de `new_docs/UI_CANONICAL_RULES.md`.

## 3) Funcionamento de UI (estado -> render -> ação)
1. Server envia snapshot/update.
2. Parser C++ transforma payload em callback Lua.
3. Módulo Lua atualiza `TaskBoardModel` (single source no client).
4. OTUI renderiza (cards, tabs, botões) a partir do model.
5. Clique do usuário envia intenção ao server (`sendTaskBoard*`).
6. UI só confirma estado após ACK/update do server.

## 4) Contrato de parse
Adicionar callbacks dedicados:
- `g_game.onTaskBoardOpen(snapshot)`
- `g_game.onTaskBoardBountyUpdate(data)`
- `g_game.onTaskBoardWeeklyUpdate(data)`
- `g_game.onTaskBoardShopUpdate(data)`
- `g_game.onTaskBoardCurrencies(data)`

## 5) Contrato de send
Adicionar APIs de intenção:
- `sendTaskBoardOpen()`
- `sendTaskBoardSelectBounty(slotId, taskId)`
- `sendTaskBoardReroll(slotId, rerollType)`
- `sendTaskBoardClaim(slotId)`
- `sendTaskBoardWeeklyClaim(taskId)`
- `sendTaskBoardBuy(shopItemId)`
- `sendTaskBoardPreferredUpdate(payload)`

## 6) Modelo local Lua
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

## 7) Widgets existentes a reutilizar (padrão)
- Base Window/MainWindow e variações em `otclient/data/styles/10-windows.otui`.
- Buttons/CheckBox/ProgressBar/TabBar/Separators em:
  - `otclient/data/styles/10-buttons.otui`
  - `otclient/data/styles/10-checkboxes.otui`
  - `otclient/data/styles/10-progressbars.otui`
  - `otclient/data/styles/20-tabbars.otui`
  - `otclient/data/styles/10-separators.otui`
- MiniWindow e containers em `otclient/data/styles/30-miniwindow.otui`.
- Referências de tela com cards/tabs/estados:
  - `otclient/modules/game_rewardwall/styles/style.otui`
  - `otclient/modules/game_rewardwall/styles/pickreward.otui`

## 8) Entrada UX
- Context menu: nova entrada “Task Board”.
- Hotkey opcional dedicada.
- Não esconder feature por heurística: usar somente gate explícito.

## 9) Critérios de pronto (client)
- Fluxo completo nas 3 abas.
- Atualizações reativas por pacote server.
- Zero acoplamento funcional com Prey.
- Layout aderente às regras canônicas de UI do projeto.
