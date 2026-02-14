# UIMap

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: clearTiles, create, drawSelf, followCreature, getCameraPosition, getFloorViewMode, getFollowingCreature, getMaxZoomIn, getMaxZoomOut, getMinimumAmbientLight, getNextShader, getPosition, getShader, getSightSpectators, getSpectators, getTile, getVisibleDimension, getZoom, isDrawingHealthBars, isDrawingLights, isDrawingManaBar, isDrawingNames, isInRange, isKeepAspectRatioEnabled, isLimitVisibleRangeEnabled, isLimitedVisibleDimension, isSwitchingShader, lockVisibleFloor, movePixels, setAntiAliasingMode, setCameraPosition, setCrosshairTexture, setDrawHarmony, setDrawHealthBars, setDrawHighlightTarget, setDrawLights, setDrawManaBar, setDrawNames, setDrawViewportEdge, setFloorFading, setFloorViewMode, setKeepAspectRatio, setLimitVisibleDimension, setLimitVisibleRange, setMaxZoomIn, setMaxZoomOut, setMinimumAmbientLight, setShader, setShadowFloorIntensity, setVisibleDimension, setZoom, unlockVisibleFloor, zoomIn, zoomOut
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: UIMap -> UIWidget
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:1114`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
