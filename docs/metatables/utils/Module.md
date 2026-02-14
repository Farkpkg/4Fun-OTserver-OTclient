# Module

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: canReload, canUnload, getAuthor, getAutoLoadPriority, getDescription, getName, getSandbox, getVersion, getWebsite, isAutoLoad, isLoaded, isReloadble, isSandboxed, load, reload, unload
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Module
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/framework/luafunctions.cpp:320`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
