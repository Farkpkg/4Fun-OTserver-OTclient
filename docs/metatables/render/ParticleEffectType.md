# ParticleEffectType

- **Tipo:** C++ userdata binding
- **Categoria:** render
- **Definição/registro:** otclient/src/framework/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: create, getDescription, getName
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: ParticleEffectType
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/framework/luafunctions.cpp:983`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
