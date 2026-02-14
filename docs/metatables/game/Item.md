# Item

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: addContainerItem, addContainerItemIndexed, clearContainerItems, clone, getActionId, getCharges, getClothSlot, getContainerItem, getContainerItems, getCount, getCountOrSubType, getDescription, getDurationTime, getId, getMarketData, getMeanPrice, getName, getNpcSaleData, getServerId, getSubType, getTeleportDestination, getText, getTier, getTooltip, getUniqueId, hasClockExpire, hasExpire, hasExpireStop, hasWearOut, isDualWield, isFluidContainer, isMarketable, isStackable, removeContainerItem, setActionId, setCount, setDescription, setTeleportDestination, setText, setTier, setTooltip, setUniqueId
- Métodos estáticos: create, createOtb
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Item -> Thing`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:771`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
