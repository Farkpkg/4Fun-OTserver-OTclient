---
title: Huntinganalyser
tags: [metatables]
date: 2026-02-16
---

# HuntingAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
<<<<<<< HEAD
- **Localização:** otclient/modules/game_analyser/classes/HuntingAnalyser.lua
=======
- **Definição/registro:** otclient/modules/game_analyser/classes/HuntingAnalyser.lua
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
<<<<<<< HEAD
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
=======
- Tabela Lua prototipal (`Class.__index = Class`) e instâncias com `setmetatable`.

## API
- Métodos públicos: ver funções no arquivo fonte do módulo
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: HuntingAnalyser
- Dependências: módulo Lua local

## Exemplos reais (extração direta)
- `otclient/modules/game_analyser/classes/HuntingAnalyser.lua:124`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
