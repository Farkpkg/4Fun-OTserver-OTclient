# UIProgressRect

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getDuration, getPercent, getTimeElapsed, setDuration, setPercent, showProgress, showTime, start, stop
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIProgressRect -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:1192`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
