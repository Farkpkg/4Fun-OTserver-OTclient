# PartyHuntAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/PartyHuntAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: clipboardData, create, lootSplitter, onPartyAnalyzer, reset, startEvent, updateWindow
- Métodos internos: -
- Campos observados: lastUpdateTime, updateScheduled

## Herança e __index chain
- Chain: `PartyHuntAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/PartyHuntAnalyser.lua:48`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
