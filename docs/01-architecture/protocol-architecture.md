# Protocol Architecture

## Canais de comunicação

## Login channel

- Handshake e autenticação por `ProtocolLogin` (`crystalserver/src/server/network/protocol/protocollogin.*`).
- Entrega lista de personagens/mundos e dados de sessão.

## Game channel

- Sessão de jogo por `ProtocolGame` em server/client.
- Recepção de pacotes do cliente via `ProtocolGame::parsePacket` (server).
- Parsing no cliente via `ProtocolGame::parseMessage` (switch em opcodes server).

## Extended opcode

- Client envia por `ProtocolGame::sendExtendedOpcode` com opcode de transporte `ClientExtendedOpcode`.
- Server trata em `ProtocolGame::parseExtendedOpcode` e delega para `Game::parsePlayerExtendedOpcode`.
- Execução final em eventos Lua `CreatureEvent.onExtendedOpcode`.

## Feature flags de protocolo

- Flags em server (`GameFeature_t`, incluindo `ExtendedOpcode`) controlam compatibilidade.
- Cliente possui tabela de features (módulo `game_features`) e enums de protocolo em C++/Lua.
