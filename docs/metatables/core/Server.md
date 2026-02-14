# Server

- **Tipo:** C++ userdata binding
- **Categoria:** core
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: acceptNext, close, isOpen
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Server`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:999`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
