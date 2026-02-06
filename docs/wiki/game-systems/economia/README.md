<!-- tags: - economy - server - client priority: high -->

## LLM Summary
- **What**: Banco e market do jogo.
- **Why**: Suporta transações e economia.
- **Where**: crystalserver/src/game/bank, src/io/iomarket.*
- **How**: Servidor consulta e grava ofertas.
- **Extends**: NPCs e scripts de economia.
- **Risks**: Queries custosas e inconsistência de dados.

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

## Exemplo prático (do código)
- `IOMarket::getActiveOffers` consulta ofertas no banco e aplica `marketOfferDuration` conforme config.

## Debug e troubleshooting
- **Sintoma: market não retorna ofertas**
  - **Possível causa**: query não retorna resultados ou configuração inválida.
  - **Onde investigar**: `crystalserver/src/io/iomarket.cpp`.

## Performance e otimização
- **Ponto sensível**: consultas de market podem ser custosas sem índices adequados.

## Pontos de extensão
- Scripts de NPCs podem expor serviços econômicos em `crystalserver/data/scripts/npcs/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

