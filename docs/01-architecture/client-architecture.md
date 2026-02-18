# Client Architecture

## Bootstrap

1. `otclient/src/main.cpp`
   - Inicializa plataforma e recursos.
   - Descobre diretório de trabalho contendo `init.lua`.
   - Inicializa `g_app`, `g_client`, Lua e executa `init.lua`.

2. `otclient/init.lua`
   - Configura nome da aplicação, search paths, configs e pacotes.
   - Chama `g_modules.discoverModules()`.
   - Auto-carrega módulos por prioridade e força carga de `corelib`, `gamelib`, `modulelib`, `startup`, `client` e `game_interface`.

## Sistema de módulos

- Definição por arquivos `.otmod` em `otclient/modules/*/*.otmod`.
- Gestão em C++ por `framework/core/modulemanager.*` e `framework/core/module.*`.
- Recursos:
  - dependências (`dependencies`)
  - ordem por prioridade (`autoload-priority`)
  - carga tardia (`load-later`)
  - sandbox Lua por módulo.

## Runtime de jogo

- Camada de protocolo: `otclient/src/client/protocolgame*.cpp`.
- Camada de estado local: `otclient/src/client/game.*`, `map.*`, `creature.*`, `item.*`.
- UI de jogo modularizada em `otclient/modules/game_*`.

## Dependências arquiteturais críticas

- `gamelib` centraliza constantes/protocolo Lua consumidos pelos módulos de interface.
- `modulelib/controller.lua` encapsula registro de eventos/opcodes para módulos customizados.
- `client_locales` depende de extended opcode para sincronização de idioma com server.
