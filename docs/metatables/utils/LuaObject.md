# LuaObject

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Localização:** otclient/src/framework/luaengine/luainterface.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getClassName
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `LuaObject`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luaengine/luainterface.cpp:48`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
