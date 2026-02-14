# Hooking Guide de Metatables

## Padrões seguros
```lua
local old = Class.method
function Class:method(...)
  local r = old(self, ...)
  return r
end
```

## Hook em userdata C++
- Preferir hook de métodos na tabela de classe (`Class.method`) e evitar sobrescrever `__index`/`__newindex` globais da classe.
- Em objetos com eventos (`on*`), atribuição ativa `m_events` internamente no `__newindex` base.

## Hook em metatable Lua pura
- Em classes prototipais (`X.__index = X`), hook direto em `X.metodo` preserva cadeia de delegação.
