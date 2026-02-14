# InputMessage

- **Tipo:** C++ userdata binding
- **Categoria:** network
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: decryptRsa, eof, getBuffer, getMessageSize, getReadSize, getString, getU16, getU32, getU64, getU8, getUnreadSize, peekU16, peekU32, peekU64, peekU8, setBuffer, skipBytes
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `InputMessage`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:1034`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
