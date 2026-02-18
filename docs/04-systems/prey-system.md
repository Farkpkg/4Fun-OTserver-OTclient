# Prey System (OTClient + CrystalServer)

> Documento gerado por auditoria direta do código atual. Não há suposições de upstream.

## 1) Mapeamento completo de arquivos

### 1.1 Client

| Arquivo | Papel no sistema | Dependências diretas |
|---|---|---|
| `otclient/modules/game_prey/prey.otmod` | Registro/autoload do módulo Prey. | `client_topmenu`, `prey.lua` |
| `otclient/modules/game_prey/prey.otui` | Definição da janela, painéis de estado, botões, tracker visual, barras de tempo e campos de preço. | callbacks Lua em `modules.game_prey.*` |
| `otclient/modules/game_prey/prey.lua` | Controller/UI principal: toggle da janela, render dos estados (`locked/inactive/active/selection/list`), envio de ações, confirmações de reroll, pesquisa/lista de criaturas, atualização de cooldown/recursos. | `g_game`, `g_ui`, `game_mainpanel`, `game_interface` |
| `otclient/src/client/protocolcodes.h` | Enum de opcodes Prey C→S e S→C. | `ProtocolGame` send/parse |
| `otclient/src/client/protocolgamesend.cpp` | Serialização de pacotes `ClientPreyAction` e `ClientPreyRequest`. | `ProtocolGame`, `OutputMessage` |
| `otclient/src/client/protocolgameparse.cpp` | Parse dos pacotes `GameServerSendPreyFreeRerolls`, `GameServerSendPreyTimeLeft`, `GameServerSendPreyData`, `GameServerSendPreyRerollPrice`; despacho para Lua (`g_game.onPrey*`). | `g_lua`, `getOutfit`, `const.h` |
| `otclient/src/client/protocolgame.h` | Assinaturas de send/parse Prey. | parser/sender C++ |
| `otclient/src/client/game.cpp` e `game.h` | API exposta à Lua (`g_game.preyAction`, `g_game.preyRequest`). | `ProtocolGame` |
| `otclient/src/client/luafunctions.cpp` | Bind Lua das APIs `preyAction` e `preyRequest`. | `Game` |
| `otclient/src/client/const.h` | Enums do domínio Prey no client (state, action, option, bonus, unlock state, feature flag). | Parser/UI |
| `otclient/src/client/staticdata.h` | Struct `PreyMonster` (nome + outfit) usada no parse. | `protocolgameparse.cpp` |
| `otclient/modules/game_features/features.lua` | Habilita `GamePrey` para versões >= 1100. | `g_game.enableFeature` |

### 1.2 Server

