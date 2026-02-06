---
alwaysApply: true
---
# Guia do Modulelib (Controller)

## Escopo

Este guia cobre o `modulelib`, que fornece a classe `Controller` para ciclo de vida e cleanup automatico dos modulos.

## Papel no boot

- Carregado apos `corelib` e `gamelib` (ver `init.lua`).
- Centraliza o padrao de Controller para modulos Lua.

## Controller (resumo)

- `Controller:new()` cria instancia e registra em `G_CONTROLLER_CALLED`.
- `Controller:init()` conecta eventos e executa hooks de init.
- `onGameStart`/`onGameEnd` gerenciam eventos GAME_INIT.
- `loadHtml()` carrega UI HTML quando aplicavel.

## Ciclo de vida (resumo)

1. `Controller:init()`:
   - carrega UI (se `dataUI` existir);
   - executa hooks `MODULE_INIT`;
   - conecta `g_game.onGameStart/onGameEnd`.
2. `onGameStart()`:
   - ativa eventos `GAME_INIT`;
   - conecta eventos do jogo.
3. `onGameEnd()`:
   - limpa eventos `GAME_INIT` e scheduled events;
   - destrói UI se aplicável;
   - remove binds de teclado do tipo GAME_INIT.

## Boas praticas

- Usar `self:*` para estado e evitar globals.
- Preferir `loadHtml()`/`setUI()` do Controller ao criar UI.
- Sempre limpar recursos no fluxo de `onGameEnd` quando necessário.

## Tipos de evento

- `MODULE_INIT`: eventos na inicializacao do modulo.
- `GAME_INIT`: eventos no inicio do jogo.

## Onde editar

- `modules/modulelib/controller.lua`.

## Relacionados

- `src/framework/luaengine/AGENTS.md` (bindings e fluxo Lua/C++).
- `src/framework/ui/AGENTS.md` (base de UI usada pelo Controller).
- `init.lua` (ordem de carregamento).
