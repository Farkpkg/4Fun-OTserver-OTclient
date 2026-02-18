# Module System (OTClient)

## Arquivos-chave

- Bootstrap Lua: `otclient/init.lua`
- Descoberta/carga C++: `otclient/src/framework/core/modulemanager.cpp`
- Modelo de módulo C++: `otclient/src/framework/core/module.cpp`
- Metadados de módulos: `otclient/modules/*/*.otmod`

## Pipeline real de carga

1. `g_modules.discoverModules()` varre search paths por `.otmod`.
2. `g_modules.autoLoadModules(maxPriority)` carrega por prioridade.
3. `g_modules.ensureModuleLoaded(name)` força módulos críticos.
4. Cada módulo executa hooks `@onLoad`/`@onUnload` definidos no `.otmod`.

## Módulos ativos observados

Famílias encontradas em `otclient/modules/`:

- Base: `corelib`, `gamelib`, `modulelib`, `startup`, `client`
- Client UI: `client_*` (serverlist, entergame, options, topmenu, etc.)
- Game UI/features: `game_*` (inventory, battle, market, store, prey, forge, wheel, tasks, etc.)

## Estratégia de manutenção

- Novos módulos devem declarar dependências explícitas.
- Evitar side effects globais fora de `init()`/`terminate()`.
- Registrar e remover handlers de forma simétrica.
