---
title: Container
tags: [metatables]
date: 2026-02-16
---

# Container

- **Tipo:** C++ userdata binding
- **Categoria:** game
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getCapacity, getContainerItem, getFirstIndex, getId, getItem, getItems, getItemsCount, getName, getSize, getSlotPosition, hasPages, hasParent, isClosed, isUnlocked
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Container`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:455`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: getCapacity, getContainerItem, getFirstIndex, getId, getItem, getItems, getItemsCount, getName, getSize, getSlotPosition, hasPages, hasParent, isClosed, isUnlocked
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Container
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:455`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
