# Integração com Creature

## 1) Armazenamento
`Creature` herda `Thing` -> `AttachableObject`; efeitos ficam em `m_data->attachedEffects` (cliente). No servidor, a criatura guarda IDs em `attachedEffectList`.

## 2) Vínculo com outfit
Há dois vínculos:
1. **Transform effect**: `onDispatcherAttachEffect` pode trocar outfit temporariamente para o `ThingType` do efeito.
2. **Outfit custom OTCR**: campos `lookWing/lookAura/lookEffect/lookShader` são enviados/recebidos no protocolo e convertidos em attach/detach/shader.

## 3) looktype e offsets
Módulo Lua permite configuração por looktype:
- `registerThingConfig(ThingCategoryCreature, lookType)`
- `c:set(effectId, { dirOffset = ... })`
Isso ajusta offsets específicos por criatura/outfit e reaplica no `onOutfitChange`.

## 4) Direção da criatura
Ao mudar direção:
- `Creature::setDirection` chama `setAttachedEffectDirection`.
- Efeitos de categoria `Creature`/`Missile` recebem direção atual para manter orientação.

## 5) Player/Monster/NPC
No cliente, qualquer `Creature` pode renderizar attached effects.
No servidor:
- gestão de wing/aura/effect/shader é fortemente centrada em `PlayerAttachedEffects` (unlock, toggle, persistência em storage);
- monsters/NPCs ainda podem ter `attachedEffectList` e receber attach/detach por API base de `Creature`.

## Fluxo (player)
```text
Player escolhe outfit custom (wing/aura/effect/shader)
 -> servidor valida posse/unlock
 -> detach current + attach novo id
 -> Game envia para espectadores
 -> cliente aplica na criatura e renderiza
```

## Pontos críticos
- Flags `disableWalkAnimation` e `transform` alteram estado da criatura durante o attach/detach.
- `hideOwner` usa contador no objeto dono; múltiplos efeitos ocultadores são suportados, mas exigem detach balanceado.
