# AttachedEffects — Visão geral técnica completa

## Escopo auditado
Esta análise cobre o pipeline completo de efeitos anexados em **cliente OTClient** (`otclient/`) e **servidor CrystalServer** (`crystalserver/`), incluindo:
- armazenamento e ciclo de vida C++;
- API Lua (bindings + módulos);
- integração com Outfit/Wings/Auras/Shaders;
- protocolo de rede para sync incremental e sync em snapshot;
- limites estruturais e pontos de risco.

---

## ETAPA 1 — varredura global (resultado consolidado)

## 1) Arquivos C++ diretamente relacionados

### Cliente (OTClient)
- `otclient/src/client/attachedeffect.h`
- `otclient/src/client/attachedeffect.cpp`
- `otclient/src/client/attachedeffectmanager.h`
- `otclient/src/client/attachedeffectmanager.cpp`
- `otclient/src/client/attachableobject.h`
- `otclient/src/client/attachableobject.cpp`
- `otclient/src/client/thing.h`
- `otclient/src/client/thing.cpp`
- `otclient/src/client/creature.h`
- `otclient/src/client/creature.cpp`
- `otclient/src/client/item.cpp`
- `otclient/src/client/tile.cpp`
- `otclient/src/client/protocolcodes.h`
- `otclient/src/client/protocolgame.h`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/luafunctions.cpp`
- `otclient/src/client/luavaluecasts_client.cpp`
- `otclient/src/client/const.h`

### Servidor (Crystal)
- `crystalserver/src/creatures/appearance/attached_effects/attached_effects.hpp`
- `crystalserver/src/creatures/appearance/attached_effects/attached_effects.cpp`
- `crystalserver/src/creatures/players/attached_effects/player_attached_effects.hpp`
- `crystalserver/src/creatures/players/attached_effects/player_attached_effects.cpp`
- `crystalserver/src/creatures/creature.hpp`
- `crystalserver/src/creatures/creature.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.hpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/game/game.hpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/utils/const.hpp`
- `crystalserver/src/lua/functions/creatures/creature_functions.cpp`

## 2) Módulos Lua relacionados
- `otclient/modules/game_attachedeffects/attachedeffects.otmod`
- `otclient/modules/game_attachedeffects/attachedeffects.lua`
- `otclient/modules/game_attachedeffects/lib.lua`
- `otclient/modules/game_attachedeffects/effects.lua`
- `otclient/modules/game_attachedeffects/configs/outfit_618.lua`
- `otclient/modules/gamelib/thing.lua` (categorias)
- `otclient/modules/gamelib/const.lua` (features)
- `otclient/meta.lua` (stubs/documentação de API)

## 3) Enums, structs e constantes-chave
- Cliente:
  - `ThingCategory*` e `ThingExternalTexture`.
  - `Otc::GameCreatureAttachedEffect`, `Otc::GameCreatureShader`, `Otc::GameWingsAurasEffectsShader`.
  - opcodes custom: `GameServerAttchedEffect=52`, `GameServerDetachEffect=53`, `GameServerCreatureShader=54`, `GameServerMapShader=55`.
- Servidor:
  - structs: `Aura`, `Wing`, `Effect`, `Shader`.
  - storages de ranges:
    - `PSTRG_WING_RANGE_START/SIZE`
    - `PSTRG_EFFECT_RANGE_START/SIZE`
    - `PSTRG_AURA_RANGE_START/SIZE`
    - `PSTRG_SHADER_RANGE_START/SIZE`

## 4) IDs de efeitos encontrados

### Catálogo em XML do servidor
Arquivo: `crystalserver/data/XML/attachedeffects.xml`
- Aura: `id=8`
- Shader: `id=1..5` (Rainbow, Ghost, Jelly, Fragmented, Outline)
- Effect: `id=7`
- Wing: `id=2`, `id=11`

### Registro Lua cliente (exemplos de laboratório)
Arquivo: `otclient/modules/game_attachedeffects/effects.lua`
- IDs registrados: `1..11` (misto de DAT creature/effect/missile e textura externa PNG/APNG via `ThingExternalTexture`).
- Inclui composições (`attachEffect` em cadeia), transform, bounce/pulse/fade, loop, duration e shader por efeito.

## 5) Dependências centrais
- **Creature/Thing/Tile/Item**: herdam ou usam `AttachableObject`.
- **Outfit**: transform + sincronização de wing/aura/effect/shader por outfit custom.
- **Renderer**: `g_drawPool`, draw orders, state de shader/opacidade/escala.
- **Shader**: shader por efeito (`AttachedEffect::setShader`) e shader da criatura.
- **FrameBuffer**: draw em UI creature passa por `bindFrameBuffer`.
- **Protocol**: snapshot de lista + mensagens incrementais attach/detach + shader.

---

## Definição prática do sistema
`AttachedEffect` é uma entidade renderizável e scriptável que pode representar:
1. um `ThingType` DAT (creature/effect/missile/item);
2. uma textura externa (`Texture` / `AnimatedTexture`, incluindo APNG quando suportado pelo pipeline de textura);
3. uma composição de subefeitos (`effect:attachEffect(outroEffect)`).

O objeto dono (`AttachableObject`) mantém vetor de efeitos e aplica eventos Lua `onAttach` / `onDetach`, além de remoção automática por `duration` ou término de loop.

---

## Fluxo macro (resumo executivo)
1. **Registro**: efeito é cadastrado no manager (C++ singleton + conveniência Lua).
2. **Instanciação**: ao solicitar `getById`, retorna clone isolado.
3. **Attach**: `AttachableObject::attachEffect` agenda timers/eventos e adiciona ao vetor.
4. **Draw**: dono chama draw bottom/top; efeito decide se renderiza por direção/camada.
5. **Atualização**: animação por timer + animator + speed; suporte a movimento interpolado.
6. **Detach**: manual, por id, por duração, por loop esgotado ou clear.
7. **Rede**: servidor envia lista no snapshot e updates incrementais para espectadores.

Nos demais arquivos desta pasta, cada etapa é detalhada em profundidade.
