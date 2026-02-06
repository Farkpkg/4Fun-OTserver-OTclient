<!-- tags: - items - server - lua priority: high -->

## LLM Summary
- **What**: Tipos e propriedades de itens.
- **Why**: Suporta inventário, mapa e interações.
- **Where**: crystalserver/src/items, data/items
- **How**: Dados XML + scripts de ações/movimentos.
- **Extends**: Adicionar itens em items.xml e scripts.
- **Risks**: Itens inconsistentes quebram gameplay.

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

## Exemplo prático (do código)
- `crystalserver/data/items/items.xml` contém itens com atributos, incluindo itens com campos como `primarytype`, `weight` e `script`.

## Debug e troubleshooting
- **Sintoma: item sem propriedades**
  - **Possível causa**: definição ausente ou atributos faltando em `items.xml`.
  - **Onde investigar**: `crystalserver/data/items/items.xml` e scripts em `actions/` e `movements/`.

## Performance e otimização
- **Ponto sensível**: itens com eventos frequentes (stepin/stepout) podem gerar muitas chamadas de script.

## Pontos de extensão
- Scripts em `crystalserver/data/scripts/actions/` e `movements/`.
- Dados de item em `crystalserver/data/items/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

