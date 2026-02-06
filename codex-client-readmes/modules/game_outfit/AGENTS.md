---
alwaysApply: true
---
# Guia de Outfit Window

## Escopo

Este guia cobre `modules/game_outfit`, que gerencia a janela de outfit, presets e selecao de shaders.

## Arquivos principais

- `modules/game_outfit/outfit.lua`
- `modules/game_outfit/outfitwindow.otui`
- `modules/game_outfit/outfit.otmod`

## Pontos chave

- Recebe dados via `g_game.onOpenOutfitWindow`.
- Exibe outfits, mounts, familiars, wings, auras, effects e shaders.
- Persiste presets e preferencias no settings.

## Onde editar

- Logica e presets: `outfit.lua`.
- Layout: `outfitwindow.otui`.

## Relacionados (C++)

- `src/client/game.cpp` (processOpenOutfitWindow).
- `src/client/protocolgameparse.cpp` (parseOpenOutfitWindow).
- `src/client/creature.*` (outfit e shader).
- `src/client/thing.*` (shader em items/creatures).
- `src/framework/graphics/AGENTS.md` (ShaderManager/g_shaders).
