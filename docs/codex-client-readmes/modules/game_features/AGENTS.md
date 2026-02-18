---
alwaysApply: true
---
# Guia de Game Features (Lua)

## Escopo

Este guia cobre as flags de features do jogo em `modules/game_features`. Elas controlam variacoes de protocolo e comportamento do client.

## Arquivos relevantes

- `features.lua`: definicao e habilitacao de features.

## Relacoes

- Flags em C++: `src/client/const.h` (Otc::GameFeature).
- Usado por: `src/client/network.md`, `src/client/protocolgame*`.

## Onde editar

- Ajuste/novas features no Lua aqui.
- Implementacao real em C++ (parse/send, estados, UI).
