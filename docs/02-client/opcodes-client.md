# Opcodes Client (Client → Server)

Fonte canônica client-side:

- `otclient/src/client/protocolcodes.h` (`enum ClientOpcodes`)
- envio real por `otclient/src/client/protocolgamesend.cpp`

## Transporte extended opcode

- `Proto::ClientExtendedOpcode = 50`
- Método de envio: `ProtocolGame::sendExtendedOpcode(uint8_t opcode, const std::string& buffer)`

## Opcodes relevantes observados no server parser

Mapeamento tratado por `ProtocolGame::parsePacketFromDispatcher` no server (`crystalserver/src/server/network/protocol/protocolgame.cpp`):

- `0x14` logout
- `0x1D` ping back
- `0x1E` ping
- `0x32` extended opcode
- `0x64-0x6D` movimento/autowalk
- `0x78` throw item
- `0x7D-0x80` trade
- `0x96` chat/message route
- demais opcodes seguem handlers específicos no mesmo switch.

## Observação de governança

Para alterações de opcode:

1. atualizar enum client,
2. atualizar parser server,
3. atualizar documentação em `05-protocol/`.
