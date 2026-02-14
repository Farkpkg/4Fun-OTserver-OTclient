# UIGridLayout

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** UILayout
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getCellSize, getCellSpacing, getNumColumns, getNumLines, isUIGridLayout, setCellHeight, setCellSize, setCellSpacing, setCellWidth, setFlow, setNumColumns, setNumLines
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIGridLayout -> UILayout`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:897`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
