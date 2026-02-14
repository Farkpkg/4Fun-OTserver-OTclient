# LootAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/LootAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addLootedItems, checkBalance, checkLootHour, create, gaugeIsVisible, getTarget, graphIsVisible, openTargetConfig, reset, setLootPerHourGauge, setLootPerHourGraph, setTarget, updateBasePriceFromLootedItems, updateBasicUI, updateGraph, updateGraphics, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `LootAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/LootAnalyser.lua:66`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
