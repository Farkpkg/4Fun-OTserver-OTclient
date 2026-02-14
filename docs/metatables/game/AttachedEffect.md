# AttachedEffect

- **Tipo:** C++ userdata binding
- **Categoria:** game
- **Definição/registro:** otclient/src/client/luafunctions.cpp
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
- Userdata de `LuaObjectPtr` com despacho via `LuaInterface` (`__index`, `__newindex`).
- Campos privados em `LuaObject::m_fields` e eventos em `LuaObject::m_events` acessados indiretamente.

## API
- Métodos públicos: attachEffect, canDrawOnUI, clone, create, getDirection, getDuration, getId, getSpeed, isFollowingOwner, isPermanent, move, setBounce, setCanDrawOnUI, setDirOffset, setDirection, setDisableWalkAnimation, setDrawOrder, setDuration, setFade, setFollowOwner, setHideOwner, setLight, setLoop, setOffset, setOnTop, setOnTopByDir, setOpacity, setPermanent, setPulse, setShader, setSize, setSpeed, setTransform
- Campos/fieldmethods: -

## Herança e dependências
- Chain `__index`: AttachedEffect
- Dependências: LuaInterface, LuaObject

## Exemplos reais (extração direta)
- `otclient/src/client/luafunctions.cpp:834`

## Pontos de extensão
- Override de métodos na tabela de classe/protótipo.
- Hook de eventos `on*` quando aplicável.

## Riscos
- Override indevido de método global.
- Quebra de chain de `__index` ao substituir metatable inteira.
