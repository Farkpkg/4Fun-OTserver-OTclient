# Cyclopedia Monsters/Creatures (Bestiary + Bosstiary)

## 1) Arquitetura e estruturas de dados

### Front-end Lua
Arquivos principais:
- `otclient/modules/game_cyclopedia/tab/bestiary/bestiary.lua`
- `otclient/modules/game_cyclopedia/tab/bosstiary/bosstiary.lua`
- `otclient/modules/game_cyclopedia/tab/boss_slots/boss_slots.lua`
- `otclient/modules/game_cyclopedia/tab/charms/charms.lua`

Estruturas usadas no namespace `Cyclopedia`:
- `Cyclopedia.Bestiary` (estado de stage, páginas, categorias, criaturas, pesquisa)
- `Cyclopedia.Bestiary.Search` e `Cyclopedia.Bestiary.Creatures` (paginação por blocos)
- `Cyclopedia.storedTrackerData` e `Cyclopedia.storedBosstiaryTrackerData` (cache de tracker por personagem)
- Estados de filtros de Bosstiary por categoria/ranking

### C++ (modelo de dados)
Definidos em `staticdata.h` e enviados para Lua por `luavaluecasts_client.cpp`:
- `CyclopediaBestiaryRace`
- `BestiaryOverviewMonsters`
- `BestiaryMonsterData`
- `BestiaryCharmsData`
- `BosstiaryData`
- `BosstiarySlotsData` + `BosstiarySlot`
- `BossCooldownData`

### Fluxo de callbacks (C++ -> Lua)
- `Game::processParseBestiaryRaces` -> `g_game.onParseBestiaryRaces`
- `Game::processParseBestiaryOverview` -> `g_game.onParseBestiaryOverview`
- `Game::processUpdateBestiaryMonsterData` -> `g_game.onUpdateBestiaryMonsterData`
- `Game::processUpdateBestiaryCharmsData` -> `g_game.onUpdateBestiaryCharmsData`
- `Game::processBosstiaryInfo` -> `g_game.onParseSendBosstiary`
- `Game::processBosstiarySlots` -> `g_game.onParseBosstiarySlots`

## 2) UI e interação

### Bestiary (`showBestiary`)
- Carrega UI (`g_ui.loadUI("bestiary", contentContainer)`).
- Define stage inicial por categoria.
- Registra busca via Enter no `SearchEdit`.
- Pede dados ao servidor com `g_game.requestBestiary()`.

### Stages
`bestiary.lua` usa 4 stages:
- `CATEGORY`
- `CREATURES`
- `CREATURE`
- `SEARCH`

O stage controla:
- widgets visíveis
- comportamento dos botões back/next/prev
- paginação de resultados

### Busca/filtro/paginação
- Busca textual gera lista de `raceIds` e envia `requestBestiaryOverview("Result", true, list)`.
- Catálogos e resultados são quebrados em páginas manualmente (arrays por índice de página).
- `verifyBestiaryButtons()` habilita/desabilita botões conforme página e estado de busca.

## 3) Dados técnicos do monstro carregados do protocol

Em `parseBestiaryMonsterData`:
- `id`, `bestClass`, `currentLevel`
- Kill/progress (`killCounter`, thresholds de unlock)
- `difficulty`, `occurrence`
- Loot list (`itemId`, `difficulty`, `specialEvent`, nome/amount quando disponível)
- Dados avançados por nível:
  - `maxHealth`, `experience`, `speed`, `armor`, `mitigation`
  - Resistências elementais (`combat[elementId] = value`)
  - `location`
- Campos condicionais por `clientVersion` (ex.: animus mastery >= 13.40)

## 4) Trackers (Bestiary/Bosstiary)

O módulo cria miniwindows dedicadas:
- botão toggle no main panel
- cache persistente por personagem
- fallback de recarga agressivo:
  - carrega cache local
  - refresca UI
  - re-solicita servidor

Chamadas relevantes:
- `Cyclopedia.refreshBestiaryTracker()`
- `Cyclopedia.refreshBosstiaryTracker()`
- `g_game.sendStatusTrackerBestiary(raceId, status)` para ativar/desativar tracking

## 5) Bosstiary + Boss Slots

### Bosstiary
- `showBosstiary()` chama `g_game.requestBosstiaryInfo()`.
- Cria cards por boss com categoria (`Bane/Archfoe/Nemesis`) e estado de progresso.
- Implementa busca e paginação separadas.

### Boss Slots
- `showBossSlot()` chama `g_game.requestBossSlootInfo()`.
- Exibe slot bloqueado/vazio/ativo.
- Ações enviadas via `g_game.requestBossSlotAction(action, raceId)`.

## 6) Looktypes e customização de criatura

Na Cyclopedia, visual de criaturas usa `UICreature:setOutfit(...)`:
- bestiary/bosstiary cards: looktype conforme dados de raça.
- character appearances: usa outfits/mounts/familiars recebidos de `requestCharacterInfo`.

Interações relevantes:
- `getCreature():setStaticWalking(1000)` para animação estática suave.
- suporte a `lookType`, `lookHead`, `lookBody`, `lookLegs`, `lookFeet`, addons e mount.

## 7) Limitações e pontos de atenção
- `parseBestiaryEntryChanged` está com TODO (sem uso efetivo).
- Parte do tracker depende fortemente de estado local/cache; risco de divergência visual temporária.
- Há variações de parsing por versão de cliente, exigindo cuidado ao portar protocol.
