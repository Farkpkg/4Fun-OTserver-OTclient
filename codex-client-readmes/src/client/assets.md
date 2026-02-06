 # Thing Types e Asset Loading

## Escopo

Este guia cobre `ThingType` e o carregamento de assets (sprites, animacoes e cache). Para posicionamento no mundo, veja `src/client/world.md`. Para renderizacao, veja `src/client/rendering.md`.

## Relacao Thing ↔ ThingType

- `Thing` guarda estado de instancia (posicao, stack) e referencia `m_clientId`.
- `ThingType` guarda metadados compartilhados (sprites, flags, patterns).

## Formatos suportados

- Legacy `.dat` (binario): parsing em `ThingType::unserialize()`.
- Moderno protobuf (10.98+): parsing em `ThingType::unserializeAppearance()`.
- Schemas em `src/protobuf/AGENTS.md`.

## Sprite loading e cache

- `m_spritesIndex` mapeia sprites por fase/pattern.
- `getTexture()` faz lazy loading e preenche `m_textureData` por fase.
- Cache evita rebuild por frame e reduz I/O.

## Animacao

- `Animator` controla fases (idle/moving/initial).
- Quando nao ha animator, fases usam tempo baseado em `g_clock`.

## Flags e propriedades

- Flags definem comportamento (walkable, stackable, light, etc.).
- `ThingType` controla layers, displacement, elevation e patterns.

## Onde ficam os assets

- `data/things/<versao>/`: appearances e sprites do client.
- Para estrutura do diretorio, veja `data/AGENTS.md`.

## Referencias locais

- `src/client/thingtype.*`
- `src/client/thing.*`
- `src/client/animator.*`
