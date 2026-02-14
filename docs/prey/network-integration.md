# PREY — Integração de Rede (ProtocolGame / NetworkMessage)

## Opcodes envolvidos

### Cliente OTClient (`protocolcodes.h`)
- Server -> Client:
  - `GameServerSendPreyFreeRerolls = 230`
  - `GameServerSendPreyTimeLeft = 231`
  - `GameServerSendPreyData = 232`
  - `GameServerSendPreyRerollPrice = 233`
- Client -> Server:
  - `ClientPreyAction = 235`
  - `ClientPreyRequest = 237`

### Servidor Crystal (`protocolgame.cpp`)
- `0xEB` client->server: `parsePreyAction`.
- `0xE7` server->client: prey time left.
- `0xE8` server->client: prey slot data.
- `0xE9` server->client: prey prices.
- `0xE6` server->client também aparece em outros subsistemas (bosstiary entry changed), indicando multiplex por contexto/feature.

## Handlers no cliente
`ProtocolGame::parseMessage` roteia para:
- `parsePreyFreeRerolls`
- `parsePreyTimeLeft`
- `parsePreyData`
- `parsePreyRerollPrice`

Depois chama callbacks Lua globais (`g_game.onPrey*`), consumidos por `modules/game_prey/prey.lua`.

## Estruturas de payload

### PreyTimeLeft (`0xE7`)
- `u8 slot`
- `u16 timeLeft`

### PreyData (`0xE8`)
Header comum:
- `u8 slot`
- `u8 state`

Body variável por estado:
- `LOCKED`: unlockState + tempos/wildcards
- `INACTIVE`: tempos/wildcards
- `ACTIVE`: monster(outfit) + bonusType + bonusValue + grade + timeLeft + reroll timer + option
- `SELECTION`: lista de 9 monsters com outfit
- `SELECTION_CHANGE_MONSTER`: bônus atual + lista monsters
- `LIST_SELECTION`: lista completa de raceIds

Tail:
- old protocol: `u16` (minutes)
- new protocol: `u32` (seconds) + `u8 option`

### PreyRerollPrice (`0xE9`)
- `u32 preyRerollPrice`
- protocolos novos adicionam também preços de prey bonus/list e task hunting.

## Caminho completo solicitado

```text
Servidor
  -> ProtocolGame::sendPreyData/sendPreyTimeLeft/sendPreyPrices
  -> NetworkMessage (serialização por estado)
  -> Cliente ProtocolGame::parsePrey*
  -> g_lua.callGlobalField("g_game", "onPrey...")
  -> modules.game_prey (controller Lua)
  -> atualização de widgets OTUI (slot, tracker, botões, barras)
```

## ExtendedOpcode / PREY_OPCODE
- Não há uso de `ExtendedOpcode` para prey no fluxo principal.
- Prey usa opcodes dedicados no protocolo base.

## Pontos críticos
1. **Divergência de opcode request**: `ClientPreyRequest` do cliente não mapeia de forma evidente para um parse explícito de “refresh prey” no servidor.
2. **Convivência com Task Hunting**: payload de preços inclui ambos; parsing parcialmente acoplado no cliente.
3. **Compatibilidade old/new protocol**: múltiplos branches por versão podem causar desserialização incorreta em forks híbridos.

## Limitações e possíveis bugs
- Multiplex de opcode por feature/protocolo aumenta risco de parse errado em forks híbridos.
- Branches por `clientVersion` e `protocolVersion` exigem coerência estrita entre par server/client.

## Sugestões
- Adotar testes de integração com capturas reais de `NetworkMessage` para cada estado prey.
