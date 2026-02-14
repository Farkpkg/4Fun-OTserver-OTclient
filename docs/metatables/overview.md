# Metatables Overview (Crystalserver/OTclient)

## Escopo e metodologia
- Comando de varredura principal: `rg -n "setmetatable\(|getmetatable\(|__index|__newindex|__call|__gc|__tostring|__eq|__lt|__le|__add|__sub|__mul|__div|__unm|__concat|__pairs|__ipairs|registerClass|registerMetaMethod|bindClass|LuaInterface|LuaObject" otclient crystalserver codex-client-readmes -g "*.{lua,cpp,h,hpp,cc,cxx}"`.
- Ocorrências brutas: **1862**.
- Metatables C++: **63**.
- Metatables Lua puras: **19**.
- Ocorrências dinâmicas/anônimas: **17**.

## Regras de classificação
1. Origem de binding C++ (client/framework/luaengine).
2. Classe base e prefixo (`UI*`).
3. Fallback por nome.

## Arquitetura base C++↔Lua
- `registerClass` cria `Class`, `Class_fieldmethods`, `Class_mt`.
- Metamétodos base: __name, __baseName, __index, __newindex, __eq, __gc.

## Metatables dinâmicas/anônimas (evidências)
- `otclient/modules/game_wheel/classes/geometry.lua:5` [setmetatable-id] `local self = setmetatable({}, Circle)`
- `otclient/modules/game_wheel/classes/wheelnode.lua:9` [setmetatable-id] `setmetatable(instance, WheelNode)`
- `otclient/modules/game_battle/battle.lua:18` [getmetatable-alias] `local meta = getmetatable(t)`
- `otclient/modules/game_battle/battle.lua:23` [setmetatable-id] `setmetatable(target, meta)`
- `otclient/modules/game_battle/battle.lua:23` [setmetatable-alias-meta] `setmetatable(target, meta)`
- `otclient/modules/game_battle/battle.lua:443` [setmetatable-inline] `setmetatable(instance, {__index = self})`
- `otclient/modules/game_battle/battle.lua:443` [inline-__index] `setmetatable(instance, {__index = self})`
- `otclient/modules/corelib/util.lua:62` [getmetatable-alias] `local mt = getmetatable(object)`
- `otclient/modules/corelib/table.lua:241` [getmetatable-alias] `local mt = getmetatable(t1)`
- `otclient/modules/corelib/ui/uiwidget.lua:547` [setmetatable-inline] `local menv = setmetatable(locals, { __index = env })`
- `otclient/modules/corelib/ui/uiwidget.lua:547` [inline-__index] `local menv = setmetatable(locals, { __index = env })`
- `otclient/modules/corelib/ui/uiwidget.lua:583` [setmetatable-inline] `setmetatable(baseEnv, { __index = _G })`
- `otclient/modules/corelib/ui/uiwidget.lua:583` [inline-__index] `setmetatable(baseEnv, { __index = _G })`
- `otclient/modules/corelib/ui/uiwidget.lua:600` [setmetatable-inline] `setmetatable(e, { __index = base })`
- `otclient/modules/corelib/ui/uiwidget.lua:600` [inline-__index] `setmetatable(e, { __index = base })`
- `otclient/modules/modulelib/controller.lua:91` [setmetatable-id] `setmetatable(obj, self)`
- `otclient/modules/modulelib/eventcontroller.lua:22` [setmetatable-id] `setmetatable(obj, self)`

## Mapa global
```text
Lua Script -> Metatable Lua -> Metatable C++ userdata -> LuaInterface -> LuaObject -> Engine (Game/UI/Render/Network/Utils)
```
