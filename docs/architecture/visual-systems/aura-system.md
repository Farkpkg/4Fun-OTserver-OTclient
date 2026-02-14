# Aura System

## Arquitetura interna

- Aura segue o mesmo backbone de Wings:
  - catálogo em `AttachedEffects` (server)
  - ownership/seleção em `PlayerAttachedEffects`
  - render via `AttachedEffect` no client.
- `defaultOutfit.lookAura` é a “fonte de verdade” para outfit atual.

## Fluxo de execução

1. Player escolhe aura (ou random) no server.
2. `toggleAura` ajusta `defaultOutfit.lookAura`.
3. `Game::playerChangeOutfit` faz detach da aura antiga e attach da nova.
4. Broadcast para espectadores envia attach/detach incremental.
5. Cliente resolve id no `g_attachedEffects` e clona para runtime da criatura.

## C++ <-> Lua

- Server Lua pode chamar:
  - `creature:attachEffectById(id[, temporary])`
  - `creature:detachEffectById(id)`
- Client Lua pode definir comportamento visual (offsets, shader local, transform, etc.) para cada id via `modules/game_attachedeffects/lib.lua`.

## Render pipeline

- A aura é desenhada em fase on-bottom ou on-top conforme config:
  - bottom draw ocorre antes do corpo da criatura (`Creature::internalDraw`).
  - top draw ocorre após corpo/mount.
- `drawLight` também permite emissor de luz por efeito (`setLight`).

## Integração de rede

- Outfit inclui `lookAura` (`U16`) em payload estendido.
- Broadcast incremental usa mesma mensagem de attach/detach de qualquer attached effect.

## Dependências

- `PlayerAttachedEffects::hasAura` valida ownership por storages bitmask.
- Cliente depende de registro prévio do id em `g_attachedEffects` (normalmente feito por Lua module).

## Assets

- Pode usar sprites DAT (`ThingCategoryEffect` / `ThingCategoryCreature`) ou textura externa PNG.
- Se textura externa animada for suportada por `AnimatedTexture`, o frame pode ser atualizado por timer.

## Limitações / possíveis bugs

- IDs no server são `uint16_t`, mas alguns lookups recebem `uint8_t` em assinaturas (`getAuraByID(uint8_t)`), potencial truncamento para ids > 255.
- Falhas de registro no cliente (id não encontrado) silenciam visualmente o efeito para o usuário.

## Melhorias

- Alinhar tipos para `uint16_t` em toda cadeia aura/wing/effect/shader.
- Adicionar ack/telemetria para detectar ids recebidos sem registro no client.
