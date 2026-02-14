# ImpactAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/ImpactAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addDealDamage, addHealing, checkAnchos, create, damageTypeIsVisible, gaugeDPSIsVisible, gaugeHPSIsVisible, getAllTimeHightDps, graphDPSIsVisible, graphHPSIsVisible, loadConfigJson, openTargetConfig, reset, saveConfigJson, setAllTimeHightDps, setAllTimeHightHps, setDPSGauge, setDPSGraph, setDamageType, setHPSGauge, setHPSGraph, toggleSessionMode, updateGraphics, updateMinuteData, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `ImpactAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/ImpactAnalyser.lua:73`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
