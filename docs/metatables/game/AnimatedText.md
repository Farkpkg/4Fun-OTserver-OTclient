# AnimatedText

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Localização:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata `LuaObjectPtr`; dispatch por `__index`/`__newindex` base.
- Campos dinâmicos + fieldmethods + tabela de métodos.

## API
- Métodos públicos: getColor, getOffset, getText
- Métodos estáticos: -
- Fieldmethods/Campos: -

## Herança e __index chain
- Chain: `AnimatedText`
- Permite override: sim.

## Evidências
- `otclient/src/client/luafunctions.cpp:916`

## Riscos
- Mutabilidade em runtime pode introduzir overrides indevidos.
