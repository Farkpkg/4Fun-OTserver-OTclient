# Tibia4Fun Visual Systems — Overview

## Escopo analisado
Este documento cobre o ecossistema **Wings / Aura / Shaders / Effects** em duas camadas:

- **Servidor (`crystalserver`)**: catálogo, persistência de ownership, lógica de toggle e serialização de protocolo.
- **Cliente (`otclient`)**: parse de mensagens, estruturas de runtime, draw pipeline, integrações Lua/C++.

## Mapeamento global (arquivos-chave)

### Servidor
- Catálogo de attached effects: `crystalserver/src/creatures/appearance/attached_effects/attached_effects.hpp|.cpp`
- Estado por player (wings/aura/effect/shader + randomização + envio): `crystalserver/src/creatures/players/attached_effects/player_attached_effects.hpp|.cpp`
- Aplicação da troca de outfit e sincronização: `crystalserver/src/game/game.cpp`
- Estrutura base em `Creature`: `crystalserver/src/creatures/creature.cpp`
- Rede/opcodes custom OTCR: `crystalserver/src/server/network/protocol/protocolgame.cpp`
- APIs Lua server-side: `crystalserver/src/lua/functions/creatures/creature_functions.cpp`, `crystalserver/src/lua/functions/creatures/player/player_functions.cpp`
- Base de dados dos ids/nomes: `crystalserver/data/XML/attachedeffects.xml`

### Cliente
- Runtime de attached effects: `otclient/src/client/attachedeffect.h|.cpp`
- Registry/lookup de attached effects: `otclient/src/client/attachedeffectmanager.h|.cpp`
- Contêiner comum de objetos anexáveis (creatures/tiles): `otclient/src/client/attachableobject.h|.cpp`
- Outfit transportando wing/aura/effect/shader: `otclient/src/client/outfit.h|.cpp`
- Parse/send de protocolo e outfit serialization: `otclient/src/client/protocolgameparse.cpp`, `otclient/src/client/protocolgamesend.cpp`, `otclient/src/client/protocolcodes.h`
- Efeito de mapa (magic effect): `otclient/src/client/effect.h|.cpp`
- Render de criaturas + shaders + FB pass: `otclient/src/client/creature.cpp`
- Render map shader e uniforms: `otclient/src/client/mapview.cpp`
- Infra de shaders: `otclient/src/framework/graphics/shadermanager.h|.cpp`, `shader.h|.cpp`
- Infra de partículas: `otclient/src/framework/graphics/particle*.h|.cpp`
- Bindings Lua cliente: `otclient/src/client/luafunctions.cpp`, `otclient/src/client/luavaluecasts_client.cpp`
- Módulos Lua de alto nível:
  - `otclient/modules/game_attachedeffects/*.lua`
  - `otclient/modules/game_shaders/shaders.lua`

## Classes e estruturas centrais

- **Servidor**: `AttachedEffects`, `PlayerAttachedEffects`, `Creature`, `ProtocolGame`, structs `Aura`, `Wing`, `Effect`, `Shader`.
- **Cliente**: `AttachedEffect`, `AttachedEffectManager`, `AttachableObject`, `Creature`, `Outfit`, `Effect`, `MapView`, `ShaderManager`, `ParticleManager`, `ParticleEffect`, `ParticleSystem`, `ParticleType`.

## Enums / constantes / opcodes relevantes

- Cliente (`Proto::GameServer*`):
  - `GameServerAttchedEffect = 52` *(sic no código)*
  - `GameServerDetachEffect = 53`
  - `GameServerCreatureShader = 54`
  - `GameServerMapShader = 55`
  - `GameServerGraphicalEffect = 131`
  - `GameServerTextEffect = 132`
  - `GameServerMissleEffect = 133`
- Servidor (bytes enviados OTCR):
  - `0x34` attach effect
  - `0x35` detach effect
  - `0x36` creature shader
  - `0x37` map shader
