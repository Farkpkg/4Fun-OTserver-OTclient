# SoundSource

- **Tipo:** C++ userdata binding
- **Categoria:** utils
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: isPlaying, play, removeEffect, setEffect, setFading, setGain, setLooping, setName, setPosition, setReferenceDistance, setRelative, setVelocity, stop
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `SoundSource`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:1091`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
