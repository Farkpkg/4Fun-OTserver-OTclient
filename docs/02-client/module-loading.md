# Carregamento de Módulos no OTClient

## Descrição
O OTClient inicializa ambiente, paths e módulos em ordem de prioridade. O bootstrap real está centralizado em `otclient/init.lua`.

## Localização no Projeto
- client/
  - `otclient/init.lua`
  - `otclient/modules/`

## Arquivos Envolvidos
- `otclient/init.lua`
- `otclient/modules/corelib/corelib.otmod`
- `otclient/modules/gamelib/gamelib.otmod`
- `otclient/modules/modulelib/modulelib.otmod`
- `otclient/modules/client/client.otmod`
- `otclient/modules/game_interface/interface.otmod`

## Fluxo de Execução
1. Define serviços e configuração de servidores em `init.lua`.
2. Configura log, paths (`data`, `modules`, `mods`) e `config.otml`.
3. Descobre módulos com `g_modules.discoverModules()`.
4. Carrega módulos base (`corelib`, `gamelib`, `modulelib`, `startup`).
5. Carrega módulos de cliente (`client`) e interface de jogo (`game_interface`).
6. Carrega mods e aplica `otclientrc.lua` se existir.

## Dependências
- `g_resources`, `g_configs`, `g_modules` (bindings globais do client).
- Definições `*.otmod` no diretório de módulos.

## Pontos de Extensão
- Adicionar novo módulo em `otclient/modules/<nome>/` com arquivo `.otmod`.
- Controlar ordem pelo `autoload-priority` no `.otmod`.
- Adicionar scripts customizados em `otclientrc.lua`.
