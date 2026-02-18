# Server Architecture

## Bootstrap server

Fluxo central em `crystalserver/src/crystalserver.cpp` (`CrystalServer::run`):

1. Carregar `config.lua`.
2. Inicializar conexão de banco (`Database::connect`, `DatabaseManager`).
3. Inicializar ambiente Lua.
4. Carregar assets/XML/scripts (vocations, events.xml, outfits, familiars, imbuements, items, scripts core/datapack).
5. Carregar mapa e entrar em estado de jogo `GAME_STATE_NORMAL`.
6. Inicializar serviços de rede (`ProtocolGame`, `ProtocolLogin`, `ProtocolStatus`) via `ServiceManager`.

## Domínios internos

- `src/game/`: regras de jogo, estado global e integração entre subsistemas.
- `src/creatures/`: players, monsters, npcs, combate e componentes de aparência.
- `src/items/`: objetos, containers, decay, armas e parsing.
- `src/lua/`: ponte C++ ⇄ Lua para funções, callbacks e carregamento de scripts.
- `src/server/network/`: protocolos e serialização de mensagens.
- `src/io/`: operações de leitura/escrita em banco por domínio.
- `src/database/`: conexão, transações e tarefas assíncronas.

## Modelo de extensão

- Eventos e callbacks Lua (CreatureEvent, MoveEvent, GlobalEvent, EventCallback, etc.).
- Sistema de módulos XML + hooks de `g_modules().executeOnRecvbyte` no parser de protocolo.
- RevScriptSys (`data/libs/functions/revscriptsys.lua`) para binding declarativo de callbacks.
