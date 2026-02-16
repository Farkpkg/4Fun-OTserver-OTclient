---
title: Uiitem
tags: [metatables]
date: 2026-02-16
---

# UIItem

- **Tipo:** C++ userdata binding
- **Categoria:** ui
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: clearItem, getFlipDirection, getItem, getItemCount, getItemCountOrSubType, getItemId, getItemSubType, isItemVisible, isVirtual, setFlipDirection, setItem, setItemCount, setItemId, setItemSubType, setItemVisible, setShowCount, setVirtual
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIItem -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1047`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: clearItem, create, getFlipDirection, getItem, getItemCount, getItemCountOrSubType, getItemId, getItemSubType, isItemVisible, isVirtual, setFlipDirection, setItem, setItemCount, setItemId, setItemSubType, setItemVisible, setShowCount, setVirtual
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: UIItem -> UIWidget
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:1047`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
