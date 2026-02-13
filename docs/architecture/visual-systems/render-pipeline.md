# Render Pipeline (Wings/Aura/Shaders/Effects)

## Ordem macro

1. **MapView prepass** (`MapView::preLoad`) atualiza caches/attached widgets.
2. **MAP draw pool** desenha tiles/things/missiles/effects.
3. **Creature draw** executa:
   - attached effects bottom
   - mount
   - corpo (com ou sem shader/framebuffer)
   - attached effects top
4. **Light pass** usa `drawLight` de tiles/creatures/attached effects.
5. **Foreground/text/creature info** em pools dedicados.

## DrawPool e estado

- `DrawPoolManager` coordena pools por tipo (`MAP`, `FOREGROUND`, `LIGHT`, etc.).
- `DrawPool` faz batching por estado (`texture`, `shader`, `composition`, `opacity`).
- `setShaderProgram(..., onlyOnce)` minimiza persistência indevida do shader.

## FrameBuffer usage

- Para shaders de criatura com `useFramebuffer=true`:
  1. bind FBO (`bindFrameBuffer`)
  2. render da criatura no buffer
  3. release/desenho do FBO no destino (`releaseFrameBuffer`)
- Isso habilita efeitos pós-processamento localizados (outline, forge_*).

## Map shader path

- `MapView::registerEvents` injeta callback pre/post draw:
  - pre: bind shader, set uniforms de câmera/zoom/walkoffset, opacity de fade.
  - post: reset shader/opacity.

## Assets e texturas

- DAT sprites para thing-based effects.
- PNG/AnimatedTexture para external effects e partículas.
- Fragment shaders GLSL carregados dinamicamente via resource manager.

## Limitações

- Muitos estados transitórios (shader/opacidade/escala/draw order) exigem resets cuidadosos.
- Composição de vários effects com pulse/fade pode amplificar custo CPU por frame.

## Sugestões

- Snapshot de estado gráfico para debug (frame capture textual).
- Métricas por pool (draw calls, objetos batchados, FBO switches).
