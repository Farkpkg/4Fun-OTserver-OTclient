# Packet Structure

## Estrutura geral

1. Cabeçalho/length (camada de mensagem da conexão).
2. Byte de opcode.
3. Payload específico por opcode.

## No servidor

- Entrada: `ProtocolGame::parsePacket` lê `recvbyte`.
- Roteamento: `parsePacketFromDispatcher` executa switch para handler por opcode.
- Módulos custom podem interceptar via `g_modules().executeOnRecvbyte`.

## No cliente

- Entrada: `ProtocolGame::parseMessage`.
- Roteamento por `switch` com enums `GameServerOpcodes`.
- Extended opcode chama `parseExtendedOpcode` e repassa a Lua.

## Padrões de payload observados

- Coordenadas: `Position` (x, y, z).
- Itens: `(itemId, subtype/count, atributos condicionais)`.
- Criaturas: `(creatureId, type, health/speed/outfit/light/etc.)`.
- Textos/eventos: strings UTF-8 + tipos/flags auxiliares.
