---
alwaysApply: true
---
# Guia de Graphics (DrawPool, Painter, TextureAtlas)

## Escopo

Este guia cobre o pipeline de renderizacao no framework: DrawPool, DrawPoolManager, Painter, TextureAtlas e framebuffers.

## Componentes principais

- `DrawPool`: pool de comandos com estado e batching.
- `DrawPoolManager`: coordena pools e flush do frame.
- `DrawHashController`: deduplicacao por hash.
- `PoolState` e `DrawObject`: estado de render e buffers.
- `TextureAtlas`: packing de texturas.
- `Graphics`/`Painter`: API de render e envio para GPU.

## Pipeline (alto nivel)

- Coleta de comandos por pool -> hashing -> batching.
- Double-buffer entre thread de coleta e thread de render.
- Flush no final do frame via `g_drawPool`.

## Pools e camadas

- MAP, LIGHT, FOREGROUND, FOREGROUND_MAP, CREATURE_INFORMATION, TEXT.
- Pools com framebuffer fazem caching quando `canRepaint()` nao muda.

## Otimizacoes

- Batching por estado para reduzir mudanças de GPU.
- TextureAtlas para reduzir binds.
- Hash dedup para evitar redesenho igual.
- Object pooling para reduzir alocacoes.

## Framebuffers e efeitos

- Pools podem renderizar em framebuffer para caching/efeitos.
- `bindFrameBuffer()` / `releaseFrameBuffer()` suportam efeitos temporarios.
- Composicao: `NORMAL`, `MULTIPLY`, `ADD` para luz e glow.
- Shaders via `setShaderProgram()` com refresh controlado.

## Shaders e particulas

- `ShaderManager` gerencia programas GLSL (`g_shaders`).
- `ParticleManager` e `ParticleSystem` controlam efeitos (`g_particles`).
- UI com particulas: `src/framework/ui/uiparticles.*`.

## Referencias locais

- `src/framework/graphics/drawpool.*`
- `src/framework/graphics/drawpoolmanager.*`
- `src/framework/graphics/textureatlas.*`
- `src/framework/graphics/graphics.*`
- `src/framework/graphics/painter.*`
- `src/framework/graphics/shadermanager.*`
- `src/framework/graphics/particle*.*`
