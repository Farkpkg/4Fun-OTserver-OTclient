# Circle

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_wheel/classes/geometry.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: divideIntoSlices, inArea, isPointInSlice, new
- Métodos internos: -
- Campos observados: _centerX, _centerY, _radius

## Herança e __index chain
- Chain: `Circle`
- Permite override: sim.

## Evidências
- `otclient/modules/game_wheel/classes/geometry.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