- Feature flags cliente:
  - `Otc::GameWingsAurasEffectsShader`
  - `Otc::GameCreatureShader`
  - `Otc::GameItemShader`

## Onde cada ação acontece

- **Criar efeitos**
  - Cliente: via `g_attachedEffects.registerByThing/registerByImage` (Lua e C++), e via parse de magic effect (`parseMagicEffect`) criando `Effect`.
  - Servidor: catálogo carregado de `attachedeffects.xml`.
- **Anexar à criatura**
  - Servidor: `Creature::attachEffectById` + broadcast para espectadores.
  - Cliente: `ProtocolGame::parseAttachedEffect` -> `Creature::attachEffect(effect->clone())`.
- **Renderizar**
  - Cliente: `AttachableObject::drawAttachedEffect`, `AttachedEffect::draw`, `Creature::internalDraw`, `MapView::drawFloor/registerEvents`.
- **Remover**
  - Servidor: `Creature::detachEffectById` + broadcast.
  - Cliente: `parseDetachEffect`, timers de duração/loop, clear de listas e lifecycle de partículas.
- **Sincronização**
  - Outfit completo trafega wing/aura/effect/shader em `getOutfit()/sendChangeOutfit()` quando feature habilitada.
  - Eventos incrementais OTCR usam opcodes 0x34-0x37.

## Observações de maturidade

- Há dois canais para “efeitos visuais”: **Thing effect de mapa** (`Effect`) e **AttachedEffect** (objeto anexável, configurável e scriptável).
- Sistema de shader é híbrido: parte configurada por Lua (catálogo/arquivos frag), parte aplicada por C++ durante draw.
- Existem sinais de customização OTCR ampla (paperdoll, shader map/creature e payload estendido no outfit).

## API extraída (Lua/C++)

### Server Lua

- **Função:** `creature:attachEffectById(effectId, [temporary])`
  - **Parâmetros:** `effectId:uint16`, `temporary:boolean` opcional.
  - **Retorno:** sem retorno útil (stack 1).
  - **Exemplo:** `player:attachEffectById(7)`.

- **Função:** `creature:detachEffectById(effectId)`
  - **Parâmetros:** `effectId:uint16`.
  - **Retorno:** sem retorno útil (stack 1).
  - **Exemplo:** `player:detachEffectById(7)`.

- **Função:** `creature:setShader(shaderName)`
  - **Parâmetros:** `shaderName:string`.
  - **Retorno:** `boolean`.
  - **Exemplo:** `target:setShader('Outfit - Ghost')`.

- **Função:** `player:setMapShader(shaderName, [temporary])`
  - **Parâmetros:** `shaderName:string`, `temporary:boolean` opcional (não utilizado na implementação).
  - **Retorno:** `boolean`.
  - **Exemplo:** `player:setMapShader('Map - Heat')`.

- **Função:** `player:addCustomOutfit(type, idOrName)` / `player:removeCustomOutfit(type, idOrName)`
  - **Parâmetros:** `type in {'wing','aura','effect','shader'}`, `id:number|string`.
  - **Uso:** destrava/remover wings/auras/effects/shaders de catálogo para o player.

### Client Lua

- **Função:** `g_attachedEffects.registerByThing(id, name, thingId, category)`
  - **Uso:** registra efeito anexável a partir de ThingType (creature/effect/item).

- **Função:** `g_attachedEffects.registerByImage(id, name, path)`
  - **Uso:** registra efeito via textura externa PNG.

- **Função:** `AttachableObject:attachEffect(effect)` / `:detachEffectById(id)`
  - **Uso:** anexar/remover wings/auras/effects em runtime.

- **Função:** `AttachedEffect:setShader(name)`
  - **Uso:** shader por efeito anexado.

- **Função:** `AttachableObject:attachParticleEffect(name)`
  - **Uso:** aplicar sistema de partículas por nome OTPS.
