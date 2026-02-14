# AttachedEffect

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: attachEffect, canDrawOnUI, clone, getDirection, getDuration, getId, getSpeed, isFollowingOwner, isPermanent, move, setBounce, setCanDrawOnUI, setDirOffset, setDirection, setDisableWalkAnimation, setDrawOrder, setDuration, setFade, setFollowOwner, setHideOwner, setLight, setLoop, setOffset, setOnTop, setOnTopByDir, setOpacity, setPermanent, setPulse, setShader, setSize, setSpeed, setTransform
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `AttachedEffect`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:834`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
