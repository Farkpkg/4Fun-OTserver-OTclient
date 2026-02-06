---
alwaysApply: true
---
# Guia de Attached Effects

## Escopo

Este guia cobre `modules/game_attachedeffects`: efeitos anexados a criaturas/itens e configuracoes via Lua.

## Arquivos principais

- `modules/game_attachedeffects/attachedeffects.lua`
- `modules/game_attachedeffects/effects.lua`
- `modules/game_attachedeffects/lib.lua`
- `modules/game_attachedeffects/configs/`

## Pontos chave

- Effects sao definidos em tabelas (shader, speed, opacity, drawOnUI).
- `lib.lua` aplica configuracao em `AttachedEffect` e registra hooks.
- Pode usar particulas (`g_particles`) e shaders (`g_shaders`).

## Onde editar

- Configs e presets: `effects.lua` e `configs/`.
- Helpers de attach/detach: `lib.lua`.
- Inicializacao do modulo: `attachedeffects.lua`.

## Relacionados (C++)

- `src/client/attachedeffect.*` e `src/client/attachedeffectmanager.*`.
- `src/client/attachableobject.*` (attach/detach, particulas e widgets).
- `src/client/protocolgameparse.cpp` (parseAttachedEffect).
- `src/client/luafunctions.cpp` (binds de `g_attachedEffects`).
- `src/framework/graphics/AGENTS.md` (particulas e shaders).
- `src/client/effects.md` (overview de efeitos e shaders).
