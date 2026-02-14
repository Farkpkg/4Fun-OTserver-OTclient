# LocalPlayer

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** Player
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
