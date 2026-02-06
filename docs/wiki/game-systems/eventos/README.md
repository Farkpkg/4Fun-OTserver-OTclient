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

## Pontos de extensão
- `crystalserver/data/events/` e `crystalserver/data/scripts/eventcallbacks/`.
- Scripts em `creaturescripts/`, `globalevents/`, `actions/` e `movements/`.
