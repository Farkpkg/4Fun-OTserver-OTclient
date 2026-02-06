---
alwaysApply: true
---
# Guia de Audio (SoundManager)

## Escopo

Este guia cobre o sistema de audio do framework (OpenAL): sound manager, canais e efeitos.

## Componentes principais

- `SoundManager` (`soundmanager.*`) singleton `g_sounds`.
- `SoundChannel` e `SoundSource` para playback.
- `SoundEffect` para 3D positional audio.
- `SoundFile` / `OggSoundFile` para decodificacao.

## Fluxo basico

- `g_sounds.init()` inicializa OpenAL.
- Modulos Lua usam `g_sounds.play/preload`.
- Canais controlam fila e volume por tipo.

## Onde ficam os assets

- `data/sounds/` (ogg/otml e assets de audio).

## Onde editar

- `src/framework/sound/soundmanager.*`
- `src/framework/sound/soundchannel.*`
- `src/framework/sound/soundeffect.*`
- `src/framework/sound/soundfile.*`
- `src/framework/sound/oggsoundfile.*`

## Relacionados

- `modules/client_options/AGENTS.md` (enableAudio, volume).
- `src/framework/luaengine/AGENTS.md` (binds de `g_sounds`).
- `data/AGENTS.md` (estrutura de assets).
