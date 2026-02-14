# Thing

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** AttachableObject
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: canAnimate, getClassification, getDefaultAction, getExactSize, getId, getMarketData, getMeanPrice, getNpcSaleData, getParentContainer, getPosition, getScaleFactor, getStackPos, getStackPriority, getTile, hasExpireStop, hasWearout, isAmmo, isContainer, isCreature, isEffect, isForceUse, isFullGround, isGround, isGroundBorder, isHighlighted, isHookSouth, isIgnoreLook, isItem, isLocalPlayer, isLyingCorpse, isMarked, isMarketable, isMissile, isMonster, isMultiUse, isNotMoveable, isNpc, isOnBottom, isOnTop, isPickupable, isPlayer, isRotateable, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, setAnimate, setHighlight, setId, setMarked, setPosition, setScaleFactor, setShader
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Thing -> AttachableObject`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:487`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
