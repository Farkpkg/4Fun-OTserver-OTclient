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

## Exemplos práticos (do código)
- **Spell/runa de exemplo**: `crystalserver/data/scripts/spells/#example.lua` define um `Combat()` com parâmetros e registra uma runa.
- **Eventos registrados em XML**: `crystalserver/data/XML/events.xml` lista métodos de evento para `Creature`, `Party` e `Player`.
- **Carga de scripts com logs**: `Scripts::loadScripts` registra scripts carregados e erros quando `SCRIPTS_CONSOLE_LOGS` está habilitado.

## Debug e troubleshooting
- **Sintoma: script não carrega**
  - **Possível causa**: arquivo inválido ou erro de execução Lua.
  - **Onde investigar**: `Scripts::loadScripts` registra `g_logger().error(...)` e imprime o erro de Lua.
- **Sintoma: módulo de UI não inicia**
  - **Possível causa**: dependências faltando ou erro de script.
  - **Onde investigar**: erro de carregamento em `otclient/src/framework/core/module.cpp`.

## Performance e otimização
- **Pontos sensíveis**
  - **Carga de scripts**: a carga percorre diretórios recursivamente e pode impactar boot do servidor.
  - **Logs em excesso**: `SCRIPTS_CONSOLE_LOGS` aumenta volume de logs durante o boot.
- **Onde investigar**
  - `crystalserver/src/lua/scripts/scripts.cpp` (load e logging).

## Pontos de extensão e customização
- **Onde é seguro modificar**
  - Scripts Lua em `crystalserver/data/scripts/`.
  - Módulos Lua em `otclient/modules/`.
- **Onde exigir coordenação**
  - Alterações em eventos registrados no XML devem corresponder aos scripts Lua existentes.

## Integrações
- **Servidor**: scripts são chamados pelo núcleo em `crystalserver/src/game/` e entidades em `crystalserver/src/creatures/`.
- **Cliente**: módulos recebem eventos do framework e do protocolo para atualizar UI e estado.
