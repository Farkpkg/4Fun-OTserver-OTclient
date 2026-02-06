[Wiki](../README.md) > Protocolos

# Protocolos de rede

## Visão geral
A comunicação cliente ↔ servidor é feita por protocolos binários específicos do Open Tibia. O cliente serializa e envia mensagens, e o servidor processa essas mensagens na camada de protocolo antes de encaminhar ao núcleo do jogo.

## Localização no repositório
- **Servidor**: `crystalserver/src/server/network/protocol/` e `crystalserver/src/server/network/message/`.
- **Cliente**: `otclient/src/client/protocolgame*.cpp` e `otclient/src/client/protocolcodes*`.

## Estrutura interna (alto nível)
- **Servidor**
  - `protocolstatus.*` — fluxo de status/login e informações iniciais.
  - `protocolgame.*` — mensagens do jogo (entrada e saída).
- **Cliente**
  - `protocolgameparse.cpp` — parsing de pacotes recebidos.
  - `protocolgamesend.cpp` — envio de pacotes para o servidor.
  - `protocolcodes.*` — códigos/identificadores de mensagens.

## Fluxo de execução (alto nível)
1. **Handshake/Login**: o cliente conecta e inicia o fluxo de status/login; o servidor responde via `protocolstatus`.
2. **Sessão de jogo**: após autenticação, o cliente usa `protocolgame` para enviar ações e receber atualizações do mundo.

## Integrações
- **Servidor**: encaminha mensagens para `crystalserver/src/game/` e sistemas de criaturas/itens/mapa.
- **Cliente**: integra com o núcleo em `otclient/src/client/` e dispara atualizações de UI e estado.
