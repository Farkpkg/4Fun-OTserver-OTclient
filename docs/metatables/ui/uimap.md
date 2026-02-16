---
title: Uimap
tags: [metatables]
date: 2026-02-16
---

# UIMap

- **Tipo:** C++ userdata binding
- **Categoria:** ui
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
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
=======
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
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
