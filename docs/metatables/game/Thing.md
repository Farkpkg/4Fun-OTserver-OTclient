# Thing

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** AttachableObject
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: canAnimate, getClassification, getDefaultAction, getExactSize, getId, getMarketData, getMeanPrice, getNpcSaleData, getParentContainer, getPosition, getScaleFactor, getStackPos, getStackPriority, getTile, hasExpireStop, hasWearout, isAmmo, isContainer, isCreature, isEffect, isForceUse, isFullGround, isGround, isGroundBorder, isHighlighted, isHookSouth, isIgnoreLook, isItem, isLocalPlayer, isLyingCorpse, isMarked, isMarketable, isMissile, isMonster, isMultiUse, isNotMoveable, isNpc, isOnBottom, isOnTop, isPickupable, isPlayer, isRotateable, isStackable, isTopEffect, isTranslucent, isUnwrapable, isUsable, isWrapable, setAnimate, setHighlight, setId, setMarked, setPosition, setScaleFactor, setShader
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Thing -> AttachableObject
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:487`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
