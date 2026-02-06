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

## Pontos de extensão
- Scripts Lua em `crystalserver/data/scripts/spells/`, `runes/` e `weapons/`.
- Eventos e callbacks em `crystalserver/data/events/`.
