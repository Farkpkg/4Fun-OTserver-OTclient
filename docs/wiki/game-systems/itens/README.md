[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Itens

# Itens

## Visão geral
O sistema de itens define tipos, propriedades e comportamento de itens no jogo. Ele integra C++ no servidor, dados e scripts.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/items/`.
- **Dados**: `crystalserver/data/items/`.
- **Scripts**: `crystalserver/data/scripts/actions/` e `crystalserver/data/scripts/movements/`.
- **Cliente**: `otclient/src/client/item*.cpp` e `otclient/data/things/`.

## Estrutura interna (alto nível)
- Tipos de item no servidor em `crystalserver/src/items/`.
- Definições e propriedades em `crystalserver/data/items/`.
- Ações/movimentos por scripts Lua.

## Fluxo geral
1. Itens são carregados durante a inicialização do servidor.
2. Ações de uso/movimento disparam scripts específicos.
3. O cliente renderiza itens no mapa e inventário.

## Pontos de extensão
- Scripts em `crystalserver/data/scripts/actions/` e `movements/`.
- Dados de item em `crystalserver/data/items/`.
