# Container

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getCapacity, getContainerItem, getFirstIndex, getId, getItem, getItems, getItemsCount, getName, getSize, getSlotPosition, hasPages, hasParent, isClosed, isUnlocked
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Container`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:455`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
