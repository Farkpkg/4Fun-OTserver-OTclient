# RENDERING PIPELINE ANALYSIS

## Etapa Zero — Contexto operacional obrigatório

### Limites de atuação (FATO)
- Esta análise fica no estado operacional **CURRENT_STATE/MANUAL_ONLY/PARTIALLY_IMPLEMENTED**; nada aqui assume mecanismos de governança automática inexistentes. Não houve proposta de redesign nem expansão arquitetural. 
- A regra operacional é priorizar evidência executável em código sobre suposição documental.

### Estado operacional atual (FATO)
- O repositório possui fluxos reais de protocolo e UI no cliente (`otclient`) e integrações Lua/C++ ativas para Cyclopedia, Bestiary e Bosstiary.
- Parte da governança em `new_docs` é manual/parcial; portanto esta investigação trata risco estrutural apenas com evidência de código.

### Regras de investigação factual (aplicadas)
- **FATO** = linha verificável em arquivo.
- **HIPÓTESE** = inferência limitada quando o código não explicita intenção completa.

---

## Fase 1 — Mapeamento de arquivos

## 1) Characters (tela de Character no Cyclopedia)

### Arquivos principais
- `otclient/modules/modules/game_cyclopedia/tab/character/character.otui`
  - Define widgets `UICreature` para `CharacterBase.Outfit` e `InfoBase.outfitPanel.Sprite`.
- `otclient/modules/modules/game_cyclopedia/tab/character/character.lua`
  - `showCharacter()` aplica `player:getOutfit()` em dois widgets.
  - `Cyclopedia.loadCharacterAppearances(...)` monta outfits de outfits/mounts/familiars recebidos do servidor.
  - `Cyclopedia.reloadCharacterAppearances()` renderiza lista visual (um widget `CharacterAppearance` por entrada).
- `otclient/modules/modules/game_cyclopedia/game_cyclopedia.lua`
  - Registro de callbacks `onParseCyclopediaCharacterAppearances` -> `Cyclopedia.loadCharacterAppearances`.
- `otclient/src/client/protocolgameparse.cpp`
  - Parse de dados de Cyclopedia Character Info (inclui aparências) e envio ao `g_game`.
- `otclient/src/client/game.cpp`
  - Bridge C++ -> Lua (`onParseCyclopediaCharacterAppearances`).
- `otclient/src/client/uicreature.cpp`
  - Implementação de draw (`UICreature::drawSelf`) e aplicação de outfit/shader.

### Dependências diretas/indiretas
- Diretas: `g_game`, `g_ui`, `UICreature`, `Creature`, `player:getOutfit()`, callbacks Lua.
- Indiretas: `g_things`/assets de sprite (via outfit ids), ciclo de protocolo Cyclopedia Character Info.

---

## 2) Bestiary

### Arquivos principais
- `otclient/modules/modules/game_cyclopedia/tab/bestiary/bestiary.otui`
  - Widget principal e `UICreature` da tela de detalhe (`CreatureInfo.LeftBase.Sprite`).
- `otclient/modules/modules/game_cyclopedia/cyclopedia_widgets.otui`
  - Define `BestiaryCreature` com `UICreature id: Sprite` (lista/páginas).
- `otclient/modules/modules/game_cyclopedia/tab/bestiary/bestiary.lua`
  - `showBestiary()` solicita dados (`g_game.requestBestiary()`).
  - `Cyclopedia.loadBestiaryCreatures()`/`CreateBestiaryCreaturesItem()` monta cards visuais com `g_things.getRaceData(id).outfit`.
  - `Cyclopedia.loadBestiarySelectedCreature()` renderiza sprite da criatura selecionada.
  - Tracker com cache local (`Cyclopedia.storedTrackerData`, `loadTrackerData/saveTrackerData`).
- `otclient/modules/modules/game_cyclopedia/game_cyclopedia.lua`
  - Registro de callbacks `onParseBestiaryRaces`, `onParseBestiaryOverview`, `onUpdateBestiaryMonsterData`, `onParseCyclopediaTracker`.
