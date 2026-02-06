<!-- tags: - creatures - npcs - server - lua priority: high -->

## LLM Summary
- **What**: Entidades vivas (players, monsters, NPCs).
- **Why**: Define comportamento e interação.
- **Where**: crystalserver/src/creatures, data/scripts/npcs
- **How**: Servidor gerencia estado e cliente renderiza.
- **Extends**: Scripts de NPCs e creaturescripts.
- **Risks**: Lógica de NPCs pode impactar desempenho.

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

## Exemplo prático (do código)
- `crystalserver/data/scripts/npcs/task_master.lua` define um NPC com `onSay` e registra o tipo via `npcType:register(...)`.

## Debug e troubleshooting
- **Sintoma: NPC não responde**
  - **Possível causa**: script não carregado ou evento não acionado.
  - **Onde investigar**: scripts em `crystalserver/data/scripts/npcs/` e bibliotecas em `crystalserver/data/npclib/`.

## Performance e otimização
- **Ponto sensível**: scripts de NPCs com lógica pesada podem aumentar carga em áreas com muitos jogadores.

## Pontos de extensão
- Scripts de NPCs em `crystalserver/data/scripts/npcs/`.
- Eventos de criatura em `crystalserver/data/scripts/creaturescripts/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

