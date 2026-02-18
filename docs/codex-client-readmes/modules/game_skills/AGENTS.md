---
alwaysApply: true
---
# Guia de Skills Panel

## Escopo

Este guia cobre o painel de skills em `modules/game_skills`.

## Arquivos principais

- `modules/game_skills/skills.lua`
- `modules/game_skills/skills.otui`

## Onde editar

- Logica e eventos: `skills.lua`.
- Layout/estilos: `skills.otui` e `data/styles/10-progressbars.otui`.

## Relacionados (C++)

- `src/client/localplayer.h` (skills/atributos).
- `src/client/game.cpp` (processPlayerStats/Skills).
- `src/client/state.md` (callbacks de stats).
