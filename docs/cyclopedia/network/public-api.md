# API pública relevante da Cyclopedia

## 1) Funções para abrir a Cyclopedia

### `toggle(defaultWindow)` (Lua, `game_cyclopedia.lua`)
- **Parâmetros:** `defaultWindow: string|nil` (`items`, `bestiary`, `character`, etc.)
- **Retorno:** `void`
- **Uso:** abre/fecha janela principal.
- **Dependências:** `controllerCyclopedia.ui`, `show()`, `hide()`.

### `show(defaultWindow)` (Lua)
- **Parâmetros:** `defaultWindow: string|nil`
- **Retorno:** `void`
- **Uso:** mostra Cyclopedia e seleciona tab inicial.

### `SelectWindow(type, isBackButtonPress)` (Lua)
- **Parâmetros:**
  - `type: string`
  - `isBackButtonPress: bool|nil`
- **Retorno:** `void`
- **Uso:** troca tab ativa e mantém histórico.

## 2) Busca / filtros / paginação

### Bestiary
- `Cyclopedia.BestiarySearch()`
- `Cyclopedia.BestiarySearchText(text)`
- `Cyclopedia.changeBestiaryPage(prev, next)`
- `Cyclopedia.verifyBestiaryButtons()`

### Items
- `Cyclopedia.ItemSearch(text, clearTextEdit)`
- `Cyclopedia.vocationFilter(value)`
- `Cyclopedia.levelFilter(value)`
- `Cyclopedia.handFilter(h1Val, h2Val)`
- `Cyclopedia.classificationFilter(data)`
- `Cyclopedia.applyFilters()`
- `Cyclopedia.selectItemCategory(id)`

### Bosstiary
- `Cyclopedia.BosstiarySearchText(text, clear)`
- `Cyclopedia.changeBosstiaryFilter(widget, isCheck)`
- `Cyclopedia.changeBosstiaryPage(prev, next)`

## 3) Exibição de detalhes

### Item detail
- `Cyclopedia.loadItemDetail(itemId, descriptions)`
  - renderiza detalhes após callback de rede.

### Creature detail
- `Cyclopedia.loadBestiarySelectedCreature(data)`
  - popula painel completo da criatura.

### Character detail
- `Cyclopedia.loadCharacterGeneralStats(data, skills)`
- `Cyclopedia.loadCharacterCombatStats(...)`
- `Cyclopedia.loadCharacterAppearances(color, outfits, mounts, familiars)`
- `Cyclopedia.loadCharacterItems(data)`

## 4) Atualização/inserção de entradas (rede)

### Requests públicos (`g_game`)
- `requestBestiary()`
- `requestBestiaryOverview(catName, search, raceIds)`
- `requestBestiarySearch(raceId)`
- `requestCharacterInfo(playerId, type, entriesPerPage, page)`
- `requestBosstiaryInfo()`
- `requestBossSlootInfo()`
- `requestBossSlotAction(action, raceId)`
- `sendStatusTrackerBestiary(raceId, status)`
- `sendCyclopediaHouseAuction(type, houseId, timestamp, bidValue, name)`

## 5) Exemplos rápidos

```lua
-- Abrir direto no tab de itens
toggle("items")

-- Buscar criatura por texto (bestiary)
Cyclopedia.BestiarySearchText("dragon")
Cyclopedia.BestiarySearch()

-- Solicitar info de personagem (stats gerais)
g_game.requestCharacterInfo(g_game.getLocalPlayer():getId(), Otc.CYCLOPEDIA_CHARACTERINFO_GENERALSTATS, 0, 0)

-- Solicitar detalhe de item via inspeção
Cyclopedia.loadItemDetail(3031, { {"Weight", "1.00 oz"}, {"Description", "A gold coin."} })
```

## 6) Observação
A maior parte dessa API é pública para Lua no cliente; inserir novos tipos de entrada requer:
1. opcode + parser C++
2. `Game::process*` callback
3. binding/evento Lua
4. render OTUI/Lua.
