# Diagnóstico do erro de `sendTextMessage` no `!task`

## Contexto

O comando que apresentou o problema foi o `!task` (não `!talk`).

Erro reportado:

```txt
[ProtocolGame::sendTextMessage] - Message type is wrong, missing or invalid
```

## Causa técnica

No CrystalServer/Canary, `ProtocolGame::sendTextMessage` rejeita mensagens com tipo inválido (`MESSAGE_NONE = 0`).

Quando um script Lua passa um enum inexistente/`nil` para `player:sendTextMessage(...)`, esse valor pode ser convertido internamente para `0`, disparando esse log.

Referência de validação:
- `crystalserver/src/server/network/protocol/protocolgame.cpp`

## Regra correta de uso

- `player:sendTextMessage(MESSAGE_..., "...")` → usa enum de **MessageClasses**.
- `player:say("...", TALKTYPE_...)` → usa enum de **SpeakClasses**.

Enums válidos estão em:
- `crystalserver/src/utils/utils_definitions.hpp`
- Expostos ao Lua em `crystalserver/src/lua/functions/core/game/lua_enums.cpp`

## Ajuste aplicado no sistema de tasks

Foram feitas duas melhorias para o fluxo `!task`:

1. **Padronização de mensagem com fallback seguro**
   - `TASK_MESSAGE_STATUS = MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE or MESSAGE_LOGIN`
   - `TASK_MESSAGE_INFO = MESSAGE_EVENT_ADVANCE or MESSAGE_STATUS or MESSAGE_LOGIN`
   - `TASK_MESSAGE_ERROR = MESSAGE_FAILURE or MESSAGE_STATUS or MESSAGE_EVENT_ADVANCE`

2. **Helper centralizado** (`sendTaskMessage`) em:
   - `crystalserver/data/scripts/talkactions/player/task.lua`
   - `crystalserver/data/scripts/lib/linked_tasks.lua`

Esse helper evita envio com tipo inválido e usa `sendCancelMessage` como fallback final caso necessário.

## Resultado

- O `!task` continua funcional (list/start/status/check/sync).
- O envio de mensagens ao player fica compatível com os enums existentes no core.
- Evita logs por tipo de mensagem inválido no `ProtocolGame::sendTextMessage`.
