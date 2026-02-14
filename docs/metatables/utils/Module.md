# Module

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: canReload, canUnload, getAuthor, getAutoLoadPriority, getDescription, getName, getSandbox, getVersion, getWebsite, isAutoLoad, isLoaded, isReloadble, isSandboxed, load, reload, unload
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Module`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:320`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
