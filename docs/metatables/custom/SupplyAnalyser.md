# SupplyAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/SupplyAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addSuppliesItems, checkBalance, checkDecrease, checkSupplyHour, create, decreaseWidget, gaugeIsVisible, getItemCount, getTarget, graphIsVisible, openTargetConfig, reset, setSupplyPerHourGauge, setSupplyPerHourGraph, setTarget, updateBasicUI, updateGraph, updateGraphics, updateWidget, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `SupplyAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/SupplyAnalyser.lua:66`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
