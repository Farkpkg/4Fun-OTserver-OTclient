---
alwaysApply: true
---
# Guia de VIP List

## Escopo

Este guia cobre a lista de VIPs em `modules/game_viplist`.

## Arquivos principais

- `modules/game_viplist/viplist.lua`
- `modules/game_viplist/viplist.otui`
- `modules/game_viplist/addvip.otui`

## Onde editar

- Logica e ordenacao: `viplist.lua`.
- Layout: `viplist.otui` e `addvip.otui`.

## Relacionados (C++)

- `src/client/game.cpp` (processVipAdd/processVipStateChange).
- `src/client/state.md` (eventos de VIP).
