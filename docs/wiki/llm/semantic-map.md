[Wiki](../README.md) > Mapa semântico (LLM)

# Semantic Map (LLM)

## Sistemas
- **Servidor** ↔ **Protocolos** ↔ **Cliente**
- **Scripts** (servidor) e **Módulos** (cliente)
- **Game Systems** (combate, itens, mapas, etc.)
- **Configuração** (server/client)
- **Assets/UI** (cliente)

## Relações e dependências diretas
- **Cliente → Protocolos**: `otclient/src/client/protocolgame*` envia/recebe mensagens.
- **Protocolos → Servidor**: `crystalserver/src/server/network/protocol` valida e encaminha.
- **Servidor → Scripts**: eventos disparam Lua em `crystalserver/data/scripts`.
- **Servidor ↔ Banco**: persistência via `crystalserver/src/database` e `crystalserver/src/io`.
- **Cliente → UI/Assets**: módulos usam OTUI e assets em `otclient/data`.

## Fluxos principais
- **Login**: Cliente → ProtocolLogin → Server → resposta.
- **Jogo**: Cliente ↔ ProtocolGame ↔ Server → atualizações de mapa/criaturas/itens.
- **Eventos**: Server → Scripts → efeitos no mundo → mensagens ao cliente.

## Pontos de integração
- **Protocolos**: opcodes e versões sincronizadas.
- **Scripts**: hooks de eventos e actions/movements.
- **UI**: módulos reagem a eventos do protocolo.

## Áreas de acoplamento forte
- OpCodes/versões de protocolo.
- Definições de itens/criaturas que afetam cliente e servidor.

## Áreas de desacoplamento
- Scripts Lua e módulos do cliente.
