---
title: Localplayer
tags: [metatables]
date: 2026-02-16
---

# LocalPlayer

- **Tipo:** C++ userdata binding
- **Categoria:** game
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** Player
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: autoWalk, canWalk, getBaseMagicLevel, getBlessings, getExperience, getFreeCapacity, getHarmony, getHealth, getInventoryCount, getInventoryItem, getLevel, getLevelPercent, getMagicLevel, getMagicLevelPercent, getMana, getManaShield, getMaxHealth, getMaxMana, getMaxManaShield, getOfflineTrainingTime, getRegenerationTime, getResourceBalance, getSkillBaseLevel, getSkillLevel, getSkillLevelPercent, getSoul, getStamina, getStates, getStoreExpBoostTime, getTotalCapacity, getTotalMoney, getVocation, hasEquippedItemId, hasSight, isAutoWalking, isKnown, isPreWalking, isPremium, isSerene, isServerWalking, isSupplyStashAvailable, isWalkLocked, lockWalk, preWalk, setExperience, setFreeCapacity, setHealth, setInventoryItem, setKnown, setLevel, setMagicLevel, setMana, setManaShield, setResourceBalance, setSkill, setSoul, setStamina, setStates, setTotalCapacity, stopAutoWalk, unlockWalk
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `LocalPlayer -> Player`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:925`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: autoWalk, canWalk, getBaseMagicLevel, getBlessings, getExperience, getFreeCapacity, getHarmony, getHealth, getInventoryCount, getInventoryItem, getLevel, getLevelPercent, getMagicLevel, getMagicLevelPercent, getMana, getManaShield, getMaxHealth, getMaxMana, getMaxManaShield, getOfflineTrainingTime, getRegenerationTime, getResourceBalance, getSkillBaseLevel, getSkillLevel, getSkillLevelPercent, getSoul, getStamina, getStates, getStoreExpBoostTime, getTotalCapacity, getTotalMoney, getVocation, hasEquippedItemId, hasSight, isAutoWalking, isKnown, isPreWalking, isPremium, isSerene, isServerWalking, isSupplyStashAvailable, isWalkLocked, lockWalk, preWalk, setExperience, setFreeCapacity, setHealth, setInventoryItem, setKnown, setLevel, setMagicLevel, setMana, setManaShield, setResourceBalance, setSkill, setSoul, setStamina, setStates, setTotalCapacity, stopAutoWalk, unlockWalk
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: LocalPlayer -> Player
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:925`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
