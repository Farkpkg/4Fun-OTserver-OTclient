# Metatables Overview (Crystalserver/OTclient)

## Escopo e metodologia
- Varredura global via padrões de metatable em Lua e bindings C++↔Lua.
- Comando principal de descoberta: `rg -n "setmetatable\(|getmetatable\(|__index|__newindex|__call|__gc|__tostring|__eq|__lt|__le|__add|__sub|__mul|__div|__unm|__concat|__pairs|__ipairs|registerClass|registerMetaMethod|bindClass|LuaInterface|LuaObject" otclient crystalserver codex-client-readmes -g "*.{lua,cpp,h,hpp,cc,cxx}"`.
- Total de ocorrências brutas encontradas: **1862**.
- Metatables/classes C++ registradas: **63**.
- Metatables Lua puras detectadas: **18**.

## Arquitetura de metatable do projeto
1. `LuaInterface::registerClass` cria 3 tabelas: `Class`, `Class_fieldmethods`, `Class_mt`.
2. `Class_mt` instala `__index`, `__newindex`, `__eq`, `__gc` para todos userdata `LuaObject`.
3. Herança C++ é reproduzida no Lua com cadeia `__index` de métodos e fieldmethods.
4. Metatables Lua puras em módulos seguem padrão prototipal `X.__index = X` + `setmetatable(instance, X)`.

## Metamétodos globais base (C++)
- `__name` definido em `otclient/src/framework/luaengine/luainterface.cpp:109`.
- `__baseName` definido em `otclient/src/framework/luaengine/luainterface.cpp:112`.
- `__index` definido em `otclient/src/framework/luaengine/luainterface.cpp:116`.
- `__newindex` definido em `otclient/src/framework/luaengine/luainterface.cpp:118`.
- `__eq` definido em `otclient/src/framework/luaengine/luainterface.cpp:120`.
- `__gc` definido em `otclient/src/framework/luaengine/luainterface.cpp:122`.

## Mapa global (Lua -> Metatable -> Binding -> Engine)
```text
Lua Script (modules/*)
  ↓ chama métodos de classe/protótipo
Metatable Lua (X.__index = X)
  ↓ ou
Metatable userdata C++ (Class_mt com __index/__newindex/__eq/__gc)
  ↓
LuaInterface dispatch (luaObjectGetEvent / luaObjectSetEvent)
  ↓
LuaObject (m_fields, m_events, shared_ptr userdata)
  ↓
Subsystems de engine:
  ├─ Game Core (Game, Map, Thing, Creature, Item, Tile, ProtocolGame)
  ├─ Renderer (Painter, Texture, Shader, FrameBuffer, ThingType)
  ├─ UI (UIWidget, UIWindow, UIButton, UIMap, UIMinimap)
  ├─ Network (Connection, InputMessage, OutputMessage)
  └─ Utils/Core (Module, Event, Config, Clock, SoundSource)
```
