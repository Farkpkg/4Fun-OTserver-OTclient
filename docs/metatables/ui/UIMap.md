# UIMap

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: clearTiles, drawSelf, followCreature, getCameraPosition, getFloorViewMode, getFollowingCreature, getMaxZoomIn, getMaxZoomOut, getMinimumAmbientLight, getNextShader, getPosition, getShader, getSightSpectators, getSpectators, getTile, getVisibleDimension, getZoom, isDrawingHealthBars, isDrawingLights, isDrawingManaBar, isDrawingNames, isInRange, isKeepAspectRatioEnabled, isLimitVisibleRangeEnabled, isLimitedVisibleDimension, isSwitchingShader, lockVisibleFloor, movePixels, setAntiAliasingMode, setCameraPosition, setCrosshairTexture, setDrawHarmony, setDrawHealthBars, setDrawHighlightTarget, setDrawLights, setDrawManaBar, setDrawNames, setDrawViewportEdge, setFloorFading, setFloorViewMode, setKeepAspectRatio, setLimitVisibleDimension, setLimitVisibleRange, setMaxZoomIn, setMaxZoomOut, setMinimumAmbientLight, setShader, setShadowFloorIntensity, setVisibleDimension, setZoom, unlockVisibleFloor, zoomIn, zoomOut
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIMap -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1114`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
