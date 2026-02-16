# InputAnalyser

- **Tipo:** Pure Lua metatable
- **Categoria:** custom
<<<<<<< HEAD
- **Localização:** otclient/modules/game_analyser/classes/InputAnalyser.lua
=======
- **Definição/registro:** otclient/modules/game_analyser/classes/InputAnalyser.lua
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
<<<<<<< HEAD
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: addInputDamage, checkAnchos, checkDPS, clipboardData, create, damageGraphIsVisible, damageSourceIsVisible, damageTypesIsVisible, loadConfigJson, reset, saveConfigJson, setDamageGraph, setDamageSource, setDamageTypes, toggleDamageSource, toggleSessionMode, updateMinuteData, updateWindow
- Métodos internos: -
- Campos observados: -

## Herança e __index chain
- Chain: `InputAnalyser`
- Permite override: sim.

## Evidências
- `otclient/modules/game_analyser/classes/InputAnalyser.lua:81`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Tabela Lua prototipal (`Class.__index = Class`) e instâncias com `setmetatable`.

## API
- Métodos públicos: ver funções no arquivo fonte do módulo
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: InputAnalyser
- Dependências: módulo Lua local

## Exemplos reais (extração direta)
- `otclient/modules/game_analyser/classes/InputAnalyser.lua:81`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
