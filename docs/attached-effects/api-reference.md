# API de AttachedEffects

## Cliente C++ exposto em Lua

## `AttachableObject`
- `attachEffect(effect)` -> `void`
- `detachEffect(effect)` -> `bool`
- `detachEffectById(id)` -> `bool`
- `getAttachedEffects()` -> `AttachedEffect[]`
- `getAttachedEffectById(id)` -> `AttachedEffect|nil`
- `clearAttachedEffects(ignoreLuaEvent?)`
- `clearTemporaryAttachedEffects()` *(C++ only, usado no parse de criatura)*
- `clearPermanentAttachedEffects()` *(C++ only)*

### Exemplo
```lua
local e = g_attachedEffects.getById(1)
if e then
  creature:attachEffect(e)
end
creature:detachEffectById(1)
```

## `AttachedEffect`
- `AttachedEffect.create(thingId, category)` -> `AttachedEffect`
- `clone()`
- `getId()`
- `setSpeed(speed)` / `getSpeed()`
- `setOnTop(bool)`
- `setDisableWalkAnimation(bool)`
- `setOpacity(number)`
- `setDuration(ms)` / `getDuration()`
- `setHideOwner(bool)`
- `setLoop(int)`
- `setPermanent(bool)` / `isPermanent()`
- `setTransform(bool)`
- `setOffset(x, y)`
- `setDirOffset(dir, x, y, onTop?)`
- `setOnTopByDir(dir, onTop)`
- `setShader(name)`
- `setSize(size)`
- `setCanDrawOnUI(bool)` / `canDrawOnUI()`
- `attachEffect(effectFilho)`
- `setDrawOrder(order)`
- `setLight(light)`
- `setBounce(min,height,speed)`
- `setPulse(min,height,speed)`
- `setFade(start,end,speed)`
- `setFollowOwner(bool)` / `isFollowingOwner()`
- `setDirection(dir)` / `getDirection()`
- `move(fromPos, toPos)`

### Exemplo
```lua
local fx = AttachedEffect.create(38, ThingCategoryMissile)
fx:setDuration(500)
fx:setDirection(East)
fx:move(fromPos, toPos)
owner:attachEffect(fx)
```

## `g_attachedEffects` (singleton)
- `registerByThing(id, name, thingId, category)`
- `registerByImage(id, name, path, smooth?)`
- `getById(id)`
- `remove(id)`
- `clear()`

## API auxiliar Lua do módulo (`AttachedEffectManager` em `lib.lua`)
- `register(id, name, thingId, thingCategory, config)`
- `registerThingConfig(category, thingId):set(effectId, config)`
- `getConfig(id, category, thingId)`
- `executeThingConfig(effect, category, thingId)`
- `getDataThing(thing)`

## Servidor Lua (`Creature`)
- `creature:attachEffectById(effectId, [temporary])`
- `creature:detachEffectById(effectId)`
- `creature:getAttachedEffects()` (lista de IDs)

## Dependências por função
- Attach/detach: `AttachableObject`, `Creature`, dispatcher.
- Shader: `ShaderManager`, draw pool, protocolo (`sendShader`).
- Registro por imagem: `ResourceManager`/`TextureManager`.
- Registro por thing: `ThingTypeManager`/DAT categories.
