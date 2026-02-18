---
alwaysApply: true
---
# Guia de Platform Layer

## Escopo

Este guia cobre a camada de plataforma: janelas, contexto GL, input nativo e crash handlers.

## Componentes principais

- `platformwindow.*`: interface base de janela.
- `win32window.*`, `x11window.*`, `androidwindow.*`, `browserwindow.*`.
- `platform.*`: selecao da implementacao por `#ifdef`.
- Crash handlers: `win32crashhandler.*`, `unixcrashhandler.*`.

## Fluxo geral

- `g_window` aponta para a implementacao da plataforma ativa.
- Eventos nativos sao traduzidos e repassados ao framework/UI.
- Contexto GL (WGL/GLX/EGL) e swap buffers sao gerenciados aqui.

## Onde editar

- Windows: `src/framework/platform/win32window.*`, `src/framework/platform/win32platform.*`.
- Linux: `src/framework/platform/x11window.*`, `src/framework/platform/unixplatform.*`.
- Android: `src/framework/platform/androidwindow.*`.
- Browser/WASM: `src/framework/platform/browserwindow.*`.

## Relacionados

- `src/framework/input/AGENTS.md`.
- `src/framework/AGENTS.md`.
- `src/framework/graphics/AGENTS.md`.
