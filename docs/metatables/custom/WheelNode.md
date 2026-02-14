# WheelNode

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** -
- **Classe base:** (root)
- **Metamétodos ativos:** -

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: new
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `WheelNode`
- Permite override: sim.

## Evidências
- `otclient/modules/game_wheel/classes/wheelnode.lua:4`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
