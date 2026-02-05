# Custom Protocols Documentation

## Regras Gerais
- Opcode >= 200
- Nunca reutilizar opcode
- Toda alteração deve ser documentada aqui

---

## Exemplo de Protocolo

### Opcode 200 – Player Prestige

Direção:
- Server → Client

Estrutura do Pacote:
- uint8 opcode
- uint16 prestigeLevel
- uint64 prestigeExperience

Fluxo:
1. Server calcula prestígio
2. Server envia pacote
3. Client atualiza UI

Implementação:
- Server: protocolgame.cpp (sendExtendedOpcode)
- Client: protocolgame.cpp (parseExtendedOpcode)

---

## Observações
- Mudanças em protocolos exigem:
  - Alteração no server
  - Alteração no client
  - Atualização deste arquivo
