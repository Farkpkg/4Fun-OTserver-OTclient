# Mapa de dependências

## Grafo principal
```text
AttachedEffectManager
  -> ThingTypeManager (DAT ids)
  -> ResourceManager/TextureManager (imagens)
  -> AttachedEffect (prototype/clone)

AttachedEffect
  -> DrawPool (draw/shader/opacidade/ordem)
  -> ShaderManager
  -> ThingType / Animator
  -> LightView
  -> Timer/Clock

AttachableObject
  -> vetor attachedEffects
  -> EventDispatcher (attach callbacks + duration detach)
  -> Lua callbacks

Creature/Item/Tile
  -> chamam drawAttachedEffect(bottom/top)
  -> drawAttachedLightEffect

ProtocolGame (client)
  -> parseAttachedEffect / parseDetachEffect
  -> g_attachedEffects.getById

ProtocolGame (server)
  -> sendAttachedEffect / sendDetachEffect / sendShader

Game / PlayerAttachedEffects
  -> regras wings/auras/effects/shaders
  -> storages por ranges (unlock)
```

## Sistemas relacionados
- **Wings system**: usa IDs de `Wing` carregados do XML e attach/detach por outfit.
- **Aura system**: idem wing, storage bitmap próprio.
- **Shader system**: mistura shader de criatura (string) + shader por attached effect no cliente.
- **Particle system**: paralelo a attached effects, mas no mesmo `AttachableObject`.
- **Custom outfits**: `lookWing/lookAura/lookEffect/lookShader` no pacote de outfit.
- **Premium/GM effects**: dependem de regras de unlock (`hasWing/hasAura/hasEffect/hasShader`) e storages do player.

## Dependências com Protocol e NetworkMessage
- servidor serializa em `NetworkMessage` (`u32` creatureId, `u16` effectId, `string` shader);
- cliente desserializa em `InputMessage` e aplica no objeto `Creature`.

## Código comentado / potencialmente morto
- exemplos de uniform em shader dentro de `Creature::internalDraw` e `Item::internalDraw` comentados.
- branch estranha em `lib.lua` (`if type(x) == 'boolean'`) indica trecho possivelmente legado.
- `ThingExternalTexture` definido em Lua como categoria extra fora do enum C++ clássico.
