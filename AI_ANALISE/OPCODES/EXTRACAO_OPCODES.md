# Extração Técnica — OPCODES (CrystalServer + OTClient)

## 1) Visão Geral

**Elemento analisado:** `OPCODES` (opcodes padrão de protocolo + extended opcodes customizados).

No workspace, os opcodes são o contrato binário principal de comunicação de rede entre client e server. Eles definem:
- qual mensagem está sendo enviada,
- qual parser deve processá-la,
- e qual payload é esperado.

**Atuação no sistema:**
- (x) Servidor
- (x) Cliente
- (x) Ambos

Há dois grupos principais:
1. **Opcodes base do protocolo de jogo** (ex.: movimento, inventário, chat, market, cyclopedia, etc.).
2. **Extended opcodes** (canal customizado OTClient com transporte `0x32` + `opcode lógico` + `string`).

---

## 2) Localização no Código

### 2.1 Definições canônicas de opcode

- `otclient/src/client/protocolcodes.h:45`
- `otclient/src/client/protocolcodes.h:236`
- `otclient/modules/gamelib/protocol.lua:1`
- `otclient/modules/gamelib/protocol.lua:112`
- `otclient/modules/gamelib/const.lua:353`

### 2.2 Dispatch e parse no servidor

- `crystalserver/src/server/network/protocol/protocolgame.cpp:1118`
- `crystalserver/src/server/network/protocol/protocolgame.cpp:1155`
- `crystalserver/src/server/network/protocol/protocolgame.cpp:9110`
- `crystalserver/src/game/game.cpp:10052`
- `crystalserver/src/lua/creature/creatureevent.cpp:528`

### 2.3 Dispatch e parse no cliente

- `otclient/src/client/protocolgameparse.cpp:135`
- `otclient/src/client/protocolgameparse.cpp:3595`
- `otclient/src/client/protocolgamesend.cpp:33`
- `otclient/modules/gamelib/protocolgame.lua:7`
- `otclient/modules/gamelib/protocolgame.lua:17`

### 2.4 Handlers/scripts de extended opcode

- `crystalserver/data/libs/functions/player.lua:55`
- `crystalserver/data/libs/functions/revscriptsys.lua:168`
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua:1`
- `otclient/modules/client_locales/locales.lua:11`
- `otclient/modules/client_locales/locales.lua:90`
- `otclient/modules/game_tasks/tasks.lua:25`
- `otclient/modules/game_tasks/tasks.lua:64`

### 2.5 Documentação existente no repositório

- `docs/05-protocol/opcodes-client.md:1`
- `docs/05-protocol/opcodes-server.md:1`
- `docs/05-protocol/extended-opcodes.md:1`
- `docs/04-systems/extended-opcode-dispatch.md:1`

---

## 3) Código Extraído (trechos relevantes)

### 3.1 Tabelas de opcodes no cliente (Lua)

```lua
-- otclient/modules/gamelib/protocol.lua
GameServerOpcodes = {
    ...
    GameServerExtendedOpcode = 50,
    ...
}

ClientOpcodes = {
    ...
    ClientExtendedOpcode = 50,
    ...
}
```

### 3.2 IDs lógicos de extended opcode

```lua
-- otclient/modules/gamelib/const.lua
ExtendedIds = {
    Activate = 0,
    Locale = 1,
    Ping = 2,
    Sound = 3,
    Game = 4,
    Particles = 5,
    MapShader = 6,
    NeedsUpdate = 7
}
```

### 3.3 Envio de extended opcode no client C++

```cpp
// otclient/src/client/protocolgamesend.cpp
void ProtocolGame::sendExtendedOpcode(const uint8_t opcode, const std::string& buffer)
{
    if (m_enableSendExtendedOpcode) {
        msg->addU8(Proto::ClientExtendedOpcode);
        msg->addU8(opcode);
        msg->addString(buffer);
        send(msg);
    }
}
```

### 3.4 Recepção de extended opcode no client C++

```cpp
// otclient/src/client/protocolgameparse.cpp
void ProtocolGame::parseExtendedOpcode(const InputMessagePtr& msg)
{
    const uint8_t opcode = msg->getU8();
    const auto& buffer = msg->getString();

    if (opcode == 0) {
        m_enableSendExtendedOpcode = true;
    } else if (opcode == 2) {
        parsePingBack(msg);
    } else {
        callLuaField("onExtendedOpcode", opcode, buffer);
    }
}
```

### 3.5 Dispatch de pacote `0x32` no servidor

```cpp
// crystalserver/src/server/network/protocol/protocolgame.cpp
case 0x32:
    parseExtendedOpcode(msg);
    break; // otclient extended opcode

