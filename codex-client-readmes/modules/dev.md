# Development Workflow (Modules)

## Escopo

Este guia resume o fluxo de desenvolvimento de modulos Lua: descoberta, Controller pattern, auto-reload e debugging. Para build, veja `tools/build.md`.

## Descoberta e prioridade

- Modulos vivem em `modules/` e carregam por prioridade.
- Faixas sugeridas:
  - 0-99: client (infra, login, menus)
  - 100-499: game UI (interface, console, battle)
  - 500+: features e extensoes

## Estrutura basica do modulo

- `module.otmod` (metadata e autoload)
- `init.lua` (controller principal)
- `*.otui` (UI)
- `*.lua` adicionais (logica)

## Controller pattern (recomendado)

- `Controller:new()` gerencia cleanup automatico.
- Use: `self:connect`, `self:bindKeyPress`, `self:scheduleEvent`, `self:setUI`.
- Evite estado global; prefira `self.*`.
- Implementacao em `modules/modulelib/controller.lua` (ver `modules/modulelib/AGENTS.md`).

## Auto-reload

- Habilitar em `init.lua`:
  - `g_modules.enableAutoReload()`
- Recarregar no console:
  - `g_modules.reloadModule('nome')`
  - `g_modules.reloadAllModules()`

## Debug e logs

- Console Lua: `Ctrl+T`.
- Logs: `g_logger.trace/debug/info/warning/error/fatal`.
- FPS/ping: `g_app.getFps()`, `g_game.getPing()`.

## Boas praticas

- Manter dependencias de modulo minimas.
- Evitar referencias a widgets destruídos apos reload.
- Validar dados antes de atualizar UI.

## Onde editar

- UI base: `modules/game_interface/AGENTS.md`.
- Binds C++/Lua: `src/framework/luaengine/AGENTS.md`.
- Protocolos: `src/client/network.md`.
