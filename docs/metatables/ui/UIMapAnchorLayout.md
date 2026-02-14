# UIMapAnchorLayout

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIAnchorLayout
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: -
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIMapAnchorLayout -> UIAnchorLayout`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1223`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
