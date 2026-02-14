# Sistema PREY — Visão Geral Completa

## Escopo analisado
A varredura foi feita em **cliente OTClient** e **servidor CrystalServer**, com foco em:
- módulo UI (`game_prey`)
- protocolo (opcodes cliente/servidor)
- persistência (`player_prey`)
- aplicação real de bônus (XP/dano/defesa/loot)
- integração com systems adjacentes (Cyclopedia, Store summary, resource balance)

## Arquivos diretamente envolvidos

### Cliente (OTClient)
- `otclient/modules/game_prey/prey.lua`
- `otclient/modules/game_prey/prey.otui`
- `otclient/modules/game_prey/prey.otmod`
- `otclient/modules/game_features/features.lua`
- `otclient/src/client/protocolcodes.h`
- `otclient/src/client/protocolgame.h`
- `otclient/src/client/protocolgamesend.cpp`
- `otclient/src/client/protocolgameparse.cpp`
- `otclient/src/client/game.h`
- `otclient/src/client/game.cpp`
- `otclient/src/client/luafunctions.cpp`
- `otclient/src/client/const.h`
- `otclient/src/client/staticdata.h`
- `otclient/modules/game_cyclopedia/tab/character/character.lua`
- `otclient/modules/game_cyclopedia/tab/character/character.otui`

### Servidor (CrystalServer)
- `crystalserver/src/io/ioprey.hpp`
- `crystalserver/src/io/ioprey.cpp`
- `crystalserver/src/creatures/players/player.hpp`
- `crystalserver/src/creatures/players/player.cpp`
- `crystalserver/src/server/network/protocol/protocolgame.hpp`
- `crystalserver/src/server/network/protocol/protocolgame.cpp`
- `crystalserver/src/game/game.cpp`
- `crystalserver/src/io/functions/iologindata_load_player.cpp`
- `crystalserver/src/io/functions/iologindata_save_player.cpp`
- `crystalserver/src/io/iologindata.cpp`
- `crystalserver/src/lua/functions/creatures/player/player_functions.cpp`
- `crystalserver/src/config/configmanager.cpp`
- `crystalserver/config.lua.dist`
- `crystalserver/data/events/scripts/player.lua`
- `crystalserver/data/scripts/eventcallbacks/monster/ondroploot_prey.lua`
- `crystalserver/data/migrations/18.lua`

## Módulos UI relacionados
- `game_prey`: janela principal, tracker, seleção de criaturas, rerolls, lock/auto reroll.
- `game_cyclopedia`: exibe contagem de slots permanentes e wildcards no resumo da Store.

## Classes/estruturas principais
- Servidor:
  - `PreySlot`
  - `IOPrey`
  - enums: `PreyDataState_t`, `PreyBonus_t`, `PreyAction_t`, `PreyOption_t`, `PreySlot_t`
- Cliente:
  - parse via `ProtocolGame`
  - struct `PreyMonster`
  - enums em `Otc::*` para estado/ação/opção/bônus

## Inicialização do sistema

### Servidor
- Durante load de player, o servidor carrega prey persistido (`loadPlayerPreyClass`) e, em seguida, chama `initializePrey()` em `loadPlayerInitializeSystem`.
- No login (`ProtocolGame::login` flow), envia preços (`sendPreyPrices`) e dados de slots (`player->sendPreyData`).

### Cliente
- `game_prey` carrega com `@onLoad: init()` em `prey.otmod`.
- `init()` instancia `preyWindow` (`g_ui.displayUI('prey')`) e o mini tracker (`PreyTracker`).
- O botão só aparece se `GamePrey` estiver habilitado (feature gate por versão >= 1100).

## Armazenamento e atualização de dados
- Persistência SQL por slot em `player_prey`:
  - estado, raceId selecionado, tipo de bônus, raridade, percentual, tempo, free reroll timestamp, monster list (blob serializado).
- Runtime:
  - `Player::preys` mantém até 3 slots.
  - Atualizações por ações do usuário (`parsePreyAction`) e por passagem de tempo (`checkPlayerPreys`).
- Cliente recebe updates incrementais por slot via opcode de prey data e de time-left/free-reroll.

## Assets principais
Pasta: `otclient/data/images/game/prey/`
- ícones de bônus: `prey_damage`, `prey_defense`, `prey_xp`, `prey_loot`
- variações “big”: `prey_bigdamage`, `prey_bigdefense`, `prey_bigxp`, `prey_bigloot`
- controle visual: `prey_reroll`, `prey_reroll_blocked`, `prey_select`, `prey_select_blocked`, `prey_choose`, `prey_choose_blocked`
- moeda/recurso: `prey_gold`, `prey_wildcard`
- outros: `prey_star`, `prey_nostar`, `prey_biginactive`, `prey_bignobonus`, `icon-prey-widget`

## Strings/textos específicos do sistema
No cliente há textos hardcoded para:
- descrições de botão e tooltips (reroll, lock prey, auto reroll, pick specific prey)
- mensagens de confirmação com custo em gold/wildcards
- labels de bônus (Damage Boost, XP Bonus etc.)

No servidor há mensagens de feedback operacional:
- falta de moedas/cards
- erro de seleção de criatura já em outro slot
- expiração de bônus e auto-lock/auto-reroll

## Observações de engenharia reversa (alto nível)
1. O fork Crystal integra Prey fortemente com **Task Hunting** (mesmas bases enum/opcode family e payload de preços combinado).
2. O cliente mantém `sendPreyRequest()`, porém no servidor o opcode equivalente aparece mapeado para `parseSendResourceBalance()` (não para refresh explícito de prey), sugerindo divergência/customização de protocolo.
3. Há sobreposição de opcodes em contextos distintos (ex.: `0xEB` para client->server prey action e também server->client imbuement window), dependente de direção e parser.

## Exemplo de fluxo real (trecho)
```lua
-- otclient/modules/game_prey/prey.lua
function show()
  preyWindow:show()
  g_game.preyRequest()
end
```

## Pontos críticos e limitações gerais
- Forte dependência da paridade protocolo cliente/servidor.
- Parte das regras de UI/custo no cliente ainda hardcoded.

## Sugestões gerais
- Consolidar documentação de opcodes e estados num único contrato versionado.

## Diagrama macro
```text
[DB player_prey] <-> [IOLoginData] -> [Player::preys]
      -> [IOPrey rules] -> [ProtocolGame server]
      -> [ProtocolGame client parse]
      -> [Lua game_prey] -> [OTUI]
      -> [Combat/XP/Loot effects]
```
