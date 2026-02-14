# ControllerAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/Controller.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: startEvent
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `ControllerAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/Controller.lua:13`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
