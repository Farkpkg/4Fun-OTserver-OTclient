---
alwaysApply: true
---
# Guia do Game Console (Chat)

## Escopo

Este guia cobre o sistema de chat/tab do console em `modules/game_console`. Para UI base, veja `src/framework/ui/AGENTS.md` e `modules/game_interface/AGENTS.md`.

## Arquivos principais

- `modules/game_console/console.lua`
- `modules/game_console/console.otui`
- `modules/game_console/channelswindow.otui`
- `modules/game_console/communicationwindow.otui`
- `modules/corelib/ui/uimovabletabbar.lua`

## Sistemas chave

- Tabs de chat (default, server, canais, privado, NPC).
- Routing de mensagens por `MessageModes`.
- Input e historico de mensagens.
- Modo chat/wasd e keybinds.
- Read-only panel e filtros (ignore/whitelist).
- Context menus e hooks por modulo.

## Onde editar

- Logica e handlers: `console.lua`.
- Layout/estilos: `console.otui` e `data/styles/20-tabbars.otui`.
- Tab bar: `modules/corelib/ui/uimovabletabbar.lua`.
