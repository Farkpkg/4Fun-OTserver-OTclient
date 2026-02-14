# MarketOwnOffers

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_market/classes/t_ownOffers.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: cancelMarketOffer, onBottomListValueChange, onParseMyOffers, onSelectMyOffersChild, onTopListValueChange
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `MarketOwnOffers`
- Permite override: sim.

## Evidências
- `otclient/modules/game_market/classes/t_ownOffers.lua:31`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
