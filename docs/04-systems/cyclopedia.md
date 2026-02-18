# Cyclopedia System

## 1. Objetivo
Implementar no OTClient uma interface única de Cyclopedia (itens, bestiary/charms, bosstiary, character, map, house) e sincronizar os dados com o CrystalServer via opcodes dedicados de protocolo de jogo (não via extended opcode).

## 2. Escopo
Controla:
- Abertura/alternância da janela Cyclopedia e seleção de abas no client.
- Requisições de dados de Bestiary, Charms, Character, Bosstiary, Boss Slots e House para o servidor.
- Renderização de respostas de protocolo para essas abas.
- Atualização de tracker de bestiary/bosstiary.
- Persistência server-side de progresso de charms/tracker (em `player_charms`) e resumo/títulos/badges via KV.

Não controla:
- Lógica de market em tempo real para preço de itens da Cyclopedia (há TODO no client).
- Render final de respostas de houses no parser C++ do client (há TODO explícito no parse).
- Suporte completo de inspeção de personagens de terceiros (server restringe para o próprio personagem).

## 3. Localização no Código

### Server
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.hpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/creatures/players/player.cpp`
- `crystalserver/src/creatures/players/player.hpp`
- `crystalserver/src/creatures/players/cyclopedia/player_cyclopedia.cpp`
- `crystalserver/src/creatures/players/cyclopedia/player_cyclopedia.hpp`
- `crystalserver/src/creatures/players/cyclopedia/player_badge.cpp`
- `crystalserver/src/creatures/players/cyclopedia/player_badge.hpp`
- `crystalserver/src/creatures/players/cyclopedia/player_title.cpp`
- `crystalserver/src/creatures/players/cyclopedia/player_title.hpp`
- `crystalserver/src/io/iobestiary.cpp`
- `crystalserver/src/io/io_bosstiary.cpp`
- `crystalserver/src/io/functions/iologindata_load_player.cpp`
- `crystalserver/schema.sql`

### Client
- `otclient/modules/game_cyclopedia/game_cyclopedia.otmod`
- `otclient/modules/game_cyclopedia/game_cyclopedia.lua`
- `otclient/modules/game_cyclopedia/tab/bestiary/bestiary.lua`
- `otclient/modules/game_cyclopedia/tab/charms/charms.lua`
- `otclient/modules/game_cyclopedia/tab/character/character.lua`
- `otclient/modules/game_cyclopedia/tab/items/items.lua`
- `otclient/modules/game_cyclopedia/tab/bosstiary/bosstiary.lua`
- `otclient/modules/game_cyclopedia/tab/boss_slots/boss_slots.lua`
- `otclient/modules/game_cyclopedia/tab/house/house.lua`
- `otclient/modules/game_cyclopedia/tab/map/map.lua`
- `otclient/modules/game_cyclopedia/tab/magicalArchives/magicalArchives.lua`
- `otclient/src/client/protocolcodes.h`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/game.cpp`
- `otclient/src/client/luafunctions.cpp`

## 4. Fluxo de Execução Completo
1. O módulo `game_cyclopedia` é autoload no client e inicializa `controllerCyclopedia`.
2. Em `onGameStart`, o client cria botões na main panel (`Cyclopedia`, `Bosstiary`, `Boss Slot`) e registra callbacks de eventos parseados de protocolo.
3. Ao clicar no botão, `toggle(defaultWindow)` abre a janela e `SelectWindow` carrega a aba alvo (`showBestiary`, `showCharms`, `showCharacter`, etc.).
4. Cada aba dispara requisições específicas para o servidor:
   - Bestiary: `requestBestiary`, `requestBestiaryOverview`, `requestBestiarySearch`.
   - Charms: reaproveita `requestBestiary` para carregar charms/bestiary.
   - Character: `requestCharacterInfo` por tipo (stats, deaths, kills, itens, badges, títulos...).
   - Bosstiary: `requestBosstiaryInfo`.
   - Boss slots: `requestBossSlootInfo` e ações de slot.
   - House: usa `ClientCyclopediaHouseAuction` (quando as funções Lua de request existem).
   - Items: usa inspeção `inspectionObject(INSPECT_CYCLOPEDIA, itemId, count)` para receber detalhe.
5. O servidor recebe os opcodes no `parsePacketFromDispatcher` e delega para parse handlers de Cyclopedia/Bestiary/Bosstiary.
6. O servidor processa no `Game`/`Player`/IO (ex.: `playerCyclopediaCharacterInfo`, bestiary kill status, house auction, charms/tracker) e envia respostas.
7. O parser C++ do client (`protocolgameparse.cpp`) converte payload binário em estruturas e dispara callbacks Lua (`g_game.process...`/`g_lua.callGlobalField`).
8. A UI Lua da Cyclopedia renderiza dados finais (listas, progresso, trackers, detalhes, etc.).

