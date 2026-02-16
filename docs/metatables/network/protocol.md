---
title: Protocol
tags: [metatables]
date: 2026-02-16
---

# Protocol

- **Tipo:** C++ userdata binding
- **Categoria:** network
<<<<<<< HEAD
- **Localização:** otclient/src/framework/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: connect, disconnect, enableChecksum, enableXteaEncryption, enabledSequencedPackets, generateXteaKey, getConnection, getXteaKey, isConnected, isConnecting, recv, send, setConnection, setXteaKey
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Protocol`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:1016`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
=======
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: connect, create, disconnect, enableChecksum, enableXteaEncryption, enabledSequencedPackets, generateXteaKey, getConnection, getXteaKey, isConnected, isConnecting, recv, send, setConnection, setXteaKey
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Protocol
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/framework/luafunctions.cpp:1016`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
