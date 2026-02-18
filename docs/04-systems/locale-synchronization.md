# Sincronização de Locale via Extended Opcode

## Descrição
O cliente envia o locale selecionado para o servidor usando Extended Opcode. O servidor possui `CreatureEvent` para receber o opcode de idioma.

## Localização no Projeto
- client/
  - `otclient/modules/client_locales/locales.lua`
- server/
  - `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`

## Arquivos Envolvidos
- `otclient/modules/client_locales/locales.lua`
- `crystalserver/data/scripts/creaturescripts/others/#extended_opcode.lua`
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/lua/creature/creatureevent.cpp`

## Fluxo de Execução
1. No login (`onGameStart`), o client chama `sendLocale(currentLocale.name)`.
2. `sendLocale` envia `ProtocolGame:sendExtendedOpcode(ExtendedIds.Locale, localeName)`.
3. O servidor recebe pacote de opcode estendido e encaminha para `Game::parsePlayerExtendedOpcode`.
4. O `CreatureEvent` `ExtendedOpcode` executa `onExtendedOpcode(player, opcode, buffer)`.
5. O script `#extended_opcode.lua` trata `OPCODE_LANGUAGE = 1` e filtra idiomas `en`/`pt`.

## Dependências
- Registro de callback em `ProtocolGame.registerExtendedOpcode` no client.
- Evento `CreatureEvent("ExtendedOpcode")` no server.
- Handshake de habilitação de opcodes estendidos no protocolo.

## Pontos de Extensão
- Persistir idioma em storage do jogador no bloco já indicado no script do servidor.
- Adicionar novos idiomas no client e atualizar validação no servidor.
- Reaproveitar o mesmo canal para outros opcodes documentados em arquivo próprio.
