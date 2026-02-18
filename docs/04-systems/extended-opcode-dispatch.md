# Sistema de Extended Opcode

## 1. Objetivo
Transportar mensagens customizadas Client ⇄ Server fora do conjunto de opcodes padrão.

## 2. Escopo
Controla recepção/expedição de payloads customizados.
Não controla autenticação, criptografia de sessão ou validação de regra de negócio específica.

## 3. Localização no Código

### Server
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/lua/creature/creatureevent.cpp`
- `crystalserver/data/libs/functions/player.lua`

### Client
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/modules/gamelib/protocolgame.lua`

## 4. Fluxo de Execução Completo
1. Módulo client chama `sendExtendedOpcode(opcode, buffer)`.
2. Client envia pacote com opcode de transporte `ClientExtendedOpcode`.
3. Server recebe `0x32` e executa `parseExtendedOpcode`.
4. Server delega para `Game::parsePlayerExtendedOpcode`.
5. Cada `CreatureEvent` registrado para `extendedopcode` é executado.
6. Respostas podem retornar por `Player:sendExtendedOpcode`.
7. Client processa em `ProtocolGame:onExtendedOpcode` e despacha callback registrado.

## 5. Comunicação
- Opcodes utilizados: transporte extended opcode (client 50 / server recv 0x32).
- Eventos utilizados: `CreatureEvent.onExtendedOpcode`.
- Estrutura de payload: string arbitrária (frequente uso de JSON em módulos).

## 6. Estruturas de Dados
- Classes C++: `ProtocolGame`, `Game`, `CreatureEvent`, `Player`.
- Tabelas Lua: mapa de callbacks em `ProtocolGame.registerExtendedOpcode`.
- Tabelas SQL envolvidas: nenhuma direta (depende do sistema consumidor).

## 7. Dependências Cruzadas
- Locales
- Game shop
- Qualquer módulo custom de UI/regras baseado em payload.

## 8. Pontos de Extensão Reais
- Novo opcode lógico em módulo client + callback Lua server.
- Validação de payload no script servidor antes de acionar regras.

## 9. Riscos Técnicos
- Payload sem validação pode causar inconsistência lógica.
- Falta de versionamento de payload entre client e server gera quebra silenciosa.

## 10. Status
✔ Implementado
