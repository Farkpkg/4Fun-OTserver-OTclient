# Workshop

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_wheel/classes/workshop.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: createFragments, getBonusDescription, getBonusValue, getDataByBonus, getEquippedGemBonus, getFragmentList, getGemInformationByBonus, getSideBonusDescription, getSortList, getUpgradeBonus, onSearchChange, onSelectChild, onUpgradeModification, searchModifications, setCurrentPage, showFragmentList
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `Workshop`
- Permite override: sim.

## Evidências
- `otclient/modules/game_wheel/classes/workshop.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
