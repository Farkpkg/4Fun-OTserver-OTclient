<!-- tags: - protocol - network - c++ priority: critical -->

## LLM Summary
- **What**: Documenta os protocolos login/status/game.
- **Why**: Garantir compatibilidade cliente ↔ servidor.
- **Where**: crystalserver/src/server/network/protocol, otclient/src/client
- **How**: Lista fluxos, opcodes e pontos de integração.
- **Extends**: Adicionar opcodes sincronizados em ambos os lados.
- **Risks**: Incompatibilidades de opcode e versão bloqueiam sessão.

[Wiki](../README.md) > Protocolos

# Protocolos de rede

## Visão geral
A comunicação cliente ↔ servidor é feita por protocolos binários específicos do Open Tibia. O cliente serializa e envia mensagens, e o servidor processa essas mensagens na camada de protocolo antes de encaminhar ao núcleo do jogo.

## Localização no repositório
- **Servidor**: `crystalserver/src/server/network/protocol/` e `crystalserver/src/server/network/message/`.
- **Cliente**: `otclient/src/client/protocolgame*.cpp` e `otclient/src/client/protocolcodes*`.

## Estrutura interna (alto nível)
- **Servidor**
  - `protocollogin.*` — fluxo de login (identificador `0x01`).
  - `protocolstatus.*` — status (identificador `0xFF`).
  - `protocolgame.*` — mensagens do jogo (entrada e saída).
- **Cliente**
  - `protocolgameparse.cpp` — parsing de pacotes recebidos.
  - `protocolgamesend.cpp` — envio de pacotes para o servidor.
  - `protocolcodes.*` — opcodes e modos de mensagem.

## Sequência operacional (alto nível)
1. **Login/Status**: cliente abre conexão de login/status e envia a primeira mensagem; o servidor responde via `ProtocolLogin`/`ProtocolStatus`.
2. **Jogo**: após autenticação, o cliente envia ações via `ProtocolGame` e recebe atualizações do mundo.

## OpCodes importantes (cliente)
Exemplos de opcodes definidos no cliente em `Protocolcodes.h`:
- **Sessão**: `GameServerEnterGame`, `GameServerPing`, `GameServerPingBack`, `GameServerSessionEnd`.
- **Mapa**: `GameServerFullMap`, `GameServerUpdateTile`, `GameServerCreateOnMap`, `GameServerChangeOnMap`, `GameServerDeleteOnMap`.
- **Chat**: `GameServerTalk`, `GameServerTextMessage`.
- **Entidades**: `GameServerCreatureHealth`, `GameServerCreatureOutfit`, `GameServerCreatureSpeed`.

## Exemplos práticos (do código)
- **Parsing de chat**: `ProtocolGame::parseTalk` traduz o modo de mensagem e interpreta payloads com base no tipo.
- **Tradução de modos**: `Proto::buildMessageModesMap` ajusta mapas de mensagem de acordo com a versão do cliente.

## Debug e troubleshooting
- **Sintoma: cliente não entra no jogo**
  - **Possível causa**: incompatibilidade de opcodes ou protocolo.
  - **Onde investigar**: sincronização entre `protocolcodes.*` no cliente e `protocolgame.*` no servidor.
- **Sintoma: mensagens de chat inconsistentes**
  - **Possível causa**: modo de mensagem não traduzido corretamente.
  - **Onde investigar**: `ProtocolGame::parseTalk` e `Proto::buildMessageModesMap`.

## Performance e otimização
- **Pontos sensíveis**
  - **Mapa e atualizações**: opcodes de mapa (`FullMap`, `UpdateTile`, `CreateOnMap`/`ChangeOnMap`/`DeleteOnMap`) afetam volume de dados.
  - **Chat e mensagens**: parsing frequente pode aumentar uso de CPU em altas taxas de mensagem.

## Pontos de extensão e customização
- **Onde é seguro modificar**
  - Adição de opcodes customizados deve ser feita de forma coordenada (cliente + servidor).
- **Onde NÃO modificar sem coordenação**
  - Alterações de opcodes existentes quebram compatibilidade e devem ser sincronizadas nos dois lados.

## Integrações
- **Servidor**: encaminha mensagens para `crystalserver/src/game/` e sistemas de criaturas/itens/mapa.
- **Cliente**: integra com o núcleo em `otclient/src/client/` e dispara atualizações de UI e estado.

## LLM Extension Points
- **Safe to extend**: OpCodes customizados adicionados em ambos os lados.
- **Use with caution**: Mapeamento de mensagens por versão.
- **Do not modify**: Reaproveitar opcodes existentes sem migração.

