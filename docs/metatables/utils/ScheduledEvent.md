# ScheduledEvent

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** Event
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: cyclesExecuted, delay, maxCycles, nextCycle, remainingTicks, ticks
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `ScheduledEvent -> Event`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:346`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
