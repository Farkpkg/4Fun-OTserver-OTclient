# LoadedPlayer

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/gamelib/player.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: getId, getName, getVocation, isLoaded, setId, setName, setVocation
- Métodos internos: -
- Campos observados: playerId, playerName, playerVocation

## Herança e __index chain
- Chain: `LoadedPlayer`
- Permite override: sim.

## Evidências
- `otclient/modules/gamelib/player.lua:283`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
