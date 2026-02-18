# Core Engine

## Entrypoints

- Processo: `crystalserver/src/main.cpp`
- Orquestração: `crystalserver/src/crystalserver.cpp`

## Sequência de inicialização real

1. Configuração (`loadConfigLua`).
2. Conexão/validação de banco (`initializeDatabase`).
3. Carga de módulos/scripts/XML (`loadModules`).
4. World type + mapa + house rent.
5. Início de serviços de rede e game state normal.

## Serviços essenciais

- Scheduler/dispatcher (`src/game/scheduling/*`).
- `g_game()` como núcleo de estado global.
- `ServiceManager` para bind/listen de protocolos.

## Controle de falha de boot

- `modulesLoadHelper` aborta boot em falha de qualquer dependência obrigatória.
- Exceções de inicialização encapsuladas por `FailedToInitializeCrystalServer`.
