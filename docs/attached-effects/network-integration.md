# Integração de rede (Protocol)

## Cliente — opcodes consumidos
Em `protocolcodes.h`:
- `52` = `GameServerAttchedEffect`
- `53` = `GameServerDetachEffect`
- `54` = `GameServerCreatureShader`
- `55` = `GameServerMapShader`

Em `ProtocolGame::parseMessage`, esses opcodes chamam `parseAttachedEffect`, `parseDetachEffect`, `parseCreatureShader`, `parseMapShader`.

## parseAttachedEffect / parseDetachEffect
Formato da mensagem:
- `u32 creatureId`
- `u16 attachedEffectId`

Fluxo cliente:
1. resolve criatura no mapa;
2. `g_attachedEffects.getById(effectId)`;
3. `creature->attachEffect(effect->clone())`;
4. detach remove por `detachEffectById`.

## Snapshot inicial de criatura
No pacote de descrição de criatura, quando `GameCreatureAttachedEffect` está habilitado:
- cliente lê `listSize (u8)`;
- lê N `u16 effectId`;
- limpa temporários e aplica faltantes.

Isso evita depender somente de updates incrementais e garante consistência ao entrar em range.

## Servidor — envio
- `Game::sendAttachedEffect` e `Game::sendDetachEffect` iteram espectadores e enviam via `PlayerAttachedEffects`.
- `ProtocolGame::sendAttachedEffect`: opcode `0x34` + `creatureId` + `effectId`.
- `ProtocolGame::sendDetachEffect`: opcode `0x35` + `creatureId` + `effectId`.
- `ProtocolGame::sendShader`: opcode `0x36` + `creatureId` + `shaderName`.

## Outfit custom OTCR (wings/auras/effects/shaders)
- Cliente envia no `sendSetOutfit` quando feature `GameWingsAurasEffectsShader` está ativa.
- Servidor lê em `parseSetOutfit` e converte `shaderName -> shaderId`.
- Servidor reenvia outfit + listas disponíveis no outfit window custom.

## Ranges (servidor)
Não existem símbolos literais `WINGS_RANGE/AURA_RANGE/...` no código; o equivalente real é:
- `PSTRG_WING_RANGE_START/SIZE`
- `PSTRG_AURA_RANGE_START/SIZE`
- `PSTRG_EFFECT_RANGE_START/SIZE`
- `PSTRG_SHADER_RANGE_START/SIZE`

Esses ranges são usados como bitmap de posse/desbloqueio dos cosméticos.

## Fluxo solicitado
```text
Servidor
  -> ProtocolGame (0x34/0x35 ou snapshot + list)
  -> NetworkMessage (u32 creatureId, u16 effectId)
  -> Client ProtocolGame::parseAttachedEffect
  -> Creature::attachEffect / detachEffectById
  -> Render (bottom/top nas draws da criatura/item/tile)
```
