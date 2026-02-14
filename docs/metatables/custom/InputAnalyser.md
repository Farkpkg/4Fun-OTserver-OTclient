# InputAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/InputAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addInputDamage, checkAnchos, checkDPS, clipboardData, create, damageGraphIsVisible, damageSourceIsVisible, damageTypesIsVisible, loadConfigJson, reset, saveConfigJson, setDamageGraph, setDamageSource, setDamageTypes, toggleDamageSource, toggleSessionMode, updateMinuteData, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `InputAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/InputAnalyser.lua:81`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
