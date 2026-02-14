# Hooking Guide de Metatables

## Padrão seguro
```lua
local old = Class.method
function Class:method(...)
  local ret = old(self, ...)
  return ret
end
```

## Cuidados
- Não sobrescrever `Class_mt.__index` globalmente.
- Em metatables inline (`{ __index = base }`), preservar fallback original.
