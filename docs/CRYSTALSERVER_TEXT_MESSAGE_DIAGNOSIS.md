# Diagnóstico: erro em `sendTextMessage` no comando `!talk`

## Erro observado

```txt
[ProtocolGame::sendTextMessage] - Message type is wrong, missing or invalid
```

Esse erro acontece quando `player:sendTextMessage(...)` recebe um tipo inválido (ou `nil`), que no C++ vira `MESSAGE_NONE`.

## Causa raiz

No CrystalServer (base Canary), `ProtocolGame::sendTextMessage` valida explicitamente se o tipo é `MESSAGE_NONE` e loga erro.

- Arquivo: `crystalserver/src/server/network/protocol/protocolgame.cpp`
- Regra: se `message.type == MESSAGE_NONE`, considera tipo inválido.

Na prática, isso costuma ocorrer quando um script usa enum inexistente para `sendTextMessage`, por exemplo:

- `MESSAGE_SAY` (inválido para `sendTextMessage`)
- `MESSAGE_STATUS_CONSOLE_*` (comum em outras distros/forks, mas não neste core)

## Enums corretos disponíveis no CrystalServer

Os tipos válidos para `sendTextMessage` estão no enum `MessageClasses`:

- Arquivo: `crystalserver/src/utils/utils_definitions.hpp`
- Exemplos corretos: `MESSAGE_STATUS`, `MESSAGE_EVENT_ADVANCE`, `MESSAGE_LOOK`, `MESSAGE_FAILURE`, etc.

E esses enums são expostos para Lua em:

- `crystalserver/src/lua/functions/core/game/lua_enums.cpp`

## Diferença importante: mensagem de texto x fala

- `player:sendTextMessage(MESSAGE_..., "...")` usa **MessageClasses**.
- `player:say("...", TALKTYPE_SAY)` usa **SpeakClasses** (`TALKTYPE_*`).

Ou seja:
- `MESSAGE_SAY` **não existe**.
- Para "falar" no chat, use `player:say(..., TALKTYPE_SAY)`.
- Para feedback de comando, use `player:sendTextMessage(MESSAGE_EVENT_ADVANCE|MESSAGE_STATUS|...)`.

## Compatibilidade com o client

O client mapeia os mesmos códigos numéricos (ex.: 19, 30, etc.) em `protocolcodes.cpp`.

- Arquivo: `otclient/src/client/protocolcodes.cpp`
- O parse de text message ocorre em `parseTextMessage`.

Portanto, usar os enums de `MessageClasses` do servidor garante serialização/interpretação correta no client atual.

## Correção aplicada no `!talk`

Foi adicionado/ajustado o comando `!talk` para:

1. Validar parâmetro;
2. Enviar feedback com enum válido (`MESSAGE_EVENT_ADVANCE`/`MESSAGE_STATUS`);
3. Fazer a fala real usando `TALKTYPE_SAY`.

Arquivo:
- `crystalserver/data/scripts/talkactions/player/talk.lua`

## Exemplo funcional (Canary/CrystalServer)

```lua
local talk = TalkAction("!talk")

function talk.onSay(player, words, param)
    if param == "" then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: !talk <message>")
        return false
    end

    player:say(param, TALKTYPE_SAY)
    player:sendTextMessage(MESSAGE_STATUS, "Message sent with TALKTYPE_SAY.")
    return false
end

talk:groupType("normal")
talk:register()
```

## Resumo objetivo

- **Erro**: enum inválido em `sendTextMessage` (vira `MESSAGE_NONE`).
- **Enum correto para feedback de comando**: `MESSAGE_EVENT_ADVANCE` ou `MESSAGE_STATUS`.
- **Para falar no chat**: `player:say(..., TALKTYPE_SAY)`.
- **Não criar enums novos**: usar apenas os enums já registrados em `lua_enums.cpp`.