- `otclient/src/client/protocolgameparse.cpp`
  - `parseBestiaryRaces`, `parseBestiaryOverview`, `parseBestiaryMonsterData`, `parseBestiaryTracker`.
- `otclient/src/client/game.cpp`
  - `processParseBestiary*` e repasse Lua.
- `otclient/src/client/protocolgamesend.cpp`
  - `sendRequestBestiary`, `sendRequestBestiaryOverview`, `sendRequestBestiarySearch`, `sendStatusTrackerBestiary`.

### Dependências diretas/indiretas
- Diretas: `g_game`, `g_things.getRaceData`, `UICreature`, shaders (`"Outfit - cyclopedia-black"`), tracker status.
- Indiretas: staticdata (raças/outfits), protocolo de bestiary, storage local de filtros/tracker.

---

## 3) Bosstiary

### Arquivos principais
- `otclient/modules/modules/game_cyclopedia/tab/bosstiary/bosstiary.otui`
  - Layout da tela Bosstiary.
- `otclient/modules/modules/game_cyclopedia/cyclopedia_widgets.otui`
  - `BosstiaryItem` contém `UICreature id: Sprite`.
- `otclient/modules/modules/game_cyclopedia/tab/bosstiary/bosstiary.lua`
  - `showBosstiary()` chama `g_game.requestBosstiaryInfo()`.
  - `Cyclopedia.CreateBosstiaryCreature()` aplica outfit por `g_things.getRaceData(data.raceId).outfit`.
  - Usa shader escurecido quando bloqueado.
- `otclient/modules/modules/game_cyclopedia/game_cyclopedia.lua`
  - Callback `onParseSendBosstiary` -> `Cyclopedia.LoadBosstiaryCreatures`.
- `otclient/src/client/protocolgameparse.cpp`
  - `parseBosstiaryInfo` (lista base), `parseBestiaryTracker` (tracker boss via `trackerType=1`), `parseBosstiarySlots` (slots e `boostedBossId`).
- `otclient/src/client/game.cpp`
  - `processBosstiaryInfo` / `processBosstiarySlots` para Lua.
- `otclient/src/client/protocolgamesend.cpp`
  - `sendRequestBosstiaryInfo` + requests de boss slots.

### Dependências diretas/indiretas
- Diretas: `g_game`, `g_things`, `UICreature`, `sendStatusTrackerBestiary` (mesma rota de tracker).
- Indiretas: configuração de progresso por categoria (`CONFIG` local), dados de protocolo boss.

---

## 4) Boosted Creatures (tela inicial do client)

### Arquivos principais
- `otclient/modules/modules/client_bottommenu/bottommenu.otui`
  - Painel `boostedWindow` com dois widgets `Creature` (`creature`, `boss`) + placeholders (`monsterImage`, `bossImage`).
- `otclient/modules/modules/client_bottommenu/bottommenu.lua`
  - `setBoostedCreatureAndBoss(data)` aplica outfit em slots via `applyToBoostedSlot(...)`.
  - Fonte de sprite: `g_things.getRaceData(raceId).outfit`.
  - fallback visual: ícone de interrogação quando não há dados.
- `otclient/modules/modules/client_entergame/entergame.lua`
  - `postShowCreatureBoost()` faz HTTP POST `type='boostedcreature'` e chama `modules.client_bottommenu.setBoostedCreatureAndBoss(response)`.
  - Observação explícita de preload de versão para permitir carregar outfits antes da UI inicial.
- `otclient/data/styles/10-creatures.otui`
  - `Creature < UICreature` (herança do widget usado no painel).
- `otclient/src/client/uicreature.cpp`
  - Render final de creature/outfit.

### Dependências diretas/indiretas
- Diretas: `HTTP.post(Services.status, ...)`, `modules.game_things.isLoaded()`, `g_things.getRaceData`, widgets `Creature`.
- Indiretas: disponibilidade do webservice externo e staticdata local do client (raceId -> outfit).

