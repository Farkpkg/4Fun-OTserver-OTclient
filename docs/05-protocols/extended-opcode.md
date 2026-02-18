# Extended Opcode (Client ↔ Server)

## Descrição
Extended Opcode é o canal de mensagens customizadas sobre o protocolo de jogo. O opcode de transporte é `50` em ambos os lados, e o payload funcional é um sub-opcode (0-255) com string.

## Localização no Projeto
- client/
  - `otclient/src/client/protocolcodes.h`
  - `otclient/src/client/protocolgameparse.cpp`
  - `otclient/src/client/protocolgamesend.cpp`
  - `otclient/modules/gamelib/protocolgame.lua`
- server/
  - `crystalserver/src/server/network/protocol/protocolgame.cpp`
  - `crystalserver/src/game/game.cpp`
  - `crystalserver/src/lua/creature/creatureevent.cpp`

## Arquivos Envolvidos
- `otclient/src/client/protocolcodes.h`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/modules/gamelib/protocolgame.lua`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`

## Fluxo de Execução
1. O cliente só envia extended opcode após habilitação (`opcode == 0` recebido em `parseExtendedOpcode`).
2. O envio no client usa pacote `ClientExtendedOpcode` (50), seguido por sub-opcode e string.
3. O server recebe em `ProtocolGame::parseExtendedOpcode` e delega para `Game::parsePlayerExtendedOpcode`.
4. O game loop executa todos `CreatureEvent` do tipo `extendedopcode` para o jogador.
5. O script Lua decide qual sub-opcode tratar.

## Dependências
- Handshake de feature (`sendFeatures` com `GameFeature_t::ExtendedOpcode`).
- Registro Lua via `ProtocolGame.registerExtendedOpcode` (client).
- Registro Lua via `CreatureEvent("ExtendedOpcode")` (server).

## Pontos de Extensão
- Definir tabela de sub-opcodes compartilhada em arquivo único para evitar colisão.
- Usar `registerExtendedJSONOpcode` no client para payloads grandes/fragmentados.
- Aplicar validação de payload no server antes de executar regras de negócio.
