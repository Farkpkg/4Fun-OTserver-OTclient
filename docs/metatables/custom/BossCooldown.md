# BossCooldown

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/BossCooldown.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: checkTicks, create, getCooldown, hasCooldown, reset, setupCooldown, updateWindow
- Métodos internos: -
- Campos observados: lastTick, search, sort

## Herança e __index chain
- Chain: `BossCooldown`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/BossCooldown.lua:34`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
