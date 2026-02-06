<!-- tags: - skills - server - client priority: high -->

## LLM Summary
- **What**: Skills e progressão do jogador.
- **Why**: Define atributos persistentes.
- **Where**: crystalserver/src/creatures/players, schema.sql
- **How**: Servidor atualiza e cliente exibe.
- **Extends**: Hooks de creaturescripts para progressão.
- **Risks**: Persistência incorreta afeta progressão.

[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Skills

# Skills

## Visão geral
Skills representam atributos e progressão do personagem. Elas são persistidas no servidor e refletidas no cliente.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/creatures/players/` e `crystalserver/src/io/`.
- **Banco**: `crystalserver/schema.sql` (colunas de skills).
- **Cliente**: módulo `otclient/modules/game_skills/`.

## Estrutura interna (alto nível)
- Skills são mantidas nos dados do jogador no servidor.
- Persistência via camada de I/O.

## Fluxo geral
1. O servidor carrega skills do banco ao logar.
2. Atualizações são aplicadas conforme gameplay.
3. O cliente exibe informações no módulo de skills.

## Exemplo prático (do código)
- `iologindata_save_player.cpp` grava campos como `skill_fist`, `skill_sword` e `skill_dist` no banco.

## Debug e troubleshooting
- **Sintoma: skill não atualiza**
  - **Possível causa**: falha na persistência ou atualização do jogador.
  - **Onde investigar**: camada de I/O em `crystalserver/src/io/`.

## Performance e otimização
- **Ponto sensível**: gravações frequentes de skills podem aumentar carga de I/O.

## Pontos de extensão
- Scripts podem reagir a eventos de criaturas em `crystalserver/data/scripts/creaturescripts/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

