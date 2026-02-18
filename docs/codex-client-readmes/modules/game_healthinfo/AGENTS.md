---
alwaysApply: true
---
# Guia de Health/Mana Panel

## Escopo

Este guia cobre barras de vida/mana em `modules/game_healthinfo`.

## Arquivos principais

- `modules/game_healthinfo/healthinfo.lua`
- `modules/game_healthinfo/healthinfo.otui`

## Onde editar

- Logica de barras: `healthinfo.lua`.
- Layout: `healthinfo.otui`.

## Relacionados (C++)

- `src/client/creature.h` (vida/mana e eventos).
- `src/client/localplayer.h` (dados do jogador local).
- `src/client/state.md` (process* e callbacks de stats).
