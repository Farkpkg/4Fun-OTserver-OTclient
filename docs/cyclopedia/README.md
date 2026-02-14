# Cyclopedia — Documentação Técnica Completa (OTClient)

## Escopo analisado
Esta documentação cobre o stack completo da Cyclopedia no cliente, incluindo:

- Tabs e fluxos principais (`items`, `bestiary`, `charms`, `map`, `houses`, `character`, `bosstiary`, `boss slots`, `magical archives`)
- Integração de dados com C++ (`Game`, `ProtocolGame`, structs de `staticdata.h`)
- Protocolos de request/parse para dados de Cyclopedia
- Busca, filtros e paginação
- Assets de UI/sprites/icons
- Integrações relacionadas: spells, achievements/quests e looktypes/outfits

## Organização desta pasta
- `monsters/monsters.md` — Bestiary/Bosstiary, tracker, progressão, looktype de criaturas.
- `items/items.md` — Catálogos de item, filtros, inspeção detalhada, fontes de valor.
- `spells/spells.md` — Spelllist/runes/potions (integração indireta com Cyclopedia).
- `achievements/achievements.md` — Achievements/quests integrados (estado atual e limitações).
- `ui/ui.md` — Arquitetura visual da Cyclopedia (OTUI/OTMod/Lua controller).
- `network/network.md` — Fluxo de rede e mensagens (requests/parsers/callbacks Lua).
- `assets/assets.md` — Inventário técnico de assets usados.
- `dependency-map/dependency-map.md` — Mapa textual de dependências e fluxo de dados fim a fim.

## Mapeamento global de arquivos-chave
### Núcleo Cyclopedia (Lua/OTUI)
- `otclient/modules/game_cyclopedia/game_cyclopedia.otmod`
- `otclient/modules/game_cyclopedia/game_cyclopedia.otui`
- `otclient/modules/game_cyclopedia/game_cyclopedia.lua`
- `otclient/modules/game_cyclopedia/cyclopedia_widgets.otui`
- `otclient/modules/game_cyclopedia/cyclopedia_pages.otui`
- `otclient/modules/game_cyclopedia/utils.lua`
- `otclient/modules/game_cyclopedia/tab/*/*.lua`
- `otclient/modules/game_cyclopedia/tab/*/*.otui`

### C++ (dados, protocol e ponte Lua)
- `otclient/src/client/game.cpp`
- `otclient/src/client/game.h`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolgame.h`
- `otclient/src/client/protocolcodes.h`
- `otclient/src/client/luafunctions.cpp`
- `otclient/src/client/luavaluecasts_client.cpp`
- `otclient/src/client/staticdata.h`
- `otclient/src/protobuf/appearances.proto`
- `otclient/src/protobuf/staticdata.proto`

### Integrações adjacentes
- `otclient/modules/game_spelllist/spelllist.lua`
- `otclient/modules/gamelib/spells.lua`
- `otclient/modules/game_questlog/game_questlog.lua`
- `otclient/modules/corelib/ui/tooltip.lua`
- `otclient/src/client/outfit.h` / `outfit.cpp`

## Notas de arquitetura
1. O cliente trabalha em duas camadas: **protocol/structs C++** e **render/UI Lua**.
2. A Cyclopedia consome dados via callbacks `g_game.onParse...` e `g_game.onUpdate...`.
3. Parte de achievements é local/estática (tabela `ACHIEVEMENTS` em Lua), não totalmente sincronizada com backend neste módulo.
4. O tab `magicalArchives` existe, mas no estado atual é basicamente placeholder visual.
