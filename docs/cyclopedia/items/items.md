# Cyclopedia Items

## 1) Arquitetura
Arquivos principais:
- `otclient/modules/game_cyclopedia/tab/items/items.lua`
- `otclient/modules/game_cyclopedia/tab/items/items.otui`
- `otclient/src/protobuf/appearances.proto` (flags de item/categoria)
- `otclient/src/client/protocolgameparse.cpp` (`parseCyclopediaItemDetail`)

Estruturas base:
- `Cyclopedia.Items` (estado de filtros e operações)
- `Cyclopedia.CategoryItems` (mapeamento de categorias, IDs)
- cache local em JSON por personagem:
  - `/characterdata/<playerId>/itemprices.json`
  - chaves: `customSalePrices`, `primaryLootValueSources`, `dropTrackerItems`

## 2) Categorias e enums

Categorias em Lua (`CategoryItems`) alinham-se com `ITEM_CATEGORY` de protobuf, incluindo:
- Armors, Amulets, Boots, Containers
- Potions, Runes
- Weapons por tipo
- Creature Products, Soul Cores, Gold, Unsorted

`appearances.proto` também expõe `AppearanceFlagCyclopedia` para metadados de cyclopedia por item.

## 3) Fluxo de carregamento e render

### Abertura
`showItems()`:
- inicializa filtros (`VocFilter`, `LevelFilter`, mão 1/2, classificação)
- liga handlers de fonte de valor (NPC x Market)
- carrega categorias e seleciona foco padrão

### Lista
`FillItemList()` e `internalCreateItem(data)`:
- lê `ThingType` por categoria
- aplica filtros ativos
- monta widgets de item com click para detalhamento

### Detalhe
`Cyclopedia.loadItemDetail(itemId, descriptions)`:
- atualiza painel com item, descrições e valores
- chamado após parse C++ de `CyclopediaItemDetail`

### Inspeção integrada
`Cyclopedia.Items.onInspection(inspectType, itemName, item, descriptions)`:
- quando item é inspecionado via jogo, reusa renderer da Cyclopedia.

## 4) Busca, filtros e ordenação

Funções principais:
- `Cyclopedia.ItemSearch(text, clearTextEdit)`
- `Cyclopedia.selectItemCategory(id)`
- `Cyclopedia.vocationFilter(value)`
- `Cyclopedia.levelFilter(value)`
- `Cyclopedia.handFilter(h1Val, h2Val)`
- `Cyclopedia.classificationFilter(data)`
- `Cyclopedia.applyFilters()`

Filtros aplicados por `internalCreateItem` consideram:
- vocation restriction (`marketData.restrictVocation`)
- level requirement
- handed slot
- classification tier/class

## 5) Fontes de preço e valor resultante

Pipeline em `showItemPrice/getCurrentItemValue/getResultGoldValue`:
1. preço customizado do usuário (prioridade máxima)
2. fonte selecionada (NPC/market)
3. fallback entre fontes quando ausente

Observações:
- média de market está **TODO** (`getMarketOfferAverages` retorna 0 atualmente)
- sistema foi preparado para integração com `game_market` (estatísticas históricas)

## 6) Integrações especiais

### Drop Tracker / Quick Loot
Funções:
- `addToDropTracker`, `removeFromDropTracker`, `removeAllFromDropTrackerDirectly`
- `addToQuickSellWhitelist`, `removeFromQuickSellWhitelist`

Essas listas são persistidas no mesmo JSON de perfil.

### Party loot sync
- `Cyclopedia.Items.sendPartyLootItems()` envia lista de itens relevantes para rastreamento/compartilhamento.

## 7) Limitações
- cálculo de média de market não implementado totalmente.
- forte dependência de dados de `ThingType` + marketData; itens custom sem metadata podem cair em fallback genérico.
