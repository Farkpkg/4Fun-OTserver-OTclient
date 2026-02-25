# Contrato de Protocolo e Estados — Task Board (isolada)

## 1) Princípios
- Opcodes exclusivos de Task Board.
- Sem reaproveitar payloads de Prey.
- Snapshot inicial + updates incrementais.

## 2) Pacotes sugeridos (nomes conceituais)
### Client -> Server
- `ClientTaskBoardOpen`
- `ClientTaskBoardBountyAction`
- `ClientTaskBoardWeeklyAction`
- `ClientTaskBoardShopAction`
- `ClientTaskBoardPreferredAction`

### Server -> Client
- `GameServerTaskBoardOpen`
- `GameServerTaskBoardBountyData`
- `GameServerTaskBoardWeeklyData`
- `GameServerTaskBoardShopData`
- `GameServerTaskBoardCurrencyData`
- `GameServerTaskBoardError`

## 3) Máquina de estados Bounty (slot)
```text
LOCKED -> AVAILABLE -> SELECTED -> COMPLETED -> CLAIMED -> COOLDOWN -> AVAILABLE
```

## 4) Weekly states
```text
INACTIVE -> ACTIVE -> COMPLETED -> REWARDED -> EXPIRED(weekly reset)
```

## 5) Regras de consistência
1. Cliente não decide transição final de estado.
2. Toda transição vem confirmada por pacote do server.
3. Compra/claim só efetiva após ACK do server.

## 6) Compatibilidade
- Feature flag `GameTaskBoard`.
- Cliente sem suporte: ignora/opta por ocultar entrada de UI.