## 5. Comunicação Client ⇄ Server
- Lista completa de opcodes utilizados
- Direção (Client → Server ou Server → Client)
- Estrutura real de payload

### Client → Server
- `0x2A` `ClientBestiaryTrackerStatus` (tracker bestiary/bosstiary)
  - Payload: `u16 raceId`, `u8 status`.
- `0xAD` `ClientCyclopediaHouseAuction`
  - Payload base: `u8 actionType`.
  - `actionType=0`: `string townName`.
  - `actionType=1`: `u32 houseId`, `u64 bidValue`.
  - `actionType=2`: `u32 houseId`, `u32 timestamp`.
  - `actionType=3`: `u32 houseId`, `u32 timestamp`, `string newOwner`, `u64 bidValue`.
  - `actionType=4|5|6|7`: `u32 houseId`.
- `0xAE` `ClientBosstiaryRequestInfo`
  - Payload: vazio.
- `0xAF` `ClientBosstiaryRequestSlotInfo`
  - Payload: vazio.
- `0xB0` `ClientBosstiaryRequestSlotAction`
  - Payload: `u8 action`, `u32 raceId`.
- `0xCD` `ClientInspectionObject` (usado pela aba Items para Cyclopedia detail)
  - Payload: `u8 inspectionType`, `u16 itemId`, `u8 itemCount`.
- `0xE1` `ClientBestiaryRequest`
  - Payload: vazio.
- `0xE2` `ClientBestiaryRequestOverview`
  - Payload: `u8 searchFlag`; se `1`, `u16 amount` + `u16 raceId[]`; se `0`, `string categoryName`.
- `0xE3` `ClientBestiaryRequestSearch`
  - Payload: `u16 raceId`.
- `0xE4` `ClientCyclopediaSendBuyCharmRune`
  - Payload: `u8 runeId`, `u8 action`, `u16 raceId`.
- `0xE5` `ClientCyclopediaRequestCharacterInfo`
  - Payload: `u32 characterId`, `u8 infoType`; para `RecentDeaths/RecentPvPKills` também `u16 entriesPerPage`, `u16 page`.

### Server → Client
- `0x61` `GameServerBosstiaryData`
  - Lista de bosses para Cyclopedia Bosstiary (id, categoria/rarity, kills, tracker status).
- `0x62` `GameServerBosstiarySlots`
  - Dados de pontos, bônus, slots 1/2/boosted, bosses desbloqueados.
- `0x73` `GameServerBosstiaryInfo`
  - Lista resumida de bosses com kills e tracker ativo.
- `0x76` `GameServerCyclopediaItemDetail`
  - Estrutura parseada: cabeçalhos fixos + item + `u8 descriptionsSize` + pares `string key`, `string value`.
- `0xB9` `GameServerBestiaryRefreshTracker`
  - Payload: `u8 trackerType(0 bestiary/1 boss)`, `u8 size`, para cada entrada: `u16 raceId`, `u32 kills`, `u16 first`, `u16 second`, `u16 last`, `u8 status`.
- `0xBD` `GameServerBosstiaryCooldownTimer`
  - Payload: `u16 count` + entradas (`u32 bossRaceId`, `u64 cooldown`).
- `0xC3` `GameServerCyclopediaHouseAuctionMessage`
  - Payload: `u32 houseId`, `u8 type`, opcional `u8`, `u8 index`.
- `0xC6` `GameServerCyclopediaHousesInfo`
  - Metadados de casas da conta (house atual, count, lista clientId etc.).
- `0xC7` `GameServerCyclopediaHouseList`
  - Lista de casas por estado (`Available|Rented|Transfer|MoveOut`) com campos condicionais de bid/owner/erros.
- `0xD5` `GameServerBestiaryRaces`
  - Payload: `u16 raceLast`; por raça: `string class`, `u16 total`, `u16 unlocked`.
- `0xD6` `GameServerBestiaryOverview`
  - Payload: `string raceName`, `u16 count`, por monstro: `u16 raceId`, progresso/ocorrência e bônus animus, + pontos animus.
- `0xD7` `GameServerBestiaryMonsterData`
  - Payload completo de monstro (kill progress, unlocks, loot, charms points, combate, localização).
- `0xD8` `GameServerBestiaryCharmsData`
  - Payload de charms (custo reset, lista de charms/tier/unlock/assign, slots disponíveis, races elegíveis).
- `0xD9` `GameServerBestiaryEntryChanged`
  - Payload: `u16 raceId`.
