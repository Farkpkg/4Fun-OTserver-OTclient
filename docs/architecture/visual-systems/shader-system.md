# Shader System

## Arquitetura

## Núcleo gráfico
- `Shader` encapsula shader OpenGL (`glCreateShader`, compile, log, destroy assíncrono).
- `ShaderManager` mantém dicionário `name -> PainterShaderProgram` e vetor por id.
- `PainterShaderProgram` (infra) faz link, binds e multitexture.

## Catálogo e bootstrap
- `modules/game_shaders/shaders.lua` registra shaders de:
  - mapa
  - outfit
  - mount
  - texto
- Para cada shader: `g_shaders.createFragmentShader(name, frag, useFramebuffer)` + setup de uniforms.

## Uniforms importantes
- Mapa: `u_CenterCoord`, `u_MapGlobalCoord`, `u_WalkOffset`, `u_MapZoom`.
- Outfit/mount/item: ids lógicos por uniform binding (`ITEM_ID_UNIFORM`, etc.).
- Texto: offset e center (`TEXT_OFFSET_UNIFORM`, `TEXT_CENTER_UNIFORM`).

## Fluxo de aplicação

### Creature shader
- Server pode enviar via opcode 0x36/54 (`parseCreatureShader`).
- Cliente grava em `Creature::setShader` (id interno do shader).
- Durante `Creature::internalDraw`, shader pode ser aplicado direto ou via framebuffer (quando `useFramebuffer == true`).

### Map shader
- Server envia 0x37/55 ou Lua client troca localmente.
- `MapView::registerEvents` injeta `onBeforeDraw/onAfterDraw` para bind/reset shader e atualização contínua de uniforms.
- Suporte a crossfade entre shaders (`m_nextShader`, timers fade in/out).

## Integração com outfit
- Outfit estendido transporta `shader` como string.
- Server converte string para id interno (`lookShader`) e reenvia nome ao client quando necessário (`AddOutfitCustomOTCR`).

## Dependências
- DrawPool e Painter: shader é estado global do draw atual; reset obrigatório para evitar leak de estado.
- Creature pipeline depende de `hasShader()` + `useFramebuffer()` para escolher caminho.

## Assets
- Fragment shaders: `modules/game_shaders/shaders/fragment/*.frag`.
- Vertex base: `modules/game_shaders/shaders/vertex/default.vert` e sources embutidos.
- Multitexture opcional: `g_shaders.addMultiTexture`.

## Limitações / riscos
- Vazamento de estado gráfico é possível se um draw path retornar cedo sem reset (há correções defensivas em alguns pontos).
- Custo de framebuffer shaders em massa (muitos creatures com `useFramebuffer`) pode ser alto.

## Melhorias
- Perf counters por shader (tempo GPU estimado por frame).
- Fallback automático para shader default em falha de compile/link com relatório estruturado.
