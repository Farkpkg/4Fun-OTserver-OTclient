---
alwaysApply: true
---
# Guia de Battle List e Creature Tracking

## Escopo

Este guia cobre o sistema de battle list em `modules/game_battle`: tracking de criaturas, filtros, sort e eventos.

## Arquivos principais

- `modules/game_battle/battle.lua`
- `modules/game_battle/battle.otui`
- `modules/game_battle/battlebutton.otui`

## Componentes

- `BattleListManager`: cria/restaura instancias e persiste settings.
- `BattleListInstance`: lista por janela, filtros e sorting.
- `BattleButtonPool`: pool de widgets para performance.

## Eventos e callbacks

- `onCreatureAppear`, `onCreatureDisappear`, `onCreatureHealthChange`.
- Atualiza instancias visiveis e seus buttons.

## Onde editar

- Logica: `battle.lua` (filtros, sorting, eventos, persistencia).
- UI: `battle.otui` e `battlebutton.otui`.

## Relacionados (C++)

- `src/client/creatures.md` (estado, stats e callbacks de criatura).
- `src/client/world.md` (mapa/spectators usados pelo tracking).
- `src/client/state.md` (eventos e sinais do `g_game`).
