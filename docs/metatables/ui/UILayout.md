# UILayout

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: addWidget, applyStyle, disableUpdates, enableUpdates, getParentWidget, isUIAnchorLayout, isUIBoxLayout, isUIGridLayout, isUIHorizontalLayout, isUIVerticalLayout, isUpdateDisabled, isUpdating, removeWidget, setParent, update, updateLater
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UILayout`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:862`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