| Arquivo | Papel no sistema | Dependências diretas |
|---|---|---|
| `crystalserver/src/io/ioprey.hpp` | Enums, structs/classes centrais (`PreySlot`, `TaskHuntingSlot`, `TaskHuntingOption`, `IOPrey`). | `Player`, `NetworkMessage` |
| `crystalserver/src/io/ioprey.cpp` | Regras de sorteio/lista, progressão de raridade, processamento das ações (`parsePreyAction`), expiração por stamina hunting (`checkPlayerPreys`). | `g_game`, `g_monsters`, `g_configManager`, `Player` |
| `crystalserver/src/server/network/protocol/protocolgame.cpp` | Recepção de ação C→S (`parsePreyAction`) e envio S→C (`sendPreyTimeLeft`, `sendPreyData`, `sendPreyPrices`). | `Game`, `Player`, `IOPrey` |
| `crystalserver/src/server/network/protocol/protocolgame.hpp` | Assinaturas dos handlers de Prey. | `PreySlot` |
| `crystalserver/src/game/game.cpp` | Encaminha `playerPreyAction` para `IOPrey::parsePreyAction`. | `IOPrey` |
| `crystalserver/src/creatures/players/player.hpp` e `player.cpp` | Estado runtime do jogador (`preys`, `preyCards`), init de slots, envio para client, custos, blacklist e busca de slot por race. | `IOPrey`, `ProtocolGame` |
| `crystalserver/src/creatures/combat/combat.cpp` | Aplica bônus de dano/defesa do Prey durante cálculo de combate. | `Player::getPreyWithMonster` |
| `crystalserver/src/lua/functions/creatures/player/player_functions.cpp` | Ponte Lua para `removePreyStamina`, `getPreyExperiencePercentage`, `getPreyLootPercentage`, unlock de 3º slot (`preyThirdSlot`). | `IOPrey`, `Player` |
| `crystalserver/data/events/scripts/player.lua` | Redução temporal do Prey enquanto caça (`removePreyStamina`) e aplicação do bônus de XP em `onGainExperience`. | callbacks Player Lua |
| `crystalserver/data/scripts/eventcallbacks/monster/ondroploot_prey.lua` | Aplicação do bônus de loot via callback de drop (`getPreyLootPercentage`). | EventCallback monster drop |
| `crystalserver/src/io/functions/iologindata_load_player.cpp` | Carregamento da persistência (`prey_wildcard` + tabela `player_prey`). | DB + `Player::setPreySlotClass` |
| `crystalserver/src/io/functions/iologindata_save_player.cpp` | Persistência (`prey_wildcard`, `player_prey`). | DB + serialização `monster_list` |
| `crystalserver/schema.sql` | Estruturas SQL (`players.prey_wildcard`, `player_prey`). | MySQL schema |
| `crystalserver/src/config/config_enums.hpp` e `configmanager.cpp` | Chaves de configuração (`PREY_*`) e defaults. | config manager |
| `crystalserver/src/creatures/monsters/monsters.hpp` | Flags de monstro usadas no sorteio (`isPreyable`, `isPreyExclusive`). | `IOPrey` |
| `crystalserver/src/lua/functions/creatures/monster/monster_type_functions.cpp` e `data/scripts/lib/register_monster_type.lua` | Exposição/configuração Lua das flags `isPreyable` e `isPreyExclusive`. | definição de monstros |
| `crystalserver/data/modules/scripts/gamestore/init.lua` | Compra store de wildcards e unlock de slots (`player:preyThirdSlot(true)`). | GameStore |
| `crystalserver/data/migrations/3.lua`, `18.lua`, `33.lua`, `56.lua` | Histórico de migração das tabelas/colunas de prey. | schema migration |

---

## 2) Arquitetura geral (trigger e fluxo C ⇄ S)

## 2.1 Trigger de inicialização
- O módulo client `game_prey` sobe no load; conecta eventos `onPrey*` e cria janela/tracker.
- O botão da UI só é criado quando `GamePrey` está ativo.
- `GamePrey` é habilitado pelo client para versões >= 1100.
- No login server (`ProtocolGame::login`), o servidor envia:
  1) preços de Prey (`sendPreyPrices`),
  2) estado de todos os slots (`player->sendPreyData`).

## 2.2 Fluxo lógico textual (real do código)

`Player abre janela Prey`  
→ Client chama `g_game.preyRequest()`  
→ Envia opcode `ClientPreyRequest (0xED)`  
→ Server trata em `case 0xED` como `parseSendResourceBalance()`  
→ Server envia resources balance (gold/bank/prey cards/etc)  
→ UI atualiza saldos.

`Player executa ação Prey (reroll/seleção/opção)`  
→ Client chama `g_game.preyAction(slot, action, indexOrRace)`  
→ Envia `ClientPreyAction (0xEB)` com payload por ação  
→ Server valida em `IOPrey::parsePreyAction` (slot, estado, recursos, duplicidade, monstro preyable etc.)  
→ Server atualiza estado do slot  
→ Server chama `player->reloadPreySlot(slot)`  
→ Server envia `GameServerSendPreyData (0xE8)` + resources balance  
→ Client parseia e dispara `onPreyLocked/onPreyInactive/onPreyActive/...`  
→ `prey.lua` re-renderiza aba e tracker.

