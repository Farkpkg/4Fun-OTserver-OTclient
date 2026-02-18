# Item System

## Estrutura

- Tipos e definições: `src/items/items.*`, `src/items/items_definitions.hpp`
- Instâncias e atributos: `src/items/item.*`, `src/items/functions/item/*`
- Containers: `src/items/containers/*`
- Decay: `src/items/decay/*`
- Armamentos: `src/items/weapons/*`

## Carga de dados

- XML de itens carregado no bootstrap: `Item::items.loadFromXml()`.
- Dependências de gameplay (trade, inventário, loot, stash, market) consomem este catálogo.

## Persistência vinculada

- Itens de player e containers persistidos em tabelas como `player_items`, `player_depotitems`, `player_inboxitems`.
