# Contrato de protocolo e máquina de estados — Task Board (fase 1)

## 1) Pacotes server -> client

### `GameServerTaskHuntingBasicData` (opcode 186)
Payload:
1. `u16 preysCount`
2. loop `preysCount`: `u16 raceId`, `u8 difficult`
3. `u8 optionsCount`
4. loop `optionsCount`:
   - `u8 difficult`
   - `u8 stars`
   - `u16 firstKill`
   - `u16 firstReward`
   - `u16 secondKill`
   - `u16 secondReward`

### `GameServerTaskHuntingData` (opcode 187)
Payload base:
1. `u8 slot`
2. `u8 state`
3. payload variável por estado
4. `u32 nextFreeReroll`

Estados:
- `LOCKED`: `u8 taskSlotUnlocked`
- `INACTIVE`: vazio
- `SELECTION`: `u16 creatures` + lista (`u16 raceId`, `u8 isUnlocked`)
- `LIST_SELECTION`: igual ao selection
- `ACTIVE`: `u16 raceId`, `u8 upgraded`, `u16 requiredKills`, `u16 currentKills`, `u8 stars`
- `COMPLETED`: `u16 raceId`, `u8 upgraded`, `u16 requiredKills`, `u16 currentKills`, `u8 stars`

## 2) Pacote client -> server

### `ClientTaskHuntingAction` (opcode 0xBA / 186)
Payload:
1. `u8 slot`
2. `u8 action`
3. `u8 upgradeFlag`
4. `u16 raceId`

Ações suportadas:
- 0 list reroll
- 1 rewards reroll
- 2 list all (cards)
- 3 monster selection
- 4 cancel
- 5 claim

## 3) Máquina de estado por slot (resumo)

```text
LOCKED
  -> (unlock condição server) -> SELECTION

SELECTION
  -> action monsterSelection -> ACTIVE
  -> action listAllCards -> LIST_SELECTION
  -> action listReroll -> SELECTION

LIST_SELECTION
  -> action monsterSelection -> ACTIVE

ACTIVE
  -> kill progress >= target -> COMPLETED
  -> action cancel -> SELECTION

COMPLETED
  -> action claim -> INACTIVE -> (após cooldown) -> SELECTION
```

## 4) Regras de consistência
1. Cliente nunca deve avançar estado local por predição forte.
2. Todo refresh visual deve vir do pacote 187 subsequente.
3. Ação deve ser bloqueada na UI quando estado não compatível, mas server ainda valida tudo.

## 5) Compatibilidade
- Se servidor antigo não enviar dados de Task Hunting, módulo Task Board deve permanecer oculto ou em modo indisponível.
- Se cliente antigo não enviar 0xBA, server continua estável (sem feature ativa do lado cliente).