`Durante caça`  
→ Evento Lua de stamina chama `player:removePreyStamina(segundos)`  
→ Binding C++ chama `IOPrey::checkPlayerPreys(player, amount)`  
→ Reduz `bonusTimeLeft`, envia `GameServerSendPreyTimeLeft (0xE7)`; ou expira slot e reseta estado conforme opção (none/auto reroll/locked).

`Aplicação de bônus`  
- Dano/defesa: no C++ de combate (`combat.cpp`).
- XP: no evento Lua `Player:onGainExperience` via `player:getPreyExperiencePercentage(raceId)`.
- Loot: callback Lua `MonsterOnDropLootPrey` via `player:getPreyLootPercentage(raceId)`.

## 2.3 Opcodes e payloads

### Client → Server

- `0xEB` (`ClientPreyAction`)
  - base: `u8 slot`, `u8 actionType`
  - se `actionType == 2 (MONSTERSELECTION)` ou `5 (OPTION)`: `u8 index`
  - se `actionType == 4 (CHANGE_FROM_ALL)`: `u16 raceId`

- `0xED` (`ClientPreyRequest`)
  - sem payload adicional.
  - No código atual do server, este opcode aciona `parseSendResourceBalance()` (não dispara `sendPreyData` diretamente).

### Server → Client

- `0xE6` (`GameServerSendPreyFreeRerolls`): `u8 slot`, `u16 timeLeft`.
- `0xE7` (`GameServerSendPreyTimeLeft`): `u8 slot`, `u16 timeLeft`.
- `0xE8` (`GameServerSendPreyData`):
  - `u8 slot`, `u8 state`, payload variável por state:
    - Locked: `u8 unlockState`, `u32 nextFreeReroll`, `u8 wildcards` (protocol novo)
    - Inactive: `u32 nextFreeReroll`, `u8 wildcards`
    - Active: `monster(name+outfit)`, `u8 bonusType`, `u16 bonusValue`, `u8 bonusGrade`, `u16 timeLeft`, `u32 nextFreeReroll`, `u8 option`
    - Selection: lista de monstros (name+outfit), `nextFreeReroll`, `wildcards`
    - SelectionChangeMonster: bônus atual + lista de monstros + `nextFreeReroll`, `wildcards`
    - ListSelection: `u16 raceCount`, `u16 raceId[]`, `nextFreeReroll`, `wildcards`
- `0xE9` (`GameServerSendPreyRerollPrice`): `u32 goldRerollPrice`, `u8 wildcardPrice`, `u8 directSelectPrice` (+ campos task hunting no protocolo novo).

---

## 3) Estrutura de dados

## 3.1 Enums principais

### Client (`otclient/src/client/const.h`)
- `PreyState_t`: locked/inactive/active/selection/selection_change/list/wildcard.
- `PreyBonusType_t`: damage boost, damage reduction, xp bonus, improved loot.
- `PreyAction_t`: list reroll, bonus reroll, monster selection, request all monsters, change from all, option.
- `PreyOption_t`: untoggle, auto reroll, lock prey.
- `PreyUnlockState_t`: store+premium / store / none.

### Server (`crystalserver/src/io/ioprey.hpp`)
- `PreySlot_t`, `PreyDataState_t`, `PreyBonus_t`, `PreyOption_t`, `PreyAction_t`.
- Também coexistem enums de `TaskHunting` no mesmo subsistema.

## 3.2 Classes/structs

- `PreySlot`
  - Campos: `id`, `bonus`, `state`, `option`, `raceIdList`, `bonusRarity`, `selectedRaceId`, `bonusPercentage`, `bonusTimeLeft`, `freeRerollTimeStamp`.
  - Regras internas:
    - `isOccupied()` => `selectedRaceId != 0 && bonusTimeLeft > 0`
    - `eraseBonus(maintainBonus)` limpa estado e pode preservar tipo/valor de bônus.
    - `reloadBonusType()`, `reloadBonusValue()`, `reloadMonsterGrid(...)`.

