# LootAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
<<<<<<< HEAD
- **Localização:** otclient/modules/game_analyser/classes/LootAnalyser.lua
=======
- **Definição/registro:** otclient/modules/game_analyser/classes/LootAnalyser.lua
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
<<<<<<< HEAD
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addLootedItems, checkBalance, checkLootHour, create, gaugeIsVisible, getTarget, graphIsVisible, openTargetConfig, reset, setLootPerHourGauge, setLootPerHourGraph, setTarget, updateBasePriceFromLootedItems, updateBasicUI, updateGraph, updateGraphics, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `LootAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/LootAnalyser.lua:66`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Tabela Lua prototipal (`Class.__index = Class`) e instâncias com `setmetatable`.

## API
- Métodos públicos: ver funções no arquivo fonte do módulo
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: LootAnalyser
- Dependências: módulo Lua local

## Exemplos reais (extração direta)
- `otclient/modules/game_analyser/classes/LootAnalyser.lua:66`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
