[Wiki](../README.md) > Scripts

# Scripts e extensões

## Visão geral
Scripts fornecem extensibilidade para o servidor (Lua) e comportamento/UI no cliente (módulos e mods). Eles são o principal ponto de extensão sem recompilar o C++.

## Localização no repositório
- **Servidor**: `crystalserver/data/scripts/`, `crystalserver/data/events/`, `crystalserver/data/core.lua`, `crystalserver/data/global.lua`.
- **Cliente**: `otclient/modules/`, `otclient/mods/`, `otclient/init.lua`.

## Estrutura interna (alto nível)
### Servidor
- `actions/`, `movements/`, `creaturescripts/` — hooks de ações e eventos de criaturas.
- `spells/`, `runes/`, `weapons/` — magias e combate por scripts.
- `globalevents/`, `eventcallbacks/` — eventos globais e callbacks.
- `npcs/` — scripts de NPCs.

### Cliente
- `modules/client_*` — telas e fluxos de login/configuração.
- `modules/game_*` — funcionalidades de jogo e UI.
- `modulelib/`, `corelib/`, `gamelib/` — bibliotecas base para módulos.

## Fluxo de execução (alto nível)
- **Servidor**: scripts são carregados durante a inicialização e acionados por eventos definidos em XML/Lua.
- **Cliente**: módulos são carregados no bootstrap do cliente via `otclient/init.lua`.

## Integrações
- **Servidor**: scripts são chamados pelo núcleo em `crystalserver/src/game/` e entidades em `crystalserver/src/creatures/`.
- **Cliente**: módulos recebem eventos do framework e do protocolo para atualizar UI e estado.
