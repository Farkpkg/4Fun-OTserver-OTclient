# Paperdoll

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: canDrawOnUI, clone, getBodyColor, getFeetColor, getHeadColor, getId, getLegsColor, getSpeed, hasAddon, removeAddon, reset, setAddon, setAddons, setBodyColor, setCanDrawOnUI, setColor, setColorByOutfit, setDirOffset, setFeetColor, setHeadColor, setLegsColor, setMountDirOffset, setMountOffset, setMountOnTopByDir, setOffset, setOnTop, setOnTopByDir, setOnlyAddon, setOpacity, setPriority, setShader, setShowOnMount, setSizeFactor, setSpeed, setUseMountPattern
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `Paperdoll`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:870`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