void ProtocolGame::parseExtendedOpcode(NetworkMessage &msg) {
    uint8_t opcode = msg.getByte();
    const std::string &buffer = msg.getString();
    g_game().parsePlayerExtendedOpcode(player->getID(), opcode, buffer);
}
```

### 3.6 Ponte Server C++ -> Event Lua

```cpp
// crystalserver/src/game/game.cpp
void Game::parsePlayerExtendedOpcode(uint32_t playerId, uint8_t opcode, const std::string &buffer) {
    const auto &player = getPlayerByID(playerId);
    if (!player) {
        return;
    }

    for (const auto &creatureEvent : player->getCreatureEvents(CREATURE_EVENT_EXTENDED_OPCODE)) {
        creatureEvent->executeExtendedOpcode(player, opcode, buffer);
    }
}
```

```cpp
// crystalserver/src/lua/creature/creatureevent.cpp
void CreatureEvent::executeExtendedOpcode(const std::shared_ptr<Player> &player, uint8_t opcode, const std::string &buffer) const {
    // onExtendedOpcode(player, opcode, buffer)
    ...
}
```

### 3.7 Exemplo de handler Lua server-side

```lua
-- crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua
local OPCODE_LANGUAGE = 1

function extendedOpcode.onExtendedOpcode(player, opcode, buffer)
    if opcode == OPCODE_LANGUAGE then
        if buffer == "en" or buffer == "pt" then
            -- lógica de idioma
        end
    end
