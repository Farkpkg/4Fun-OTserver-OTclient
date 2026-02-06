# Network and Protocol System

## Escopo

Este guia cobre o fluxo do protocolo no client: parse, send e integracao com Game. Para transporte e seguranca, veja `src/framework/net/AGENTS.md`. Para sincronizacao de estado, veja `src/client/state.md`.

## Fluxo geral

- `ProtocolGame::parseMessage()` -> parse*() -> `Game::process*()`.
- `ProtocolGame::send*()` serializa acoes do jogador.
- Lua pode interceptar opcodes via `onOpcode`.

## Camadas e responsabilidades

- Transporte/seguranca: `src/framework/net/AGENTS.md` (ASIO, XTEA, RSA, checksum).
- Serializacao: `InputMessage`/`OutputMessage` (framework net).
- Protocolo: `ProtocolGame` (parse/send e opcodes).
- Estado de jogo: `Game::process*()` e callbacks Lua.

## ProtocolGame (papel e estrutura)

- Herda de `Protocol` e coordena parse/send do protocolo do jogo.
- Mantem estado da sessao (ex.: XTEA, flags de extended opcode).
- Encaminha eventos para `Game` e Lua.

## Parsing de mensagens (resumo)

- Le opcode com `getU8()`.
- Tenta `onOpcode` em Lua; se retornar `true`, para.
- Switch por opcode -> `parse*()` -> `Game::process*()`.
- Opcodes desconhecidos devem ser logados com o restante do buffer.

## Estrutura do dispatcher

- Loop enquanto `!msg->eof()` para processar todos os opcodes.
- Se Lua nao tratar, restaura `readPos` e segue no C++.
- O primeiro opcode de jogo inicializa estado via `processGameStart()`.

## Parse handlers (padrao)

- Ler campos na ordem correta com `getU8/getU16/getU32/getString`.
- Aplicar gates de versao/feature para campos opcionais.
- Chamar `Game::process*()` para atualizar estado + callbacks.

## InputMessage / OutputMessage

- Input: getters tipados e controle de `readPos`.
- Output: `addU8/addU16/addU32/addString/addDouble`.
- Helpers `addPosition()`/`getPosition()` padronizam structs.

## Erros e debug

- Unknown opcode: log com hex dump dos bytes restantes.
- Exceptions no parse: log com opcode/posicao/protocolo e escrita em `packet.log`.

## Padrao de envio

- `send*()` monta `OutputMessage`, adiciona opcode e payload.
- Helpers como `addPosition()`/`getPosition()` padronizam structs.
- Versoes antigas e novas mudam header e flags (ver `src/framework/net/AGENTS.md`).
- `sendLoginPacket()` aplica RSA, gera XTEA e ativa checksum/sequence conforme feature.

## Features e versoes

- Flags em `src/client/const.h` e `modules/game_features/features.lua`.
- Constantes de protocolo em `modules/gamelib/const.lua`.
- Lista de clientes e mapeamento de protocolo em `modules/gamelib/game.lua`.

## Extended Opcode

- Custom protocol via opcode estendido (sub-opcodes definidos em Lua).
- Envio/recebimento em `protocolgamesend.cpp`/`protocolgameparse.cpp`.

## Segurança (resumo)

- Login usa RSA (chave escolhida em `modules/gamelib/game.lua`).
- Sessao usa XTEA + checksum + sequenciamento (dependente de feature).

## Protobuf (formatos modernos)

- Algumas mensagens usam protobuf em versoes modernas.
- Schemas em `src/protobuf/AGENTS.md`.

## OpCodes e categorias

- Definidos em `src/client/protocolcodes.h`.
- Categorias comuns: session, map, creatures, inventory, effects, communication.
 - Alguns opcodes mudam de significado por versao (gate em `getClientVersion()`).

## Versoes e features

- `Otc::GameFeature` em `src/client/const.h` controla variacoes.
- `g_game.getClientVersion()` e `getClientProtocolVersion()` afetam parse/send.
- UI e Lua ajustam features (ver `modules/gamelib` e `modules/client_entergame`).

## Arquivos principais

- `src/client/protocolgame.*`
- `src/client/protocolgameparse.*`
- `src/client/protocolgamesend.*`
- `src/client/protocolcodes.h`
- `src/client/game.*`

## Onde editar

- Novo opcode: `protocolcodes.h` + `parseMessage()` + `parse*()` + `Game::process*()`.
- Novo envio: `send*()` em `protocolgamesend.cpp` + helper de serializacao se preciso.

## Pontes Lua

- Bindings em `src/client/luafunctions.cpp`.
- Callbacks em `Game::process*()` e `g_lua.callGlobalField`.
- Lua base: `modules/gamelib/game.lua`, `modules/gamelib/const.lua`.
- Features: `modules/game_features/features.lua`.