---

## Fase 2 — Pipeline de renderização (por sistema)

## A) Characters (Cyclopedia)

**Pipeline textual**
1. `showCharacter()` abre OTUI e, se online, lê `g_game.getLocalPlayer():getOutfit()`.
2. Outfit real do player é aplicado em widgets `UICreature` (`CharacterBase.Outfit` e `InfoBase.outfitPanel.Sprite`).
3. Quando servidor envia aparências Cyclopedia, callback `onParseCyclopediaCharacterAppearances` chama `Cyclopedia.loadCharacterAppearances(color, outfits, mounts, familiars)`.
4. Lua monta entidades visuais (tabela `Cyclopedia.Character.Appearances`) com outfits derivados de lookType/mountId + cores.
5. `reloadCharacterAppearances()` cria widgets e faz `widget.creature:setOutfit(...)`.
6. Render final ocorre em `UICreature::drawSelf()` -> `Creature::draw(...)`.

**Tipo de renderização**
- Usa `UICreature` (não draw custom manual por canvas).
- Misto de entidade real e mock:
  - Real: outfit do `LocalPlayer` na parte principal.
  - Mock visual: lista de aparências (somente outfit construído).
- Dependência de servidor: **sim** (aparências via parse Cyclopedia).
- Cache de outfit: não há cache dedicado de outfit na tela; depende de staticdata e tabela Lua temporária.
- Shader/efeitos especiais: não identificado shader específico nessa tela.

---

## B) Bestiary

**Pipeline textual**
1. `showBestiary()` abre UI e dispara `g_game.requestBestiary()`.
2. Servidor responde com categorias/overview/monstro específico (`parseBestiaryRaces`, `parseBestiaryOverview`, `parseBestiaryMonsterData`).
3. C++ `Game::process...` repassa para callbacks Lua de Cyclopedia.
4. Lua gera listas paginadas; para cada criatura: `g_things.getRaceData(id).outfit`.
5. Widgets `BestiaryCreature.Sprite` e `CreatureInfo.LeftBase.Sprite` recebem `setOutfit(...)`.
6. Render em `UICreature::drawSelf()`.
7. Atualizações: mudança de seleção, busca, paginação e tracker (inclui cache local de tracker/filtros).

**Tipo de renderização**
- Usa `UICreature`.
- Entidade visual mock (não instancia `Creature` “real de mapa” por id de entidade do jogo).
- Dependência de servidor: **alta** para progresso/stats/lista; outfit depende de staticdata cliente.
- Cache: sim para **tracker/filtros**, não para textura em si.
- Shader/efeitos: aplica `"Outfit - cyclopedia-black"` para criaturas não desbloqueadas.

---

## C) Bosstiary

**Pipeline textual**
1. `showBosstiary()` abre UI e pede `g_game.requestBosstiaryInfo()`.
2. `parseBosstiaryInfo` produz lista (`raceId`, `category`, `kills`, tracker status) -> callback Lua.
3. Lua ordena dados, cria cards e resolve `raceData` por `g_things.getRaceData(raceId)`.
4. `widget.Sprite:setOutfit(raceData.outfit)` + `setStaticWalking(1000)`.
5. Render em `UICreature::drawSelf()`.
6. Atualização por paginação/refresh e integração com tracker (via canal compartilhado `parseBestiaryTracker` com tipo boss).

**Tipo de renderização**
- Usa `UICreature`.
- Entidade mock visual.
- Dependência de servidor: **sim** para dados de progresso e tracking.
- Cache: rastreamento bosstiary reaproveita camada de cache de tracker no módulo bestiary.
- Shader/efeitos: `"Outfit - cyclopedia-black"` para boss bloqueado.

---

## D) Boosted creatures (tela inicial)

