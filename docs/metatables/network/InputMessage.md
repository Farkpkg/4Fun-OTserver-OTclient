# InputMessage

- **Tipo:** C++ userdata binding
- **Categoria:** network
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: create, decryptRsa, eof, getBuffer, getMessageSize, getReadSize, getString, getU16, getU32, getU64, getU8, getUnreadSize, peekU16, peekU32, peekU64, peekU8, setBuffer, skipBytes
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: InputMessage
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/framework/luafunctions.cpp:1034`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
