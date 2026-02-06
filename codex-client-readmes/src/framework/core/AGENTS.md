---
alwaysApply: true
---
# Guia de Framework Core (Eventos, Recursos, Config)

## Escopo

Este guia cobre o core do framework: eventos/dispatcher, recursos (PhysFS), configuracao, modulos e utilitarios base.

## Componentes principais

- Event dispatcher: `eventdispatcher.*`, `asyncdispatcher.*`, `event.*`, `scheduledevent.*`.
- Recursos: `resourcemanager.*`, `filestream.*`, `unzipper.*`.
- Configuracao: `config.*`, `configmanager.*` (singleton `g_configs`).
- Modulos: `module.*`, `modulemanager.*` (singleton `g_modules`).
- Utilitarios: `clock.*`, `timer.*`, `logger.*`.

## Eventos e dispatcher

- `g_dispatcher` processa fila de eventos no loop principal.
- `addEvent`, `scheduleEvent`, `cycleEvent` para callbacks temporizados.
- `asyncdispatcher` gerencia execucao assincrona quando necessario.

## Recursos (ResourceManager)

- `g_resources` monta o FS virtual (PhysFS) e define search paths.
- `discoverWorkDir()` localiza `init.lua` e define o workdir.
- Suporta arquivos compactados (zip/otpkg) e lookup por path logico.

## Config e settings

- `g_configs` carrega configs `.otml` e fornece `Config`.
- Em Lua, `g_settings` vem de `modules/corelib/settings.lua`.
- Settings sao persistidos em `config.otml` via `g_settings`.

## Modulos

- `g_modules` descobre e autoload de `modules/`.
- Ordem e dependencias via `module.otmod`.
- Auto-reload controlado por `g_modules.enableAutoReload()`.

## Onde editar

- Eventos: `src/framework/core/eventdispatcher.*`, `src/framework/core/scheduledevent.*`.
- Recursos: `src/framework/core/resourcemanager.*`, `src/framework/core/filestream.*`.
- Config: `src/framework/core/configmanager.*`, `src/framework/core/config.*`.
- Modulos: `src/framework/core/modulemanager.*`, `src/framework/core/module.*`.

## Relacionados

- `src/framework/AGENTS.md` (visao geral do framework).
- `src/framework/luaengine/AGENTS.md` (bindings de `g_modules`, `g_configs`).
- `modules/corelib/AGENTS.md` e `modules/corelib/settings.lua`.
