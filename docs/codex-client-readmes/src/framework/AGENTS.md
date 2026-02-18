---
alwaysApply: true
---
# Guia do Framework (Core, UI, Graphics, Lua, Platform)

## Escopo

Este guia cobre os sistemas de framework em `src/framework/`: ciclo de vida da aplicacao, renderizacao, UI, Lua, recursos e abstracao de plataforma.

## Visao Geral

- O framework e modular e multiplataforma.
- Usa C++20/23 e integra bibliotecas como LuaJIT, PhysFS, OpenGL/DirectX, ASIO.
- Este guia descreve os blocos base; sistemas de jogo ficam em `src/AGENTS.md`.

## Camadas e classes principais

- Application: `core/application.h`, `core/graphicalapplication.h`, `core/eventdispatcher.h`.
- Scripting: `core/modulemanager.h`, `luaengine/luainterface.h`.
- UI: `ui/uimanager.h`, `ui/uiwidget.h`, `ui/uilayout.h`.
- Graphics: `graphics/drawpoolmanager.h`, `graphics/painter.h`, `graphics/texturemanager.h`.
- Platform: `platform/platformwindow.h`, `core/resourcemanager.h`, `graphics/graphics.h`.

## Singletons globais (g_*)

- `g_app`: Application.
- `g_window`: PlatformWindow.
- `g_graphics`: Graphics.
- `g_painter`: Painter.
- `g_drawPool`: DrawPoolManager.
- `g_textures`: TextureManager.
- `g_ui`: UIManager.
- `g_lua`: LuaInterface.
- `g_resources`: ResourceManager.
- `g_modules`: ModuleManager.
- `g_dispatcher`: EventDispatcher.

## Pipeline e renderizacao

- Batching via DrawPool (draw pools por camada: MAP, LIGHT, FOREGROUND, etc.).
- Painter aplica comandos e apresenta o frame.
 - Detalhes completos em `src/framework/graphics/AGENTS.md`.

## Application Lifecycle e Entry Point

- Entry point varia por plataforma:
  - Desktop: `src/main.cpp` (main/WinMain conforme build).
  - Android: `androidmain.cpp` via `src/CMakeLists.txt`.
  - WASM: entry do Emscripten via flags em `src/CMakeLists.txt`.
- Definicoes comuns: `CLIENT`, `FRAMEWORK_GRAPHICS`, `FRAMEWORK_SOUND`, `FRAMEWORK_NET` (ver `src/CMakeLists.txt`).

## Sequencia de inicializacao (alto nivel)

- Instala crash handler (win32/unix).
- Inicializa `g_app`, logger, plataforma e dispatcher.
- Inicializa recursos (PhysFS, search paths, archives).
- Se grafico: janela + contexto GL/DX + draw pool/textures.
- Carrega modulos e executa `init.lua`.

## Main loop (g_app.run)

- `g_window.poll()` -> eventos de janela/input.
- `g_dispatcher.poll()` -> eventos e timers.
- `g_drawPool.draw()` -> flush de comandos.
- `g_window.swapBuffers()` -> apresenta frame.

## Threading (alto nivel)

- Main thread: input, audio, submit de GPU.
- Thread 2: rede, dispatcher, coleta de draw do mapa.
- Thread 3: coleta de draw de UI.

## Encerramento

- Termina modulos em ordem reversa.
- Limpa draw/GL/DX e janela.
- Encerra dispatcher/threads.
- Libera recursos e plataforma.

## Crash handling

- Win32: SEH e stack trace em `win32crashhandler.cpp`.
- Unix: signal handlers e backtrace em `unixcrashhandler.cpp`.
- Relatorio inclui build info e stack trace.

## Argumentos e configuracao

- Args chegam em `Application::init(args)` e controlam modulos/config/debug.
- Flags de build e configuracoes ficam em `src/framework/config.h` e `CMakeLists.txt`.

## UI Framework

- Widgets com hierarquia, layouts e estilos.
- Layouts: anchor, box, grid, flexbox (`uianchorlayout.h`, `uiboxlayout.h`, `uigridlayout.h`, `uilayoutflexbox.h`).
- Estilos via OTML e suporte a HTML/CSS.
 - Detalhes completos em `src/framework/ui/AGENTS.md`.

## Platform Abstraction Layer

- Abstracao de janela e contexto GL por `PlatformWindow`.
- Implementacoes: `win32window.*`, `x11window.*`, `androidwindow.*`, `browserwindow.*`.
- `g_window` aponta para a implementacao da plataforma (selecionada via `#ifdef`).

## Window + OpenGL Context

- Windows: WGL (desktop) ou EGL (OpenGL ES).
- Linux: GLX (desktop) ou EGL (OpenGL ES).
- Responsavel por criar janela, contexto GL e swap buffers.

## Graphics init

- `Graphics::init()` coleta info de GPU, inicia GLEW (desktop), habilita blend e inicializa `g_textures`/`g_painter`.

## Input e eventos

- Eventos de teclado/mouse sao traduzidos pela camada de janela e repassados ao framework.

## Graphics Rendering Pipeline (DrawPool)

- Pipeline baseado em DrawPool com batching por estado e deduplicacao por hash.
- Pools especializados (MAP, LIGHT, FOREGROUND, CREATURE_INFORMATION, etc.) coordenados por `DrawPoolManager`.
- Double-buffering e atomicos para sincronizacao entre coleta (game/UI) e render.
- TextureAtlas reduz bind de texturas via packing.
- Framebuffer caching para pools que nao precisam redesenhar todo frame.

## Lua e eventos

- Bindings em `luafunctions.cpp`.
- Eventos via `EventDispatcher`: `addEvent`, `scheduleEvent`, `cycleEvent`, `removeEvent`.
- Detalhes completos em `src/framework/luaengine/AGENTS.md`.

## Recursos e configuracao

- `ResourceManager` centraliza FS virtual (PhysFS) e carregamento.

## Referencias locais

- `src/framework/core`
- `src/framework/core/AGENTS.md`
- `src/framework/graphics`
- `src/framework/ui`
- `src/framework/input/AGENTS.md`
- `src/framework/sound/AGENTS.md`
- `src/framework/luaengine`
- `src/framework/net`
- `src/framework/platform/AGENTS.md`
