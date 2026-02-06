---
alwaysApply: true
---
# Guia do Gamelib (Lua base do jogo)

## Escopo

Este guia cobre a base Lua do jogo em `modules/gamelib`. Use junto com o C++ em `src/client/AGENTS.md` e `src/client/network.md`.

## Arquivos relevantes

- `const.lua`: enums e constantes do jogo.
- `game.lua`: wrappers e hooks de `g_game`.
- `protocollogin.lua`: fluxo de login por protocolo.
- `game.lua`: lista de clientes suportados e mapeamento de protocolo.
- `game.lua`: escolha de RSA e ajustes por host/version.
 - `protocollogin.lua`: parse de character list e session key.

## Onde editar

- Para ajustes de API/estado: C++ em `src/client`.
- Para comportamento de UI/uso: Lua aqui em `modules/gamelib`.
- Para features: `modules/game_features/AGENTS.md`.
