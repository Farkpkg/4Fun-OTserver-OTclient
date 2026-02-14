# Etapa 1 — Mapeamento Global (arquivos, classes, enums, IDs)

## 1) Arquivos/módulos diretamente relacionados

### Lua/OTUI
- `modules/game_cyclopedia/*`
- `modules/game_cyclopedia/tab/bestiary/*`
- `modules/game_cyclopedia/tab/items/*`
- `modules/game_cyclopedia/tab/character/*`
- `modules/game_cyclopedia/tab/charms/*`
- `modules/game_cyclopedia/tab/house/*`
- `modules/game_cyclopedia/tab/bosstiary/*`
- `modules/game_cyclopedia/tab/boss_slots/*`
- `modules/game_cyclopedia/tab/map/*`
- `modules/game_cyclopedia/tab/magicalArchives/*`

### C++ classes/funções
- `ProtocolGame::{parseBestiary*, parseBosstiary*, parseCyclopedia*}`
- `ProtocolGame::{sendRequestBestiary*, sendCyclopedia*}`
- `Game::{requestBestiary*, process*Cyclopedia*}`
- `luafunctions.cpp` bindings `g_game.request...` / `g_game.send...`
- `luavaluecasts_client.cpp` conversão struct -> Lua

### Dados/protobuf
- `appearances.proto` (`ITEM_CATEGORY`, `AppearanceFlagCyclopedia`)
- `staticdata.proto` (`Creature`, `Achievement`, `Quest`, `Outfit`)
- `staticdata.h` structs de Cyclopedia, Bestiary e Character Info

## 2) Enums/constantes importantes

### Protocol/opcodes
- `GameServerBosstiaryData`
- `GameServerBosstiarySlots`
- `GameServerBosstiaryInfo`
- `GameServerCyclopediaItemDetail`

### Character info types
`Otc::CyclopediaCharacterInfoType_t` (stats, combat, itens, aparências, kills/deaths etc.)

### House auction
`Otc::CyclopediaHouseState_t` e `Otc::CyclopediaHouseAuctionType_t`

### Item categories
`ITEM_CATEGORY` (protobuf) + espelho em `Cyclopedia.CategoryItems` (Lua)

## 3) IDs e estruturas de armazenamento
- `raceId` (bestiary/bosstiary)
- `itemId` (items/detail)
- `lookType/lookItem` (outfit/appearance)
- `playerId` (requestCharacterInfo)
- cache local por personagem:
  - tracker data
  - filtros
  - itemprices.json

## 4) Como dados são carregados/armazenados/exibidos
1. Request enviado por `g_game`.
2. Parser C++ decodifica payload.
3. `Game::process*` invoca evento Lua.
4. Lua salva estado em tabelas `Cyclopedia.*`.
5. UI atualiza listas/cards/progressbars/tooltips.

## 5) Busca, filtros e paginação
- Busca em bestiary usa combinação client-side + request server-side por raceIds.
- Itens aplicam filtros client-side em lista de ThingTypes.
- Paginação é manual (particionamento em tabelas por página).

## 6) Dependências entre módulos
- `game_cyclopedia` <- `g_game`, `g_ui`, `g_things`, `game_mainpanel`, `game_interface`
- Integração com `game_spelllist`, `game_questlog`, `game_outfit` (relacionadas ao domínio).
