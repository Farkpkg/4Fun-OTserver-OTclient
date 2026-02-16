---
title: Item
tags: [metatables]
date: 2026-02-16
---

# Item

- **Tipo:** C++ userdata binding
- **Categoria:** game
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
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
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: addContainerItem, addContainerItemIndexed, clearContainerItems, clone, create, createOtb, getActionId, getCharges, getClothSlot, getContainerItem, getContainerItems, getCount, getCountOrSubType, getDescription, getDurationTime, getId, getMarketData, getMeanPrice, getName, getNpcSaleData, getServerId, getSubType, getTeleportDestination, getText, getTier, getTooltip, getUniqueId, hasClockExpire, hasExpire, hasExpireStop, hasWearOut, isDualWield, isFluidContainer, isMarketable, isStackable, removeContainerItem, setActionId, setCount, setDescription, setTeleportDestination, setText, setTier, setTooltip, setUniqueId
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Item -> Thing
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:771`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
