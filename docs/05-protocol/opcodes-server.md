# Opcodes Server (Server → Client)

## Fontes canônicas

- Client enum de recepção: `otclient/src/client/protocolcodes.h` (`GameServerOpcodes`).
- Client parser: `otclient/src/client/protocolgameparse.cpp` (`parseMessage` switch).
- Server envio: `crystalserver/src/server/network/protocol/protocolgame.cpp` (`send*` methods).

## Faixas relevantes observadas

- `0x0A-0x1F`: login/session/ping e estados iniciais.
- `0x32`: extended opcode (GameServerExtendedOpcode).
- `0x64+`: stream de jogo (mapa, criatura, inventário, chat, trackers, sistemas).

## Exemplos de mapeamento verificável

- `GameServerExtendedOpcode = 50` (client enum) ↔ parse de extended opcode no client.
- `GameServerOpenContainer = 110`, `GameServerChangeInContainer = 113`, `GameServerDeleteInContainer = 114`.
- `GameServerPlayerData = 160`, `GameServerPlayerSkills = 161`, `GameServerPlayerState = 162`.

## Governança

Qualquer opcode novo deve atualizar simultaneamente:

1. Enum/parse no client.
2. Handler send/parse no server.
3. Documentação em `02-client/opcodes-client.md`, `05-protocol/opcodes-server.md` e `05-protocol/packet-structure.md`.
