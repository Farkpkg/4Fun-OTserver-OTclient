# UIGraph

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: addValue, clear, createGraph, getGraphsCount, setCapacity, setGraphVisible, setInfoLineColor, setInfoText, setLineColor, setLineWidth, setShowInfo, setShowLabels, setTextBackground, setTitle
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIGraph -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1205`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
