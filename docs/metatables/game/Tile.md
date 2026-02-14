# Tile

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** AttachableObject
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: addThing, canShoot, clean, getCreatures, getFlags, getGround, getItems, getPosition, getText, getThing, getThingCount, getThingStackPos, getThings, getTimer, getTopCreature, getTopLookThing, getTopMoveThing, getTopMultiUseThing, getTopThing, getTopUseThing, hasElevation, hasFlag, hasFloorChange, isClickable, isCompletelyCovered, isCovered, isEmpty, isFullGround, isFullyOpaque, isHouseTile, isLookPossible, isPathable, isSelected, isWalkable, overwriteMinimapColor, remFlag, removeThing, select, setFill, setFlag, setFlags, setText, setTimer, unselect
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Tile -> AttachableObject`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:988`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
