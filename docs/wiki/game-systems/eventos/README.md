<!-- tags: - events - lua - server priority: high -->

## LLM Summary
- **What**: Eventos e callbacks do jogo.
- **Why**: Permite lógica reativa via scripts.
- **Where**: data/events, data/scripts
- **How**: Eventos registram handlers e disparam scripts.
- **Extends**: Adicionar callbacks em scripts.
- **Risks**: Eventos globais pesados degradam performance.

[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Eventos

# Eventos

## Visão geral
Eventos conectam ações do jogo a scripts Lua, permitindo lógica customizada para diversas situações (globais, de criaturas, de ações e movimentos).

## Arquivos envolvidos
- **Servidor**: `crystalserver/data/events/` e `crystalserver/data/scripts/`.
- **XML**: `crystalserver/data/XML/events.xml`.

## Estrutura interna (alto nível)
- `events.xml` registra eventos e seus handlers.
- Scripts Lua implementam as rotinas chamadas pelos eventos.

## Fluxo geral
1. O servidor carrega os registros de eventos.
2. Quando o evento ocorre, o script associado é executado.

## Exemplo prático (do código)
- `crystalserver/data/XML/events.xml` lista eventos como `Player::onGainExperience` e `Player::onTradeRequest`.

## Debug e troubleshooting
- **Sintoma: evento não dispara**
  - **Possível causa**: evento desabilitado no XML ou script ausente.
  - **Onde investigar**: `events.xml` e scripts associados.

## Performance e otimização
- **Ponto sensível**: eventos globais frequentes podem gerar overhead se scripts tiverem lógica pesada.

## Pontos de extensão
- `crystalserver/data/events/` e `crystalserver/data/scripts/eventcallbacks/`.
- Scripts em `creaturescripts/`, `globalevents/`, `actions/` e `movements/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

