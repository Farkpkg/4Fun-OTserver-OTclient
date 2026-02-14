# ThingType

- **Tipo:** C++ userdata binding
- **Categoria:** render
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
