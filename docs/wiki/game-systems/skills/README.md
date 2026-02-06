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

## Pontos de extensão
- Scripts podem reagir a eventos de criaturas em `crystalserver/data/scripts/creaturescripts/`.
