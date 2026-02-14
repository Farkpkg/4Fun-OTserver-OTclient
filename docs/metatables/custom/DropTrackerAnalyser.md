# DropTrackerAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/DropTrackerAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: checkMonsterKilled, checkTracker, create, isInDropTracker, loadConfigJson, managerDropItem, removeAllItems, removeItem, reset, saveConfigJson, sendDropedItems, showItemContextMenu, tryAddingMonsterDrop, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `DropTrackerAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/DropTrackerAnalyser.lua:83`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
