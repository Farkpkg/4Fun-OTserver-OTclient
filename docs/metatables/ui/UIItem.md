# UIItem

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: clearItem, getFlipDirection, getItem, getItemCount, getItemCountOrSubType, getItemId, getItemSubType, isItemVisible, isVirtual, setFlipDirection, setItem, setItemCount, setItemId, setItemSubType, setItemVisible, setShowCount, setVirtual
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIItem -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1047`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
