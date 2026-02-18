---
alwaysApply: true
---
# Guia de Client (Game, Protocol, Callbacks)

## Escopo

Este guia cobre a camada de cliente em `src/client/`: Game, protocolo, parsing, callbacks para Lua e integracao com o mapa.

## Subguias

- `src/client/world.md`: map, tile, thing e entidades.
- `src/client/rendering.md`: mapview, lighting, thingtype.
- `src/client/creatures.md`: creature lifecycle, movimento e animacao.
- `src/client/assets.md`: thing types, sprites e carregamento.
- `src/client/effects.md`: attached effects, shaders e particulas.
- `src/client/network.md`: protocolo, parse/send e fluxo de mensagens.
- `src/client/state.md`: sincronizacao de estado e callbacks.

## Arquivos principais

- `game.*`: estado central do jogo e callbacks.
- `protocolgame.*`, `protocolgameparse.*`, `protocolgamesend.*`: comunicacao com servidor.
- `map.*`, `tile.*`, `creature.*`: mundo e entidades.
- `luafunctions.cpp`: bindings do lado do client.

## Callbacks C++ -> Lua (g_game)

- `processLogin()` -> `g_game.onLogin()`
- `processGameStart()` -> `g_game.onGameStart()`
- `processGameEnd()` -> `g_game.onGameEnd()`
- `processTalk(...)` -> `g_game.onTalk(...)`
- `walk(direction)` -> `g_game.onWalk(direction)`
- `processDeath(...)` -> `g_game.onDeath(...)`

## Opcode callbacks (Lua intercepta parser)

- `ProtocolGame::parseMessage()` tenta `onOpcode` em Lua antes do switch C++.
- Se Lua retornar `true`, a mensagem e considerada tratada.

## Padrao de fluxo (exemplo talk)

1. `protocolgameparse.cpp` recebe opcode e chama `parseTalk()`.
2. `game.cpp` processa e chama `g_lua.callGlobalField("g_game", "onTalk", ...)`.
3. Modulos Lua reagem e atualizam UI.

## Dicas

- Sempre validar estado do jogo antes de disparar callbacks.
- Evitar callbacks excessivos em hot path; prefira batch.
