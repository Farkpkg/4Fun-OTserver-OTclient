---
alwaysApply: true
---
# Guia de Minimap

## Escopo

Este guia cobre o minimapa em `modules/game_minimap`.

## Arquivos principais

- `modules/game_minimap/minimap.lua`
- `modules/game_minimap/minimap.otui`

## Onde editar

- Logica de zoom/floor/compass: `minimap.lua`.
- Layout/estilos: `minimap.otui`.

## Relacionados (C++)

- `src/client/map.h` e `src/client/mapview.h` (estado do mundo e visibilidade).
- `src/client/uimap.h` (widget de mapa no client).
- `src/client/world.md` (visao geral de mapa/tile).
