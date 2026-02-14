# Paperdoll

- **Tipo:** C++ userdata binding
- **Categoria:** custom
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: canDrawOnUI, clone, getBodyColor, getFeetColor, getHeadColor, getId, getLegsColor, getSpeed, hasAddon, removeAddon, reset, setAddon, setAddons, setBodyColor, setCanDrawOnUI, setColor, setColorByOutfit, setDirOffset, setFeetColor, setHeadColor, setLegsColor, setMountDirOffset, setMountOffset, setMountOnTopByDir, setOffset, setOnTop, setOnTopByDir, setOnlyAddon, setOpacity, setPriority, setShader, setShowOnMount, setSizeFactor, setSpeed, setUseMountPattern
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: Paperdoll
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:870`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
