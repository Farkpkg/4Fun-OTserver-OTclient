# UIQrCode

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Localização:** otclient/src/framework/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getCode, getCodeBorder, setCode, setCodeBorder
- Métodos estáticos: create
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `UIQrCode -> UIWidget`
- Permite override: sim.

## Evidências
- `otclient/src/framework/luafunctions.cpp:970`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
