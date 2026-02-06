[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Criaturas e NPCs

# Criaturas e NPCs

## Visão geral
Este sistema define entidades vivas do jogo (jogadores, monstros e NPCs), suas propriedades e interações. A maior parte reside no servidor, com representação no cliente.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/creatures/` (players, monsters, npcs, interactions).
- **Scripts**: `crystalserver/data/scripts/npcs/` e `crystalserver/data/npclib/`.
- **Cliente**: entidades em `otclient/src/client/creature*.cpp` e `otclient/src/client/creatures.*`.

## Estrutura interna (alto nível)
- `players/`, `monsters/`, `npcs/` — implementação das entidades no servidor.
- `appearance/` e `interactions/` — suporte a aparência e interações.

## Fluxo geral
1. O servidor carrega definições e instâncias de criaturas.
2. Eventos e scripts de NPCs são acionados por interações do jogador.
3. O cliente recebe atualizações e renderiza entidades na tela.

## Pontos de extensão
- Scripts de NPCs em `crystalserver/data/scripts/npcs/`.
- Eventos de criatura em `crystalserver/data/scripts/creaturescripts/`.
