---
title: Thingtype
tags: [metatables]
date: 2026-02-16
---

# ThingType

- **Tipo:** C++ userdata binding
- **Categoria:** render
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: blockProjectile, exportImage, getAnimationPhases, getCategory, getClassification, getClothSlot, getDefaultAction, getDescription, getDisplacement, getDisplacementX, getDisplacementY, getElevation, getGroundSpeed, getHeight, getId, getLayers, getLensHelp, getLight, getMarketData, getMaxTextLength, getMeanPrice, getMinimapColor, getName, getNpcSaleData, getNumPatternX, getNumPatternY, getNumPatternZ, getRealSize, getSize, getSkillWheelGemQualityId, getSkillWheelGemVocationId, getSprites, getWidth, hasAttribute, hasClockExpire, hasDisplacement, hasElevation, hasExpire, hasExpireStop, hasFloorChange, hasLensHelp, hasLight, hasMiniMapColor, hasSkillWheelGem, hasWearOut, isAmmo, isAnimateAlways, isChargeable, isCloth, isContainer, isDontHide, isDualWield, isFluidContainer, isForceUse, isFullGround, isGround, isGroundBorder, isHangable, isHookEast, isHookSouth, isIgnoreLook, isLyingCorpse, isMarketable, isMultiUse, isNotMoveable, isNotPathable, isNotWalkable, isOnBottom, isOnTop, isPickupable, isPodium, isRotateable, isSplash, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, isWritable, isWritableOnce, setPathable
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `ThingType`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:684`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: blockProjectile, create, exportImage, getAnimationPhases, getCategory, getClassification, getClothSlot, getDefaultAction, getDescription, getDisplacement, getDisplacementX, getDisplacementY, getElevation, getGroundSpeed, getHeight, getId, getLayers, getLensHelp, getLight, getMarketData, getMaxTextLength, getMeanPrice, getMinimapColor, getName, getNpcSaleData, getNumPatternX, getNumPatternY, getNumPatternZ, getRealSize, getSize, getSkillWheelGemQualityId, getSkillWheelGemVocationId, getSprites, getWidth, hasAttribute, hasClockExpire, hasDisplacement, hasElevation, hasExpire, hasExpireStop, hasFloorChange, hasLensHelp, hasLight, hasMiniMapColor, hasSkillWheelGem, hasWearOut, isAmmo, isAnimateAlways, isChargeable, isCloth, isContainer, isDontHide, isDualWield, isFluidContainer, isForceUse, isFullGround, isGround, isGroundBorder, isHangable, isHookEast, isHookSouth, isIgnoreLook, isLyingCorpse, isMarketable, isMultiUse, isNotMoveable, isNotPathable, isNotWalkable, isOnBottom, isOnTop, isPickupable, isPodium, isRotateable, isSplash, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, isWritable, isWritableOnce, setPathable
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: ThingType
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:684`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
