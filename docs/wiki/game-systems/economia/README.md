[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Economia

# Economia

## Visão geral
A economia engloba sistemas como banco e market, controlando transações e persistência de ofertas.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/game/bank/`.
- **Persistência**: `crystalserver/src/io/iomarket.*` e `crystalserver/schema.sql`.
- **Config**: `crystalserver/src/config/` (parâmetros de market).
- **Cliente**: `otclient/modules/game_market/`.

## Estrutura interna (alto nível)
- Banco e lógica econômica no servidor.
- Market integrado à camada de I/O e banco de dados.

## Fluxo geral
1. Jogador acessa funcionalidades de economia (ex.: market/banco).
2. Servidor registra e consulta ofertas via I/O.
3. Cliente exibe informações em módulos específicos.

## Pontos de extensão
- Scripts de NPCs podem expor serviços econômicos em `crystalserver/data/scripts/npcs/`.
