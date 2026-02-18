---
alwaysApply: true
---
# Guia de Inventory Panel

## Escopo

Este guia cobre o painel de inventario e slots em `modules/game_inventory`.

## Arquivos principais

- `modules/game_inventory/inventory.lua`
- `modules/game_inventory/inventory.otui`

## Onde editar

- Logica de slots/combate: `inventory.lua`.
- Layout/estilos: `inventory.otui`.

## Relacionados (C++)

- `src/client/const.h` (InventorySlot* e enums).
- `src/client/localplayer.h` (inventario do jogador).
- `src/client/game.cpp` (processInventoryChange).