**Pipeline textual**
1. Na tela de entrada, `EnterGame.postShowCreatureBoost()` envia HTTP com `type='boostedcreature'`.
2. Resposta JSON é passada para `modules.client_bottommenu.setBoostedCreatureAndBoss(response)`.
3. `applyToBoostedSlot` resolve `raceId` (creature e boss) em `g_things.getRaceData(raceId)`.
4. Widget `Creature` (herdado de `UICreature`) recebe `setOutfit(raceData.outfit)`.
5. `getCreature():setStaticWalking(1000)` + exibição de sprite, ocultando placeholder.
6. Render final em `UICreature::drawSelf()`.

**Tipo de renderização**
- Usa `Creature < UICreature`.
- Entidade mock visual.
- Dependência de servidor de jogo (opcode): **não direta** nesta tela; depende de webservice HTTP externo do launcher/login UI.
- Cache de outfits: não identificado cache específico; depende de staticdata já carregado.
- Shader/efeitos: não há shader especial nessa rota.

---

## Fase 3 — Boosted creatures (específico)

## 1) Como a boosted creature é determinada

**FATOS**
- Na tela inicial, a fonte é HTTP (`postShowCreatureBoost`, requestType `boostedcreature`) e não opcode de jogo nessa rotina.
- O payload aceito contempla compatibilidade retroativa: `data.creatureraceid or data.raceid`.
- Boss boosted da mesma resposta usa `data.bossraceid`.

**HIPÓTESE (restrita)**
- O backend HTTP provavelmente consolida origem (server/db/service) e entrega já resolvida para UI, pois o cliente só recebe raceIds e renderiza.

## 2) Armazenamento em memória, associação com UI e render

**FATOS**
- Não há estrutura persistente dedicada; os dados são aplicados diretamente nos widgets (`monsterOutfit`, `bossOutfit`).
- A associação é explícita no `boostedWindow` do `bottommenu.otui`.
- Render reutiliza o mesmo mecanismo de outfit de bestiary/bosstiary (`g_things.getRaceData` + `UICreature`).

## 3) Verificações solicitadas

- Dependência implícita com bestiary:
  - **FATO:** não há chamada direta para funções da tela Bestiary; há compartilhamento **de infraestrutura** (`g_things.getRaceData` e widgets de criatura).
- Estado volátil não persistido:
  - **FATO:** dados boosted não são salvos em storage local pelo módulo; estado é volátil em runtime da tela.
- Risco de drift visual:
  - **FATO:** se `raceId` do JSON não existir em staticdata (`raceData.raceId == 0`), há warning e não renderiza sprite.
  - **HIPÓTESE:** mismatch de versão entre webservice e staticdata local pode causar placeholders/inconsistência visual.

---

## Fase 4 — Verificação de consistência

## 1) Por sistema

### Characters (Cyclopedia)
- SYSTEM_INVARIANTS:
  - Sem violação evidente de autoridade de estado (INV-01): cliente apenas projeta outfit.
  - Sem quebra visível de simetria (INV-02): callbacks C++->Lua para dados de aparências existem.
- Acoplamento UI ↔ lógica:
  - **Leve**: montagem de outfits e filtros está no mesmo módulo Lua de UI.
- Estado não persistido:
  - Dados de aparências em memória (`Cyclopedia.Character.Appearances`) sem persistência.
- Duplicação:
  - Lógica de `setOutfit + setStaticWalking(1000)` repete padrão usado em outras telas.

### Bestiary
- SYSTEM_INVARIANTS:
  - Fluxo request->parse->render observável (INV-09).
- Acoplamento UI ↔ lógica:
  - Moderado: módulo mistura paginação, filtros, tracker, rendering decisions e rede indireta.
- Estado não persistido:
  - Tracker/filtros têm cache local; parte volátil em memória global `Cyclopedia`.
- Duplicação:
  - Repetição de pipeline de outfit semelhante a Bosstiary/Boosted.

### Bosstiary
- SYSTEM_INVARIANTS:
  - Fluxo request->parse->render também observável.
- Acoplamento UI ↔ lógica:
  - Moderado (render + regras de categoria/progresso na camada UI Lua).
- Estado não persistido:
  - Parte de tracker pode ser cacheada, mas render imediato é volátil.
