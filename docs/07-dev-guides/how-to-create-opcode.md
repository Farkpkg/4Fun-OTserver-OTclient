# How to Create a New Opcode

## Opcodes padrão (binário)

1. Adicionar valor no enum correspondente (client/server).
2. Implementar parser no lado receptor.
3. Implementar sender no lado emissor.
4. Garantir compatibilidade de versão/features.

## Extended opcode (recomendado para extensão)

1. Reservar ID lógico único (evitar colisão com IDs existentes).
2. Client:
   - registrar callback (`ProtocolGame.registerExtendedOpcode`),
   - enviar payload (`sendExtendedOpcode`).
3. Server:
   - tratar em `CreatureEvent.onExtendedOpcode`,
   - validar payload,
   - responder opcionalmente com `Player:sendExtendedOpcode`.
4. Atualizar documentação de contrato de payload.
