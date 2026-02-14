# LocalPlayer

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** Player
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
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