- `IOPrey`
  - `checkPlayerPreys(...)`: tick/expiração/renovação automática.
  - `parsePreyAction(...)`: máquina de estado server-side das ações do usuário.

- `PreyMonster` (client)
  - `name`, `outfit`; usado para parse/render das listas.

## 3.3 Persistência (SQL + runtime)

### Tabela `players`
- Coluna `prey_wildcard` (saldo de prey cards/wildcards).
- Carrega em login (`addPreyCards`) e salva no update do player.

### Tabela `player_prey`
- `player_id`, `slot`, `state`, `raceid`, `option`, `bonus_type`, `bonus_rarity`, `bonus_percentage`, `bonus_time`, `free_reroll`, `monster_list`.
- `monster_list` é blob serializado (`u16[]` de race IDs).
- Carregado por `loadPlayerPreyClass()` e salvo por `savePlayerPreyClass()`.

### Estado runtime no Player
- `std::vector<std::unique_ptr<PreySlot>> preys;`
- `uint64_t preyCards;`

---

## 4) Interface (Client)

## 4.1 Criação da janela
- `init()` em `prey.lua`:
  - `preyWindow = g_ui.displayUI('prey')`
  - criação de miniwindow tracker (`PreyTracker`) no painel direito.
  - registro dos listeners `onPrey*`.

## 4.2 Componentes relevantes (`prey.otui`)
- `PreyWindow` com `slot1/slot2/slot3`.
- Painéis por estado:
  - `LockedPreyPanel`
  - `InactivePreyPanel`
  - `ActivePreyPanel`
- Componentes de ação:
  - botão reroll de lista (`rerollButton`)
  - botão pick específico (`selectPreyButton`)
  - botão choose prey (`choosePreyButton`)
  - toggles `autoRerollCheck` e `lockPreyCheck`.
- Tracker (`PreyTracker`) com barras/ícones e nome da criatura.

## 4.3 Eventos UI
- Clicks principais disparam `g_game.preyAction(...)` com `PREY_ACTION_*`.
- Fluxos com confirmação:
  - `showListRerollConfirmation`
  - `showBonusRerollConfirmation`
  - `showPickSpecificPreyConfirmation`
- Pesquisa/lista do modo all monsters:
  - armazenamento por slot (`raceEntriesBySlot`, `selectedRaceEntryBySlot`), filtros e seleção visual.

## 4.4 Render dos dados recebidos
- `parsePreyData` (C++) converte pacote em callback Lua do estado específico.
- `prey.lua` atualiza:
  - painel de estado da slot,
  - nome/outfit da criatura,
  - estrelas/grade de bônus,
  - texto e barra de tempo,
  - custos e habilitação de botões por saldo (`bankGold + inventoryGold` e wildcards).

## 4.5 Cooldown visual e reroll visual
- `onPreyTimeLeft`: atualiza progress bar e tooltip no tracker e slot ativa.
- `onPreyFreeRerolls`: atualiza timer/preço do botão de reroll de lista.
- `refreshRerollButtonState`: desabilita/habilita com base em tempo free + ouro disponível.

---

## 5) Lógica do servidor

## 5.1 Configuração
- Chaves de config (defaults em `configmanager.cpp`):
  - `preySystemEnabled`, `preyFreeThirdSlot`,
  - `preyBonusRerollPrice`, `preyBonusTime`,
  - `preyFreeRerollTime`, `preyRerollPricePerLevel`, `preySelectListPrice`.

## 5.2 Seleção de criaturas (algoritmo)
- `PreySlot::reloadMonsterGrid(blackList, level)`:
  - exige bestiary >= 36 entradas.
  - sorteia 9 criaturas por distribuição de estrelas dependente da faixa de level.
  - ignora criaturas inválidas (`experience == 0`, `!isPreyable`, `isPreyExclusive`).
  - evita duplicidade via blacklist.

## 5.3 Sorteio/raridade de bônus
- `reloadBonusType()`:
  - sorteia tipo aleatório (`Damage/Defense/Experience/Loot`).
  - se rarity 10, força troca de tipo (não repete o atual).

