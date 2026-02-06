# Effects, Shaders e Particulas

## Escopo

Este guia cobre efeitos visuais no client: attached effects, shaders e particulas. Para render do mundo, veja `src/client/rendering.md`.

## Attached effects

- `AttachableObject` permite anexar efeitos a creatures/itens/tiles.
- `AttachedEffectManager` registra efeitos por thing ou imagem.
- Protocolos: `parseAttachedEffect()` cria/atualiza efeitos enviados pelo servidor.

## Particulas

- `g_particles` cria e atualiza efeitos (`ParticleManager`).
- Particulas podem ser anexadas a objetos via `AttachableObject::attachParticleEffect()`.
- Assets ficam em `data/particles/` (arquivos `.otps` e texturas).

## Shaders

- `g_shaders` registra shaders GLSL e expõe uniformes.
- `Thing::setShader()` aplica shader em itens/creatures.
- `MapView::setShader()` aplica shader no mapa com fade.
- Shaders GLSL ficam em `modules/game_shaders/shaders/`.

## Lua/Bindings

- `g_attachedEffects` (C++) exposto para Lua via `luafunctions.cpp`.
- Modulo de presets e configs: `modules/game_attachedeffects`.
- Registro de shaders: `modules/game_shaders`.

## Referencias locais

- `src/client/attachedeffect.*`
- `src/client/attachedeffectmanager.*`
- `src/client/attachableobject.*`
- `src/client/thing.*`
- `src/client/mapview.*`
- `src/framework/graphics/AGENTS.md`