end
```

### 3.8 Exemplo de uso client-side

```lua
-- otclient/modules/client_locales/locales.lua
protocolGame:sendExtendedOpcode(ExtendedIds.Locale, localeName)
ProtocolGame.registerExtendedOpcode(ExtendedIds.Locale, onExtendedLocales)
```

```lua
-- otclient/modules/game_tasks/tasks.lua
ProtocolGame.registerExtendedJSONOpcode(215, parseOpcode)
protocolGame:sendExtendedJSONOpcode(215, data)
```

---

## 4) Fluxo de Execução

## 4.1 Opcode padrão (client -> server)

`Client envia byte de opcode`  
↓  
`ProtocolGame::parsePacketFromDispatcher` (server) seleciona `case` por `recvbyte`  
↓  
`parse*` específico (ex.: stash, cyclopedia, market, movement etc.)  
↓  
`Game::*` altera estado do mundo/jogador  
↓  
Server responde com opcodes de retorno (`send*`).

## 4.2 Extended opcode (client -> server -> lua)

`ProtocolGame::sendExtendedOpcode(opcode, buffer)` (client C++)  
↓  
pacote com `ClientExtendedOpcode` (0x32) + opcode lógico + string  
↓  
`ProtocolGame::parsePacketFromDispatcher` (`case 0x32`) no server  
↓  
`ProtocolGame::parseExtendedOpcode` (server C++)  
↓  
`Game::parsePlayerExtendedOpcode`  
↓  
`CreatureEvent::executeExtendedOpcode`  
↓  
Lua `onExtendedOpcode(player, opcode, buffer)`.

## 4.3 Handshake de ativação de extended opcode

Durante login OTC:
- o server envia pacote `0x32` com payload de ativação,
- o client trata `opcode == 0` em `parseExtendedOpcode`,
- e libera `m_enableSendExtendedOpcode = true`.

Sem esse handshake, o client não envia extended opcode.

---

## 5) Dependências

### 5.1 Dependências de protocolo/transporte
- `ProtocolGame` (client e server)
- `NetworkMessage` / `InputMessage` / `OutputMessage`
- enums de opcode (`protocolcodes.h`, `protocol.lua`)

### 5.2 Dependências de evento/script
- `Game::parsePlayerExtendedOpcode`
- `CreatureEvent` com tipo `extendedopcode`
- `revscriptsys.lua` para bind de `onExtendedOpcode`
- scripts em `data/scripts/creaturescripts`.

### 5.3 Dependências de módulos de gameplay (exemplos observados)
- Locale (`ExtendedIds.Locale = 1`)
- Tasks com JSON em opcode `215`
- Shop (documentado com opcode `201`)

---

## 6) Integração Server ↔ Client

### 6.1 Contrato do canal extended

Formato observado:
- **Transporte**: opcode de rede `0x32`
- **Payload**:
  - `uint8 opcode_lógico`
  - `string buffer`

### 6.2 Processamento no cliente

- C++ (`parseExtendedOpcode`) trata casos especiais:
  - `opcode 0`: habilita envio
  - `opcode 2`: ping
- demais opcodes vão para Lua (`onExtendedOpcode`).

### 6.3 Processamento no servidor

- C++ lê `opcode` + `buffer` e encaminha para `Game`.
- `Game` executa todos os `CreatureEvent` registrados para `extendedopcode`.
- scripts Lua decidem a lógica por `if opcode == ...`.

### 6.4 Estado atual de IDs identificados

- IDs base no client: `0..7` em `ExtendedIds`.
- Casos em uso encontrados:
  - `1` (locale)
  - `201` (shop, documentado)
  - `215` (tasks JSON).

Não foi encontrado, no código varrido, um **registro central único** consolidando todos os IDs customizados usados por todos os módulos/scripts.

---

## 7) Pontos de Modificação

1. **Adicionar opcode padrão (não-extended):**
   - atualizar enum de opcodes (client),
   - incluir parser no `switch` de recepção,
   - implementar `send*`/`parse*` correspondente no server.

2. **Adicionar extended opcode customizado:**
   - escolher ID livre (0-255),
   - registrar callback no client Lua (`registerExtendedOpcode` ou `registerExtendedJSONOpcode`),
   - implementar handler no server (`onExtendedOpcode`) e validação de payload.

3. **Debug de opcodes:**
   - instrumentar `parsePacketFromDispatcher` no server,
   - instrumentar `ProtocolGame:onOpcode`/`onExtendedOpcode` no client Lua,
   - validar handshake (`opcode 0`) quando extended opcode não enviar.

---

## 8) Riscos e Efeitos Colaterais

- **Colisão de opcode customizado** entre módulos (principalmente extended).
- **Dessync de contrato** (payload esperado diferente em cada lado).
- **Falhas silenciosas**: server ignora opcode não tratado; client pode não ter callback.
- **Quebra no login/feature gating** se o handshake de extended opcode não ocorrer.
- **Injeção de payload inválido** (JSON/string) sem validação server-side.
- **Regressão cruzada** ao reaproveitar opcode já usado por outro sistema.

---

## 9) Resumo Técnico

O sistema de OPCODES no repositório é híbrido:
- opcodes de protocolo padrão para features core,
- e um canal extended (`0x32`) para integração customizada via Lua.

O dispatch central está em `ProtocolGame` (server/client). No extended, o fluxo passa por C++ e termina em `CreatureEvent.onExtendedOpcode`, permitindo extensões rápidas, mas exigindo governança forte de IDs e contrato de payload para evitar colisões e dessync.

---

## 10) Sugestões

1. Criar um **registro único de extended IDs** (ex.: `docs/05-protocol/extended-opcode-registry.md`) com dono, payload e versão.
2. Padronizar payload em JSON com schema por opcode.
3. Adicionar validação server-side mínima por opcode (tipo, tamanho, campos obrigatórios).
4. Incluir checklist obrigatório para novo opcode (enum + parser + docs + testes manuais).
5. Automatizar auditoria (`rg`) para detectar IDs duplicados em módulos Lua.
