# UIMinimap

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: anchorPosition, centerInPosition, fillPosition, floorDown, floorUp, getCameraPosition, getMaxZoom, getMinZoom, getScale, getTilePoint, getTilePosition, getTileRect, getZoom, setCameraPosition, setMaxZoom, setMixZoom, setZoom, zoomIn, zoomOut
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIMinimap -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1170`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
