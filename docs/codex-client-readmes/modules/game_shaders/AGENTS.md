---
alwaysApply: true
---
# Guia de Game Shaders

## Escopo

Este guia cobre `modules/game_shaders`, que registra shaders GLSL e expõe controle em Lua.

## Arquivos principais

- `modules/game_shaders/shaders.lua`
- `modules/game_shaders/shaders.otmod`
- `modules/game_shaders/shaders.html`
- `modules/game_shaders/shaders/fragment/*.frag`
- `modules/game_shaders/shaders/vertex/*.vert`

## Pontos chave

- Registra shaders via `g_shaders.createFragmentShader(...)`.
- Configura uniforms com `setupMapShader`, `setupItemShader`, `setupOutfitShader`.
- Shaders sao usados por map, itens, outfits e UI conforme o tipo.

## Onde editar

- Registry e lista de shaders: `shaders.lua`.
- Codigo GLSL: `shaders/fragment` e `shaders/vertex`.
- UI (quando usada): `shaders.html`.

## Relacionados (C++)

- `src/framework/graphics/shadermanager.*`.
- `src/client/shadermanager.cpp`.
- `src/client/mapview.*` (map shader).
- `src/client/thing.*` e `src/client/creature.*` (item/outfit shader).
- `src/framework/ui/uiwidget.*` (property `shader:` em OTUI).
- `src/client/effects.md` (overview de shaders).
