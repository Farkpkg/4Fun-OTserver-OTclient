# Cyclopedia Network / Protocol / Hooks

## 1) Requests públicos (Lua -> C++ -> protocol)
Bindings em `luafunctions.cpp` expõem APIs de Cyclopedia:

| Função Lua | C++ (`Game`) | Protocol send | Uso |
|---|---|---|---|
| `g_game.requestBestiary()` | `requestBestiary()` | `sendRequestBestiary()` | Carregar categorias base do Bestiary |
| `g_game.requestBestiaryOverview(catName, search, raceIds)` | `requestBestiaryOverview(...)` | `sendRequestBestiaryOverview(...)` | Carregar lista de criaturas por classe/pesquisa |
| `g_game.requestBestiarySearch(raceId)` | `requestBestiarySearch(...)` | `sendRequestBestiarySearch(...)` | Carregar detalhe de criatura |
| `g_game.requestCharacterInfo(playerId, type, entriesPerPage, page)` | `requestSendCharacterInfo(...)` | `sendCyclopediaRequestCharacterInfo(...)` | Stats/itens/appearances/recentes |
| `g_game.requestBosstiaryInfo()` | `requestBosstiaryInfo()` | `sendRequestBosstiaryInfo()` | Carregar bosses da Bosstiary |
| `g_game.requestBossSlootInfo()` | `requestBossSlootInfo()` | (pacote específico boss slot) | Carregar estado de slots |
| `g_game.requestBossSlotAction(action, raceId)` | `requestBossSlotAction(...)` | `sendBossSlotAction(...)` | Set/remove boss em slot |
| `g_game.sendStatusTrackerBestiary(raceId, status)` | `sendStatusTrackerBestiary(...)` | `sendStatusTrackerBestiary(...)` | Toggle de tracker |
| `g_game.sendCyclopediaHouseAuction(...)` | `requestSendCyclopediaHouseAuction(...)` | `sendCyclopediaHouseAuction(...)` | Operações de house auction |
| `g_game.sendRequestTrackerQuestLog(quests)` | `sendRequestTrackerQuestLog(...)` | `sendRequestTrackerQuestLog(...)` | Sincronização tracker quest |

### Assinatura resumida (API pública)
- `requestBestiary() -> void`
- `requestBestiaryOverview(catName: string, search: bool, raceIds: number[]) -> void`
- `requestBestiarySearch(raceId: number) -> void`
- `requestCharacterInfo(playerId: number, type: CyclopediaCharacterInfoType, entriesPerPage: number, page: number) -> void`
- `requestBosstiaryInfo() -> void`
- `requestBossSlootInfo() -> void`
- `requestBossSlotAction(action: number, raceId: number) -> void`
- `sendStatusTrackerBestiary(raceId: number, status: bool) -> void`
- `sendCyclopediaHouseAuction(type, houseId, timestamp, bidValue, name) -> void`
- `sendRequestTrackerQuestLog(quests: map<number,string>) -> void`

## 2) Parsers principais (server -> client)

Em `protocolgameparse.cpp`:
- `parseBestiaryRaces`
- `parseBestiaryOverview`
- `parseBestiaryMonsterData`
- `parseBestiaryCharmsData`
- `parseBestiaryTracker`
- `parseBosstiaryInfo`
- `parseBosstiarySlots`
- `parseBosstiaryCooldownTimer`
- `parseCyclopediaCharacterInfo`
- `parseCyclopediaItemDetail`
- `parseCyclopediaHousesInfo`
- `parseCyclopediaHouseList`
- `parseCyclopediaHouseAuctionMessage`

## 3) Dispatch C++ para Lua

`game.cpp` converte payload parseado em callbacks Lua:
- `onParseBestiaryRaces`
- `onParseBestiaryOverview`
- `onUpdateBestiaryMonsterData`
- `onUpdateBestiaryCharmsData`
- `onParseSendBosstiary`
- `onParseBosstiarySlots`
- `onParseCyclopediaCharacterGeneralStats`
- `onParseCyclopediaCharacterCombatStats`
- `onParseCyclopediaCharacterBadges`
- `onCyclopediaCharacterRecentDeaths`
- `onCyclopediaCharacterRecentKills`
- `onUpdateCyclopediaCharacterItemSummary`
- `onParseCyclopediaCharacterAppearances`
- `onParseItemDetail`

## 4) OpCodes relevantes
Em `protocolcodes.h` há opcodes específicos para Cyclopedia/Bosstiary, incluindo:
- `GameServerBosstiaryData`
- `GameServerBosstiarySlots`
- `GameServerBosstiaryInfo`
- `GameServerCyclopediaItemDetail`

## 5) Exemplo de uso (Lua)
```lua
-- Abrir bestiary e pedir dados
showBestiary()
g_game.requestBestiary()

-- Buscar por categoria com pesquisa server-side
g_game.requestBestiaryOverview("Result", true, { 101, 205, 980 })

-- Pedir detalhe da criatura
g_game.requestBestiarySearch(101)

-- Atualizar tracker
g_game.sendStatusTrackerBestiary(101, true)
```

## 6) Limitações conhecidas
- `parseBestiaryEntryChanged` e `parseBosstiaryEntryChanged` possuem implementação mínima (quase no-op).
- Vários campos dependem de `clientVersion` e feature flags; ambientes híbridos podem gerar incompatibilidades de payload.
