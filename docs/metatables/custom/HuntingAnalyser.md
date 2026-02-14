# HuntingAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
- **Localização:** otclient/modules/game_analyser/classes/HuntingAnalyser.lua
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addDealDamage, addHealing, addLootedItems, addMonsterKilled, addRawXPGain, addSuppliesItems, addXpGain, checkBalance, clipboardData, create, getBalance, getDamage, getDamageHour, getDamageTicks, getHealing, getHealingHour, getHealingTicks, getKilledMonsters, getLaunchTime, getLoot, getLootedItems, getRawXPGain, getSession, getStartExp, getSupplies, getSuppliesItems, getXpGain, getXpHour, loadConfigJson, reset, saveConfigJson, saveToFile, saveToJson, setBalance, setDamage, setDamageHour, setDamageTicks, setHealing, setHealingHour, setHealingTicks, setKilledMonsters, setLaunchTime, setLoot, setLootedItems, setRawXPGain, setSession, setShowBaseXp, setStartExp, setSupplies, setSuppliesItems, setXpGain, setXpHour, setupStartExp, updateLootedItemValue, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `HuntingAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/HuntingAnalyser.lua:124`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