- `reloadBonusValue()`:
  - rarity evolui em direção a 10.
  - fórmulas por tipo:
    - Damage: `2 * rarity + 5`
    - Defense: `2 * rarity + 10`
    - Experience/Loot: `3 * rarity + 10`

## 5.4 Estado/validação de ação
- `IOPrey::parsePreyAction` valida server-side:
  - slot existente e não locked;
  - dinheiro para reroll gold;
  - wildcards para bonus reroll / lock / list all;
  - estado coerente da máquina (`canSelect`, índices, etc.);
  - monstro não duplicado entre slots;
  - monstro preyable para seleção por race id.

## 5.5 Aplicação de bônus
- Damage/Defense:
  - `combat.cpp` altera `damage.primary/secondary` por `%` quando race do alvo casa com prey ativa.
- XP:
  - `Player:onGainExperience` (Lua) aplica multiplicador via `getPreyExperiencePercentage`.
- Loot:
  - callback `monsterOnDropLoot` aplica chance baseada em `getPreyLootPercentage` (inclui lógica de party share).

## 5.6 Expiração
- Tick ocorre via `player:removePreyStamina(...)` (Lua) -> `IOPrey::checkPlayerPreys(...)`.
- Ao expirar:
  - opção `AutomaticReroll`: tenta consumir wildcards e rerrolar tipo/valor+tempo.
  - opção `Locked`: tenta consumir wildcards e renovar tempo.
  - opção none: expira e volta para seleção.

## 5.7 Pagamentos
- Gold: `g_game().removeMoney(...)` para list reroll dentro da janela de free-reroll.
- Wildcards: `player->usePreyCards(...)` para bonus reroll, lock e all-monsters selection.
- Custo em gold por reroll de lista: `player level * PREY_REROLL_PRICE_LEVEL`.

---

## 6) Regras matemáticas

## 6.1 Fórmulas confirmadas
- Valor do bônus (server):
  - Damage `% = 2 * rarity + 5`
  - Defense `% = 2 * rarity + 10`
  - XP/Loot `% = 3 * rarity + 10`

- Aplicação em combate:
  - Damage bonus: adiciona `ceil(base * % / 100)` em `primary` e `secondary`.
  - Defense bonus: subtrai `ceil(base * % / 100)` em `primary` e `secondary`.

- XP bonus:
  - retorna `100 + bonusPercentage` quando slot ativa com `PreyBonus_Experience`; senão `100`.
  - `onGainExperience`: `exp = ceil(exp * preyPercent / 100)`.

- Loot bonus:
  - `getPreyLootPercentage` retorna `%` ou `0`.
  - callback de loot usa esse valor como probabilidade de roll extra.

## 6.2 Stack com outros bônus
- O código de XP aplica Prey em sequência com outros multiplicadores (boosted creature, VIP bonus, forge stack, etc.) dentro de `onGainExperience`.
- Portanto, no estado atual, o stacking de XP é multiplicativo sequencial conforme a ordem do script Lua.

## 6.3 Limites observáveis no código
- `bonusRarity` é capado em 10 dentro de `reloadBonusValue`.
- Fórmulas implicam máximo teórico:
  - Damage: 25%
  - Defense: 30%
  - XP/Loot: 40%
- (Textos de gamestore comentam faixas maiores, mas esta documentação considera somente a implementação efetiva de código.)

---

## 7) Segurança e validação

## 7.1 Validações server-side
- Não confia no estado enviado pelo client:
  - valida slot locked/estado válido,
  - valida recursos (gold/wildcards),
  - valida índice/race id,
  - valida não duplicar monstro entre slots,
  - valida preyable no fluxo de seleção por race.

## 7.2 O que não deve confiar no client
- `actionType`, `index`, `raceId`, toggles de opção e timers de UI.
- Tudo isso é revalidado no `IOPrey::parsePreyAction` e no runtime server.

