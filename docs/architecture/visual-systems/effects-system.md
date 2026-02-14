# Effects System (Attached + Magic + Particles)

## 1) AttachedEffect

### Runtime object
- Classe `AttachedEffect` suporta:
  - speed, opacity, size, duration, loop
  - transform (troca outfit temporária)
  - hide owner
  - follow owner movement interpolation (`move` + timer)
  - per-direction offsets/onTop
  - shader local
  - light source
  - bounce/pulse/fade
  - aninhamento de effects (`attachEffect` em outro attached)

### Lifecycle
- `AttachableObject::attachEffect`:
  - chama hook `onStartAttachEffect`
  - agenda detach por duration
  - adiciona na lista
  - dispara evento Lua `onAttach`
- `detachEffect`/`detachEffectById`/`clear*` removem e disparam `onDetach`.
- `drawAttachedEffect` remove automaticamente efeitos com loop zerado.

### Render
- `AttachedEffect::draw` valida tipo/texture, aplica shader/opacidade/scale/order, desenha textura externa ou `ThingType`.
- Em `drawThing=false` ele opera só luz e paths auxiliares.

## 2) Magic Effect (Thing effect)

- Classe `Effect` representa efeitos no tile (opcode `GraphicalEffect`).
- `ProtocolGame::parseMagicEffect` cria `std::make_shared<Effect>()`, seta id/position e adiciona no mapa.
- `Effect::onAppear` calcula duração por animator/ticks e agenda remoção (`g_map.removeThing`).
- `waitFor` coordena atraso para não sobrepor visual quando há fila/otimização.

## 3) Particles

- Definições OTML (`*.otps`) carregadas por `ParticleManager::importParticle`.
- `ParticleEffectType` descreve sistemas; `ParticleEffect` instancia e atualiza sistemas.
- `AttachableObject` permite `attachParticleEffect(name)` e `drawAttachedParticlesEffect` com transform matrix local.

## 4) Integração C++/Lua

### Client Lua APIs expostas
- `g_attachedEffects.registerByThing/registerByImage/getById/remove/clear`
- `AttachableObject:attachEffect/detachEffectById/clearAttachedEffects`
- `AttachableObject:attachParticleEffect/detachParticleEffectByName`
- `AttachedEffect:set*` (shader, offset, loop, duration, bounce, fade, etc.)

### Modules
- `game_attachedeffects/lib.lua`: DSL de registro e config por thingId/category.
- `game_attachedeffects/attachedeffects.lua`: hooks globais `onAttach`, `onDetach`, `onOutfitChange`.

## 5) Limitações / possíveis bugs

- Em `ProtocolGame::parseAttachedEffect`, o objeto retornado de `g_attachedEffects.getById` já é clone e ainda recebe `clone()` novamente (clone redundante).
- Nomes de opcode com typo (`Attched`) podem confundir manutenção, apesar de funcional.
- Sem garantia de ordenação estável de múltiplos attached effects com mesmos draw orders.

## 6) Melhorias

- Eliminar clone duplo no parse.
- Introduzir prioridade explícita por effect para sort de draw.
- Adicionar perfilamento para partículas anexadas em massa.
