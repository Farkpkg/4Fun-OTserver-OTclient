# Tile

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** AttachableObject
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: addThing, canShoot, clean, getCreatures, getFlags, getGround, getItems, getPosition, getText, getThing, getThingCount, getThingStackPos, getThings, getTimer, getTopCreature, getTopLookThing, getTopMoveThing, getTopMultiUseThing, getTopThing, getTopUseThing, hasElevation, hasFlag, hasFloorChange, isClickable, isCompletelyCovered, isCovered, isEmpty, isFullGround, isFullyOpaque, isHouseTile, isLookPossible, isPathable, isSelected, isWalkable, overwriteMinimapColor, remFlag, removeThing, select, setFill, setFlag, setFlags, setText, setTimer, unselect
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Tile -> AttachableObject
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:988`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
