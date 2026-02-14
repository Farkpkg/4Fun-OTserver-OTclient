# UIBoxLayout

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** UILayout
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: setFitChildren, setSpacing
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIBoxLayout -> UILayout`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:881`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
