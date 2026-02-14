# Wings System

## 1) Arquitetura

### Catálogo e identidade
- Wings são entidades catalogadas no servidor como `struct Wing { uint16_t id; std::string name; }`.
- Catálogo vem de `data/XML/attachedeffects.xml` e é carregado por `AttachedEffects::loadFromXml()`.
- Lookup por id/nome: `getWingByID`, `getWingByName`.

### Estado por jogador
- `PlayerAttachedEffects` mantém:
  - seleção atual (`getCurrentWing`, `setCurrentWing`)
  - seleção anterior (`getLastWing` com fallback em KV `last-wing`)
  - ownership (`hasWing`) baseado em bitset em storages (`PSTRG_WING_RANGE_START`)
  - randomização (`getRandomWingId`) quando player está com random mounted.

### Fluxo de toggle
1. `toggleWing(true)` valida exaustão/toggle lock, outfit atual, ownership.
2. Resolve wing alvo (last ou random).
3. Escreve `defaultOutfit.lookWing`.
4. Atualiza estado persistido e executa `g_game().internalCreatureChangeOutfit(...)`.
5. `Game::playerChangeOutfit` aplica attach/detach real em creature.

## 2) Integração com protocolo

### Outfit payload
- No parse do client: `ProtocolGame::getOutfit` lê `wing` como `U16` quando `GameWingsAurasEffectsShader` está ativo.
- No send do client: `ProtocolGame::sendChangeOutfit` serializa `outfit.getWing()`.
- No server parse: `ProtocolGame::parseSetOutfit` consome `lookWing` (U16) em OTCR.

### Evento incremental
- Servidor envia `0x34` (attach effect) com `(creatureId, effectId)`.
- Cliente recebe opcode 52 (`GameServerAttchedEffect`) e faz `creature->attachEffect(...)`.

## 3) Renderização

- Wing não tem pipeline separado: ele é um `AttachedEffect` comum associado a id configurado como creature/effect texture.
- Draw ocorre em `AttachableObject::drawAttachedEffect` e `AttachedEffect::draw`.
- Suporta offset por direção, onTop/onBottom, shader do próprio efeito, bounce/pulse/fade.

## 4) Dependências

- `Outfit.lookWing` (server) ↔ `Outfit::m_wing` (client).
- `Creature` depende de `AttachableObject` para render/lifecycle.
- `g_attachedEffects` (client registry) precisa ter id válido para o wing recebido via rede.

## 5) Assets

- Wing pode apontar para:
  - `ThingType` creature/effect (sprites do DAT)
  - textura externa PNG via `registerByImage`.

## Funções relevantes

- Server: `toggleWing`, `tameWing`, `untameWing`, `hasWing`, `diswing`.
- Client: `parseAttachedEffect`, `attachEffect`, `drawAttachedEffect`, `AttachedEffect::setDirOffset`.

## Pontos de modificação futura

- Migrar wing visual para paperdoll (já há comentário no módulo Lua sugerindo isso).
- Introduzir validação de compatibilidade wing/outfit no cliente (hoje principalmente server-side).

## Possíveis bugs / limitações

- Exhaust/toggle logic depende de flags `wasWinged` e timers; comportamento sob lag pode ficar não intuitivo.
- Sistema usa ids numéricos globais; colisão de id entre efeito/aura/wing no XML causa ambiguidades operacionais.

## Sugestões de melhoria

- Normalizar ids por namespace (`wing:*`, `aura:*`, etc.) no server.
- Incluir metadata de anchor no XML (em vez de hardcode Lua por outfit).
