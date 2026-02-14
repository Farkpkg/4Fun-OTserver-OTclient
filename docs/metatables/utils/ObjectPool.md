# ObjectPool

- **Tipo:** Pure Lua metatable
- **Categoria:** utils
- **Localização:** otclient/modules/corelib/objectpool.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: clear, get, new, release
- Métodos internos: -
- Campos observados: pool

## Herança e __index chain
- Chain: `ObjectPool`
- Permite override: sim.

## Evidências
- `otclient/modules/corelib/objectpool.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
