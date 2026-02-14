# House

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: addDoor, getEntry, getId, getName, getRent, getSize, getTile, getTownId, removeDoor, removeDoorById, setEntry, setId, setName, setRent, setSize, setTile, setTownId
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `House`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:545`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
