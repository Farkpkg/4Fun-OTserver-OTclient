# ThingType

- **Tipo:** C++ userdata binding
- **Categoria:** render
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