## 7.3 Pontos frágeis/observações reais
- `ClientPreyRequest (0xED)` no server atual não envia explicitamente `sendPreyData`; trata apenas resource balance.
- `PreyDataState_WildcardSelection` é suportado no parser client, mas o fluxo server principal de `parsePreyAction` trabalha sobretudo com `Selection/ListSelection/Active/Inactive/Locked`.
- Várias mensagens de erro possuem typo (`enought`) e não afetam regra, mas indicam dívida técnica textual.

---

## 8) Persistência

## 8.1 Como salva
- `players.prey_wildcard` salvo no update geral de player.
- `player_prey` salvo por slot em `savePlayerPreyClass()` (upsert), incluindo blob `monster_list`.

## 8.2 Quando salva
- No fluxo normal de save do player (`IOLoginDataSave`) durante persistência do personagem.

## 8.3 Como carrega
- Em `loadPlayerById`: carrega `prey_wildcard`.
- `loadPlayerPreyClass()` carrega slots de `player_prey`, desserializa `monster_list` e injeta no `Player`.

---

## 9) Pontos reais de extensão

- Novo tipo de bônus
  - Server enum `PreyBonus_t` + regras em `reloadBonusValue`, aplicação em combate/xp/loot e serialização `sendPreyData`.
  - Client enum `PreyBonusType_t` + descrição/render em `prey.lua`.

- Alterar nº de slots
  - Enums `PreySlot_t`/`PreySlotNum_t`, loops de init/send/load/save e UI (`slot1..slot3`) precisam ser ampliados em conjunto.

- Alterar tempo padrão
  - `PREY_BONUS_TIME`, `PREY_FREE_REROLL_TIME` em config.

- Alterar custo
  - Gold: `PREY_REROLL_PRICE_LEVEL`.
  - Wildcards: `PREY_BONUS_REROLL_PRICE`, `PREY_SELECTION_LIST_PRICE`.

- Alterar raridade
  - Lógica em `reloadBonusValue` e impacto na UI de estrelas.

- Adicionar novos efeitos visuais/UI
  - `prey.otui` (widgets) + `prey.lua` (eventos/render/tooltips).

---

## 10) Resumo técnico final

## 10.1 Estrutura resumida
- **Client**: `game_prey` (UI+ações) + `protocolgamesend/parse`.
- **Server**: `ProtocolGame` (pacotes) + `IOPrey` (regras) + `Player` (estado).
- **Aplicação de efeito**: C++ combate (damage/defense), Lua de player/loot (xp/loot).
- **Persistência**: `players.prey_wildcard` + `player_prey`.

## 10.2 Diagrama lógico simplificado

```text
UI Prey (client)
  -> preyAction/preyRequest
  -> Protocol C->S (0xEB / 0xED)
  -> Server parse
  -> IOPrey valida e muta slot
  -> Server envia 0xE8/0xE7/0xE9 (+ resources)
  -> Client parse
  -> Callbacks onPrey*
  -> Atualização visual e tracker

Durante caça:
  stamina tick (Lua)
    -> removePreyStamina
    -> checkPlayerPreys
    -> decrementa/expira/auto-renova
    -> envia update ao client
```

## 10.3 Dependências principais
- Bestiary (`getBestiaryList`, stars, raceId, unlock).
- MonsterType flags (`isPreyable`, `isPreyExclusive`).
- Sistema de recursos (bank/gold/prey cards).
- Eventos Lua de ganho de XP e drop de loot.
- Configuração (`PREY_*`).

## 10.4 Checklist de modificação segura
- [ ] Alterou enum de bônus/estado/ação em **client e server**.
- [ ] Atualizou serialização/deserialização do pacote (`sendPreyData` e `parsePreyData`).
- [ ] Atualizou validações server-side em `IOPrey::parsePreyAction`.
- [ ] Atualizou render/UI (`prey.lua`/`prey.otui`).
- [ ] Revisou persistência (`player_prey` load/save) para novos campos.
- [ ] Revalidou aplicação real de bônus em combate/XP/loot.
- [ ] Testou login, reroll, seleção, expiração, save/load.
