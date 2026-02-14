# XPAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/XPAanalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addRawXPGain, addXpGain, checkAnchos, checkExpHour, create, forceUpdateUI, gaugeIsVisible, getTarget, graphIsVisible, loadConfigJson, openTargetConfig, rawXPIsVisible, reset, saveConfigJson, setGaugeVisible, setGraphVisible, setRawXPVisible, setupLevel, setupStartExp, updateBasicUI, updateCalculations, updateExpensiveUI, updateGraph, updateGraphics, updateNextLevel, updateTooltip, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `XPAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/XPAanalyser.lua:74`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