- Duplicação:
  - Mesmo padrão `getRaceData + setOutfit + setStaticWalking`.

### Boosted (tela inicial)
- SYSTEM_INVARIANTS:
  - Não viola autoridade de gameplay (apenas projeção visual).
  - **Ponto sensível INV-10:** depende de fluxo crítico externo (HTTP service) fora do protocolo de jogo para preencher UI.
- Acoplamento UI ↔ lógica:
  - Leve a moderado: módulo de bottommenu faz resolução de dados + render.
- Estado não persistido:
  - Sim, volátil e sem persistência local dedicada.
- Duplicação:
  - Reuso do padrão de render de criatura, sem abstração central única.

## 2) Sobreposição de lógica (Bestiary/Bosstiary/Boosted)

**FATOS**
- Há sobreposição no núcleo de render: todos convergem para `raceId -> g_things.getRaceData -> setOutfit -> UICreature draw`.
- Bestiary e Bosstiary compartilham também infraestrutura de tracker (`onParseCyclopediaTracker` com tipo 0/1).
- Boosted não chama Bestiary diretamente, mas reutiliza a mesma fonte estática (`g_things`).

---

## Fase 5 — Classificação técnica

- **Characters (Cyclopedia): B — Renderização com acoplamento leve**
  - Pipeline claro e estável, mas lógica de montagem visual permanece embutida na camada UI Lua.

- **Bestiary: B/D — Renderização com acoplamento leve + duplicação pontual**
  - Funciona de forma consistente; há repetição de padrões de render já presentes em Bosstiary/Boosted.

- **Bosstiary: B/D — Renderização com acoplamento leve + duplicação pontual**
  - Sem sinais de quebra de pipeline; repete mecânicas de render de Bestiary.

- **Boosted (tela inicial): C — Renderização com risco estrutural leve**
  - Risco não está no draw, e sim na dependência externa HTTP + compatibilidade de raceId com staticdata local.

---

## Diagrama textual consolidado

```text
[Server opcode ou HTTP service]
          ↓
[C++ parse (quando opcode) / Lua JSON decode (quando HTTP)]
          ↓
[g_game callback -> módulo Lua da tela]
          ↓
[raceId/look data -> g_things.getRaceData / player:getOutfit]
          ↓
[widget UICreature/Creature:setOutfit + setStaticWalking]
          ↓
[UICreature::drawSelf -> Creature::draw]
          ↓
[refresh por paginação, seleção, tracker ou nova resposta]
```

---

## Pontos de risco objetivos

1. **Dependência externa no Boosted inicial**: falha/latência/incompatibilidade de webservice impacta preenchimento visual.
2. **Acoplamento de lógica e UI em Lua**: regras de render/filtro/tracker no mesmo módulo aumenta custo de manutenção.
3. **Duplicação de padrão de render**: mesma sequência de outfit aplicada em vários módulos sem camada comum.
4. **Dependência de staticdata consistente**: `raceId` inválido gera fallback e potencial drift visual.

---

## Nível de maturidade da camada de renderização

- **Maturidade geral: intermediária (estável funcionalmente, acoplamento moderado, duplicação controlada).**
- Pontos fortes:
  - Pipeline homogêneo via `UICreature`.
  - Fluxos request->parse->callback->render rastreáveis.
- Limites observados:
  - Repetição de lógica e dependência de estado volátil em alguns pontos (especialmente boosted).

---

## Conclusão executiva objetiva

- A renderização de Characters, Bestiary e Bosstiary segue um padrão consistente: dados entram via protocolo/callback, resolvem outfit e renderizam em `UICreature`.
- Boosted na tela inicial reutiliza o mesmo renderer, porém sua alimentação é externa (HTTP), criando um vetor adicional de inconsistência quando raceIds/versões divergem.
- Não há evidência de violação grave dos invariantes centrais de autoridade de estado; os maiores riscos são de **acoplamento de camada UI**, **duplicação de implementação de render** e **volatilidade de dados no fluxo boosted**.
