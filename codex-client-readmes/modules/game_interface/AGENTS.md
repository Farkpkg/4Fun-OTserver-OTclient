---
alwaysApply: true
---
# Guia do Game Interface (UI do jogo)

## Escopo

Este guia cobre a UI principal em `modules/game_interface`: paineis, contexto, controles e integracao com o jogo.

## Arquivos principais

- `modules/game_interface/gameinterface.lua`
- `modules/game_interface/gameinterface.otui`
 - `modules/game_interface/core.md`

## Onde editar (atalhos)

- Paineis/colunas: `gameinterface.lua` (panels e radio group).
- Mouse/menus: `gameinterface.lua` (processMouseAction, createThingMenu, hooks).
- Use-with/trade-with: `gameinterface.lua` (mouseGrabberWidget).
- Keybinds: `gameinterface.lua` (bindKeys).
- View modes: `gameinterface.lua` (setupViewMode, mobile config).
 - Fluxo de inicio: `modules/game_interface/core.md`.

## Sistemas principais

- Paineis e colunas (radio group + toggle de visibilidade).
- Context menus com hooks (`addMenuHook`).
- Modos de controle (regular/classic/smart click).
- Adaptacoes mobile via `g_platform.isMobile()`.
- Use-with/trade-with via mouse grabber.
- Keybinds globais (zoom, logout, limpar textos).
- View modes (normal/compact/mobile).
- Integra battle list e tracking via `modules/game_battle/AGENTS.md`.

## Onde editar

- Logica: `gameinterface.lua`.
- Layout e widgets: `gameinterface.otui`.
- Integracao com jogo: callbacks de `g_game`.
 - Strings: `data/locales/*.lua` via `tr()`.

## Referencias

- UI C++: `src/framework/ui/AGENTS.md`.
- Estado de jogo: `src/client/state.md`.
- Locales: `data/locales/AGENTS.md`.
