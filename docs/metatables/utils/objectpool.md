---
title: Objectpool
tags: [metatables]
date: 2026-02-16
---

# ObjectPool

- **Tipo:** Pure Lua metatable
- **Categoria:** utils
<<<<<<< HEAD
- **Localização:** otclient/modules/corelib/objectpool.lua
=======
- **Definição/registro:** otclient/modules/corelib/objectpool.lua
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index

## Estrutura interna
<<<<<<< HEAD
- Classe/protótipo Lua com `__index` e construtores via `setmetatable`.

## API
- Métodos públicos: clear, get, new, release
- Métodos internos: -
- Campos observados: pool

## Herança e __index chain
- Chain: `ObjectPool`
- Permite override: sim.

## Evidências
- `otclient/modules/corelib/objectpool.lua:2`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Tabela Lua prototipal (`Class.__index = Class`) e instâncias com `setmetatable`.

## API
- Métodos públicos: ver funções no arquivo fonte do módulo
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: ObjectPool
- Dependências: módulo Lua local

## Exemplos reais (extração direta)
- `otclient/modules/corelib/objectpool.lua:2`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
