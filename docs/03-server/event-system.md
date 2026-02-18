# Event System

## Componentes

- XML callback registry: `crystalserver/data/events/events.xml`
- RevScriptSys: `crystalserver/data/libs/functions/revscriptsys.lua`
- Base C++ de eventos Lua: `crystalserver/src/lua/creature/*`, `crystalserver/src/lua/global/*`, `crystalserver/src/lua/callbacks/*`

## Modelo de registro

- Eventos clássicos: `CreatureEvent`, `MoveEvent`, `GlobalEvent`, `Action`, `TalkAction`, `Spell`, `Weapon`.
- `revscriptsys.lua` intercepta `__newindex` e mapeia funções Lua para tipos de evento internos.

## Eventos de protocolo estendido

- `CreatureEvent.onExtendedOpcode` é registrado via RevScriptSys.
- Fluxo de execução: `ProtocolGame::parseExtendedOpcode` → `Game::parsePlayerExtendedOpcode` → `CreatureEvent::executeExtendedOpcode`.

## Diretriz de manutenção

- Scripts novos devem seguir API RevScriptSys para manter padronização e reduzir XML legada.