- `0xDA` `GameServerCyclopediaCharacterInfoData`
  - Payload multiplexado por `characterInfoType` + `errorCode` + bloco específico (general/combat/deaths/kills/items/badges/titles/offence/defence/misc).
- `0xE6` `GameServerSendBosstiaryEntryChanged`
  - Payload: `u32 bossId`.

## 6. Estruturas de Dados
- Classes C++ envolvidas
  - `ProtocolGame`, `Game`, `Player`, `PlayerCyclopedia`, `PlayerBadge`, `PlayerTitle`, `IOBestiary`, `IOBosstiary`.
  - Estruturas de payload do client parse (`BestiaryMonsterData`, `BestiaryCharmsData`, `CyclopediaCharacterGeneralStats`, `CyclopediaCharacterCombatStats`, `BosstiarySlotsData`, etc.).
- Tabelas Lua envolvidas
  - `Cyclopedia` (namespace do módulo), `Cyclopedia.Items`, `Cyclopedia.BossSlots`, `Cyclopedia.House`, listas de categorias/filtros e dados de UI por aba.
- Estruturas internas
  - Tracker bestiary/boss em memória de `Player` (set de `MonsterType`) com refresh por `refreshCyclopediaMonsterTracker`.
  - KV scopes: `summary`, `titles`, `badges`, `boss.cooldown`, `daily-reward`, etc.
- Tabelas SQL (persistência)
  - `player_charms` (charm points/bits/blob charms/tracker_list).
  - `player_deaths` (fonte para RecentDeaths e RecentPvPKills).
  - `player_hirelings` (resumo Cyclopedia).
  - `kv_store` (persistência geral de KV para summary/titles/badges/cooldown e correlatos).
  - Tabelas de inventário/stash/depot usadas indiretamente em Item Summary (`player_items`, `player_depotitems`, `player_inboxitems`, `player_stash`).

## 7. Dependências Cruzadas
- Bestiary: núcleo de categorias, kill status, entry changed e tracker.
- Charms: compra/atribuição/reset e recursos de charm.
- Bosstiary: listas, progressão, slots, boosted boss, cooldown timer.
- House system: listagem, bid, transfer, move out e mensagens de erro/sucesso.
- Achievements: `CYCLOPEDIA_CHARACTERINFO_ACHIEVEMENTS` encaminha para `player->achiev()->sendUnlockedSecretAchievements()`.
- Items/Inspection: aba Items depende de `ClientInspectionObject` com `INSPECT_CYCLOPEDIA`.
- Titles/Badges: cálculo e envio no bloco Character.
- Task Hunting / Prey: influencia títulos e dados relacionados (dependência indireta em check de título e kill progression).

## 8. Pontos de Extensão Reais
- Novos blocos `CyclopediaCharacterInfoType_t` no par request/response (`parseCyclopediaCharacterInfo` + `sendCyclopediaCharacter...`).
- Enriquecer payload de house e concluir callbacks Lua para `parseCyclopediaHouseAuctionMessage`, `parseCyclopediaHousesInfo`, `parseCyclopediaHouseList`.
- Expandir aba Items para preço de market real (TODO explícito em `Cyclopedia.Items.getMarketOfferAverages`).
- Adicionar novas regras de títulos/badges em `PlayerTitle::check...` e `PlayerBadge::checkAndUpdateNewBadges`.
- Estender tracker com novos critérios/status mantendo opcode `0xB9` compatível.

## 9. Riscos Técnicos
- Sincronização
  - House parser client C++ possui TODO e pode divergir da UI Lua da aba house.
  - Funções Lua `g_game.requestShowHouses/requestBidHouse/...` são chamadas na aba house, mas não há binding explícito correspondente encontrado no core atual.
- Volume de dados
  - Item summary e bestiary podem trafegar listas extensas (inventário/depot/stash e centenas de criaturas).
- Performance
  - Consultas assíncronas de death/kill history por página e construção de payloads grandes por request.
  - Requisições repetidas de bestiary no tracker ao abrir/forçar refresh.
- Dependência circular
  - Cyclopedia depende de múltiplos subsistemas (bestiary, bosstiary, achievements, house, inventory, KV), aumentando risco de regressões cruzadas.

## 10. Status
⚠ Parcial

Justificativa objetiva do status parcial:
- Parsing client de houses (`parseCyclopediaHouseAuctionMessage`, `parseCyclopediaHousesInfo`, `parseCyclopediaHouseList`) tem TODO sem integração Lua completa.
- `parseBestiaryEntryChanged` no client ainda contém TODO de uso.
- Aba house chama funções `g_game.request...` sem definição/binding explícitos auditados no client core.
- Aba Items possui TODO para média de market real.
