<!-- tags: - combat - server - lua priority: high -->

## LLM Summary
- **What**: Sistema de combate e efeitos.
- **Why**: Centraliza dano e interações de ataque.
- **Where**: crystalserver/src/creatures/combat, data/scripts/spells
- **How**: Combina núcleo C++ e scripts Lua.
- **Extends**: Spells/runes/weapons em Lua.
- **Risks**: Scripts incorretos geram dano/efeitos inválidos.

[Wiki](../../README.md) > [Sistemas de jogo](../README.md) > Combate

# Combate

## Visão geral
O sistema de combate processa dano, efeitos e interações de ataque entre entidades do jogo. Ele vive principalmente no servidor, com reflexos no cliente para apresentação visual.

## Arquivos envolvidos
- **Servidor**: `crystalserver/src/creatures/combat/`.
- **Scripts**: `crystalserver/data/scripts/spells/`, `crystalserver/data/scripts/runes/`, `crystalserver/data/scripts/weapons/`.
- **Cliente**: visualização em `otclient/src/client/` (criaturas, efeitos, mísseis).

## Estrutura interna (alto nível)
- Núcleo de combate em C++ dentro de `crystalserver/src/creatures/combat/`.
- Scripts Lua definem comportamento de magias, runas e armas.

## Fluxo geral
1. Ação de combate é recebida via protocolo.
2. O servidor processa regras e aplica efeitos.
3. O cliente recebe atualizações e renderiza animações/efeitos.

## Exemplo prático (do código)
- `crystalserver/data/scripts/spells/#example.lua` mostra a criação de um `Combat()` com parâmetros e o registro de uma runa.

## Debug e troubleshooting
- **Sintoma: magia/runa não causa efeito**
  - **Possível causa**: script não carregado ou erro de execução.
  - **Onde investigar**: scripts em `crystalserver/data/scripts/spells/` e logs do carregamento de scripts.

## Performance e otimização
- **Ponto sensível**: alto volume de efeitos/combate pode aumentar carga do servidor, especialmente quando scripts executam lógica extra.

## Pontos de extensão
- Scripts Lua em `crystalserver/data/scripts/spells/`, `runes/` e `weapons/`.
- Eventos e callbacks em `crystalserver/data/events/`.

## LLM Extension Points
- **Safe to extend**: Scripts Lua e dados ligados ao sistema.
- **Use with caution**: Interações que afetam combate/protocolo.
- **Do not modify**: Alterações sem revisar impactos no cliente.

