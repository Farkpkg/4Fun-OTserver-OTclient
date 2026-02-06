<!-- tags: - glossary - docs priority: medium -->

## LLM Summary
- **What**: Glossário de termos do servidor, cliente e protocolo.
- **Why**: Padroniza conceitos para busca semântica e RAG.
- **Where**: docs/wiki/glossary/README.md
- **How**: Lista termos com definições curtas e referências cruzadas.
- **Extends**: Adicionar termos novos conforme módulos/sistemas crescem.
- **Risks**: Termos ambíguos geram respostas inconsistentes.

[Wiki](../README.md) > Glossário

# Glossário orientado a IA

## Termos gerais
- **CrystalServer**: servidor Open Tibia deste repositório. (Ver [Servidor](../server/README.md).)
- **OTClient**: cliente customizado do jogo. (Ver [Cliente](../client/README.md).)
- **OpCode**: identificador numérico de mensagens do protocolo. (Ver [Protocolos](../protocol/README.md).)

## Termos de protocolo
- **ProtocolLogin**: protocolo de login do servidor (`protocollogin.*`).
- **ProtocolStatus**: protocolo de status do servidor (`protocolstatus.*`).
- **ProtocolGame**: protocolo de sessão de jogo (`protocolgame.*`).
- **MessageMode**: modo de mensagem do chat/feedback no cliente.

## Termos do OTClient
- **OTUI/OTML**: formatos de layout e estilo da UI.
- **Module**: unidade carregável do cliente (ex.: `game_*`, `client_*`).
- **g_game**: facade do estado do jogo no cliente.

## Termos do CrystalServer
- **Datapack**: conjunto de dados e scripts em `crystalserver/data*`.
- **Creature**: entidade viva no servidor (player, monster, NPC).
- **CreatureScript**: script Lua que responde a eventos de criatura.
