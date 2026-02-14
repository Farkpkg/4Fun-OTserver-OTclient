# Missile

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** Thing
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: setId, setPath
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Missile -> Thing`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:829`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
