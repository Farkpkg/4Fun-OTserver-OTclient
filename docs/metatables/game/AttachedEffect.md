# AttachedEffect

- **Tipo:** C++ userdata binding
- **Categoria:** game
<<<<<<< HEAD
- **Localização:** otclient/src/client/luafunctions.cpp
=======
- **Definição/registro:** otclient/src/client/luafunctions.cpp
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
- **Classe base:** (root)
- **Metamétodos ativos:** __index, __newindex, __eq, __gc

## Estrutura interna
<<<<<<< HEAD
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
=======
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
>>>>>>> fb0a891c4e31294aecbebf8077e3a2701eb748b2
