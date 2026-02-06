---
alwaysApply: true
---
# Guia de Input (Mouse)

## Escopo

Este guia cobre entrada de baixo nivel no framework, com foco em mouse.

## Arquivos principais

- `src/framework/input/mouse.h`
- `src/framework/input/mouse.cpp`

## Fluxo geral

- Eventos de janela chegam via `PlatformWindow`.
- Input e convertido e repassado ao framework/UI.
- `g_mouse` exposto para Lua via bindings do framework.

## Onde editar

- `mouse.*` para logica de cursor, posicao e eventos.

## Relacionados

- `src/framework/platform/AGENTS.md` (janela/plataforma).
- `src/framework/ui/AGENTS.md` (roteamento de eventos na UI).
- `modules/game_hotkeys/AGENTS.md` e `modules/corelib/keybind.lua`.
