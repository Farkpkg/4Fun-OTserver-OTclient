# UIProgressRect

- **Tipo:** C++ userdata binding
- **Categoria:** ui
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** UIWidget
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: create, getDuration, getPercent, getTimeElapsed, setDuration, setPercent, showProgress, showTime, start, stop
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: UIProgressRect -> UIWidget
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:1192`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
