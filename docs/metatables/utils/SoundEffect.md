# SoundEffect

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: setPreset
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `SoundEffect`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:1109`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
