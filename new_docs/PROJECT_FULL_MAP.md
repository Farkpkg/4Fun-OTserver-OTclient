# PROJECT_FULL_MAP

## Escopo auditado
- `crystalserver/`: 8435 arquivos totais; 450 arquivos C/C++.
- `otclient/`: 3758 arquivos totais; 409 arquivos C/C++.
- Inventário completo por arquivo em:
  - `new_docs/server/FILE_MANIFEST.md`
  - `new_docs/client/FILE_MANIFEST.md`

## Árvore completa comentada
### crystalserver/
- Núcleo C++ em `src/` (gameplay, rede, DB, Lua binding, segurança).
- Conteúdo/script principal em `data/`, `data-crystal/`, `data-global/`.
- Infraestrutura e build em `cmake/`, `docker/`, `tests/`, `metrics/`.

### otclient/
- Núcleo C++ em `src/` (`framework/`, `client/`, `tools/`).
- Sistema modular Lua/UI em `modules/`.
- Assets em `data/` (otui, imagens, fontes, shaders, sons, particles).
- Build/plataforma em `cmake/`, `android/`, `browser/`, `tests/`.

## Fluxo de inicialização do server
1. `crystalserver/src/main.cpp`: executa `inject<CrystalServer>().run()`.
2. `crystalserver/src/crystalserver.cpp` (construtor): configura logger, estado inicial, dispatcher e handlers críticos.
3. `CrystalServer::run()` agenda bootstrap no dispatcher:
   - `loadConfigLua()`
   - `initializeDatabase()`
   - `loadModules()` (scripts/sistemas Lua e tabelas de jogo)
   - `setWorldType()`
   - `loadMaps()`
4. Sobe serviços de rede (`ProtocolStatus`, `ProtocolLogin`, `ProtocolGame`) e muda game state para normal.

## Fluxo de inicialização do client
1. `otclient/src/main.cpp`: processa args, inicializa plataforma e resources.
2. Descobre workdir via `init.lua`.
3. Inicializa `g_app` e `g_client`.
4. Executa `init.lua`, que carrega módulos Lua (`modules/*`) e pipeline de UI.
5. Entra no loop principal com `g_app.run()`.

## Fluxo de login
1. Client chama `Game::loginWorld` (`otclient/src/client/game.cpp`).
2. `ProtocolGame::login` monta handshake e primeiro pacote (`protocolgamesend.cpp`).
3. Server recebe em `ProtocolGame::onRecvFirstMessage` (`crystalserver/src/server/network/protocol/protocolgame.cpp`).
4. Server valida challenge/RSA/XTEA, autentica conta/personagem e instancia sessão de jogo.

## Fluxo de conexão
- Camada socket/connection no server em `crystalserver/src/server/network/connection/`.
- Primeiro pacote define protocolo (status/login/game).
- Após handshake, loop de parse por opcode em `protocolgame.cpp` (server) e `protocolgameparse.cpp` (client).

## Game loop
- Server: `Dispatcher` + `EventsScheduler` + ticks de jogo.
- Client: loop gráfico/eventos/rede em `g_app.run()`.

## Sistema de pacotes
- Server: `NetworkMessage` + handlers `Protocol*`.
- Client: `InputMessage`/`OutputMessage` + parse/send em `protocolgameparse.cpp` e `protocolgamesend.cpp`.
- Superfície detalhada em `new_docs/network/NETWORK_SURFACE_MAP.md`.

## Persistência
- Server: acesso DB em `src/database/`; repositórios/IO em `src/io/`; schema/migrations em `schema.sql` e `data/migrations/`.
- Mapa completo em `new_docs/database/DATABASE_SURFACE_MAP.md`.

## Eventos
- Server: eventos de criaturas/jogador e hooks Lua em `src/lua/` + `data/scripts/`.
- Client: eventos/sinais por módulos Lua (`connect`, callbacks de `g_game`, widgets OTUI).

## Bindings Lua
- Server: bindings centrais em `src/lua/functions/` e runtime em `src/lua/scripts/`.
- Client: bindings em `otclient/src/client/luafunctions.cpp` + `framework/luaengine`.

## UI pipeline
1. OTUI define estrutura visual (`modules/**.otui`, `data/styles/**`).
2. Lua de módulo liga eventos e estado (`modules/**.lua`).
3. Sinais de jogo alimentam widgets; ações do usuário geram chamadas `g_game`/protocol.

## Extended opcodes
- Cliente envia com `ProtocolGame::sendExtendedOpcode` (`otclient/src/client/protocolgamesend.cpp`).
- Servidor trata opcode de extended packet em `protocolgame.cpp`.
- Contratos de rede e arquivos relacionados listados em `new_docs/network/NETWORK_SURFACE_MAP.md`.
