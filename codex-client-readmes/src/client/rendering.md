# Guia de Render do Mundo (MapView, Lighting, ThingType)

## Escopo

Este guia cobre o pipeline de render do mundo: `MapView`, visibilidade, luz e `ThingType`.

## MapView e visibilidade

- `MapView` calcula tiles visiveis por andar e cacheia em `cachedVisibleTiles`.
- Desenha floors back-to-front e aplica regras de occlusao.
- `drawLights()` coleta fontes de luz e aplica framebuffer dedicado.

## Lighting

- `LightView` calcula luz no CPU e compoe com blend.
- Luz global + fontes locais (creatures, itens, efeitos).
- `drawLights()` coleta fontes e aplica textura de luz.
- Usa double-buffer de pixels para atualizar textura sem travar render.

## ThingType

- Metadados de aparencia e flags (walkable, stackable, light, etc.).
- Define layers, patterns e animacao.
- `ThingType::draw()` enfileira comandos no DrawPool.
- Detalhes de carregamento e sprites em `src/client/assets.md`.

## Shaders e particulas

- Shaders sao aplicados em map/creatures/itens via `g_shaders`.
- Map shader: `MapView::setShader()` controla fade e uniforms.
- Itens/creatures: `Thing::setShader()` e `Creature::setShader()`.
- Particulas: `g_particles` e `AttachedEffect` para efeitos anexados.
- Registro de shaders em Lua: `modules/game_shaders/AGENTS.md`.
- Detalhes de attached effects em `src/client/effects.md`.

## Arquivos principais

- `src/client/mapview.*`
- `src/client/lightview.*`
- `src/client/thingtype.*`
- `src/client/uimap.*`
- `src/client/thing.*`
- `src/client/creature.*`
