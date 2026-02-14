# MarketHistory

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_market/classes/t_history.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: onBottomListValueChange, onParseMarketHistory, onSelectHistoryChild, onTopListValueChange
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `MarketHistory`
- Permite override: sim.

## Evidências
- `otclient/modules/game_market/classes/t_history.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
