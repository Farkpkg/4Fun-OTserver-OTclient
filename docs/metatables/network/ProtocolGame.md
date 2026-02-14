# ProtocolGame

- **Tipo:** C++ userdata binding
- **Categoria:** network
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** Protocol
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: sendExtendedOpcode
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `ProtocolGame -> Protocol`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:451`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
