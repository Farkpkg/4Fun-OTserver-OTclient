<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# Weekly Task Board - Documentação Técnica Completa

> Escopo real encontrado: **não existe um módulo literal chamado `Weekly Task Board`** em `COMPLETE_CUSTOM_CLIENT`.  
> O que existe e implementa lógica equivalente de tarefas/missões periódicas é:
> 1) **Battle Pass** (missões diárias + grade semanal de desbloqueio de missões), e  
> 2) **Prey Hunting Task** (sistema de tarefas de caça com progresso e recompensa por slot).

---

## ETAPA 1 — Localização (inventário completo de ocorrências relevantes)

### 1.1 Arquivos centrais (implementação direta)

#### Battle Pass (missões diárias/temporada + reset semanal de unlock)
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/const.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/classes/rewards.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otmod`
- `COMPLETE_CUSTOM_CLIENT/modules/game_sidebuttons/sidebuttons.otui` (entrada de UI para abrir Battle Pass)

#### Hunting Tasks (task system de caça)
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otmod`
- `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.lua` (tracker + integração com aba Hunting)
- `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.otui` (botão/aba Hunting Tasks)
- `COMPLETE_CUSTOM_CLIENT/modules/gamelib/const.lua` (`ResourceHuntingTask`)

#### Camada de protocolo/eventos genéricos correlata
- `COMPLETE_CUSTOM_CLIENT/modules/game_protocol/protocol.lua` (opcodes gerais e registro de parser de mensagens, sem parser explícito de battlepass/hunting)

### 1.2 Arquivos de dados/UI assets relacionados
- `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/*task*.png`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/preyhuntingtask-*.png`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/dailyMissionBg.png`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/missionBg.png`
- `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/mission_icon.png`

### 1.3 Ocorrências textuais secundárias (não implementam sistema)
- `COMPLETE_CUSTOM_CLIENT/data/json/hunting_places.json` (strings com “Task Area”)
- `COMPLETE_CUSTOM_CLIENT/data/json/markers.json` (descrições de quests/tasks do mapa)
- `COMPLETE_CUSTOM_CLIENT/modules/gamelib/core/markers.lua` (espelho de markers)
- `COMPLETE_CUSTOM_CLIENT/data/json/patch_notes*.json` (menção textual a hunting task)

> Observação: os arquivos de “ocorrência textual secundária” foram encontrados na busca por palavras-chave, mas **não contêm lógica funcional** de “Task Board / Weekly Task”; apenas conteúdo de texto/metadata.

---

## 1. Visão Geral do Sistema

Na prática, o cliente possui **duas implementações de missão/tarefa periódica**:

1. **Battle Pass (`game_battlepass`)**
   - Missões diárias (2 slots visíveis na UI)
   - Missões de temporada (26 slots em grade)
   - Temporizador da temporada
   - Temporizador de missões diárias
   - **Cálculo de “próximo unlock semanal”** baseado em `beginTime` do passe
   - Recompensas por “steps” (free/premium)

2. **Prey Hunting Tasks (`game_prey_hunting`)**
   - 3 slots de tarefa de caça
   - Estados de slot (locked/select/wildcard/active/redeem/exhausted)
   - Progresso por kills e recompensa por grade (estrelas)
   - Ações de reroll/cancel/upgrade/claim
   - Cooldown de reroll (20h)

Não há, neste código, uma entidade explícita chamada `TaskBoard`, `WeeklyTask`, `WeeklyObjectives` etc. O comportamento semanal aparece no Battle Pass via função de cálculo de semana e timer de desbloqueio.

---

## 2. Estrutura do Backend

> **Limite técnico importante:** `COMPLETE_CUSTOM_CLIENT` é majoritariamente camada de cliente (Lua + OTUI). Não há código de backend/servidor e não há SQL nesse escopo.

### 2.1 “Backend do cliente” (camada de lógica Lua)

#### 2.1.1 Battle Pass — Estrutura de estado
Principais campos globais em `BattlePass`:
- Controle de janela/UI: `window`, `missionPanel`, `progressPanel`, `outfitWidget`, `scrollBarWidget`
- Estado da temporada: `beginTime`, `endTime`, `progressPoints`, `currentRewardStep`, `nextStepPoints`
- Missões: `dailyMissionsBegin`, `dailyMissionsExpire`, `dailyMissions`, `seassonMissions`
- Premium/reroll: `premiumBattlepass`, `dailyRerollPrice`, `dailyRerollWindow`

#### 2.1.2 Battle Pass — Fluxo de eventos públicos
Eventos recebidos via `connect(g_game, {...})`:
- `onBattlePassMissions -> BattlePass.onBattlePassMissions(...)`
- `onBattlePassRewards -> BattlePass.onBattlePassRewards(...)`
- `onResourceBalance -> onResourceBalance()`

Chamadas de saída (cliente -> servidor):
- `g_game.requestBattlePass(mode)`
- `g_game.rerollBattlePassMission(missionId)`
- `g_game.redeemBattlePass(index, rewardId, objectId)` (em `classes/rewards.lua`)

#### 2.1.3 Battle Pass — “reset semanal” no cliente
Não existe reset executado localmente; o cliente apenas:
- Calcula a semana atual com `calculateWeekNumber()`
- Calcula timestamp do próximo reset com `getNextResetWeek(currentIndex)`
- Exibe contagem regressiva em `unlockInfo` (`timerEvent`)

Ou seja: o reset de fato é server-side; o cliente só calcula/mostra ETA.

---

#### 2.1.4 Hunting Tasks — Estrutura de estado
Variáveis globais principais:
- Slots e seleção: `huntingSlots`, `selectedMonster`, `inactiveSelections`, `activeMonsterList`, `wildcardSelectedMonster`
- Dados base: `huntingMonsterData`, `huntingRewardData`, `currentMonsterList`, `currentWildcardList`
- Economia: `bankBalance`, `invetoryMoney`, `wildcardBalance`, `huntingToken`
- Custos: `goldUpdatePrice`, `goldRemovePrice`, `wildcardSelectPrice`, `rerollWildcardPrice`
- Cooldown: `nextRerollTime`, `updateRerollEvent`

Enums locais:
- Ações (`PREY_HUNTING_ACTION_*`): listreroll, bonusreroll, select_wildcard, select, remove, collect
- Estados (`PREY_HUNTING_STATE_*`): locked, exhausted, select, wildcard, active, redeem
- Tipos de descrição (`DESC_TYPE`)

#### 2.1.5 Hunting Tasks — Eventos recebidos
Bindings em `connect(g_game, {...})`:
- `onPreyHuntingPrice`
- `onUpdateRerrolTime`
- `onResourceBalance`
- `onHuntingLockedState`
- `onHuntingSelectState`
- `onHuntingActiveState`
- `onPreyHuntingBaseData`
- `onHuntingWildcardState`
- `onHuntingExhaustedState`

Chamadas de saída:
- `g_game.preyHuntingAction(slot, action, bestiaryUnlocked, raceId)`

### 2.2 Hooks/timers/scheduler no cliente
- Battle Pass:
  - `timerEvent(widget, endTime)` faz polling por `scheduleEvent` de 1s para atualizar texto “New missions available in...”.
- Hunting Tasks:
  - `updateRerollEvent = cycleEvent(..., 1000)` e `updateVisibleRerollTime()` para decrementar UI de reroll com base em `os.time()`.

---

## 3. Estrutura do Banco de Dados

### 3.1 Resultado da análise
Dentro de `COMPLETE_CUSTOM_CLIENT`:
- **Não há migrations SQL**
- **Não há definição de tabelas**
- **Não há queries SQL**

### 3.2 Consequência arquitetural
Toda persistência de progresso de missões/tarefas é externalizada para o servidor.
O cliente apenas recebe snapshots/eventos e renderiza.

### 3.3 Persistência local auxiliar encontrada
- `BattlePass:saveConfigJson()` salva somente estado de UI/câmera do battlepass em:
  - `/characterdata/<playerId>/battlepass.json`
- Isso **não** é progresso de missão real, apenas posição visual (`currentRewardStep`, `lastCameraPosition`).

---

## 4. Estrutura do Frontend

## 4.1 Battle Pass UI

### 4.1.1 Layout principal
`battlepass.otui` define:
- `dailyMissionsBg` (grid 2 colunas) para missões diárias
- `missionsBackground` (grid 2x13 = 26) para missões gerais
- Barras de tempo/progresso (`dailyTimeProgress`, `seasonTimeProgress`, `levelProgress`)
- `unlockInfo` para countdown semanal de novas missões

### 4.1.2 Mapeamento de missão por semana/posição
`const.lua` define:
- `MissionsDisplacement`: mapeia índice lógico para posição visual na grade
- `MissionTypesOrder`: sequência bronze/silver/gold por semana
- `MissionRankIcons`: ícone conforme `rewardPoints`

Esse mapeamento permite “espalhar” missões por semanas dentro da grade fixa de 26 células.

## 4.2 Hunting Tasks UI

### 4.2.1 Layout por slot
`hunting.otui` define para cada slot:
- Estado `inactive`
- Estado `active`
- Estado `locked`
- Estado `selection` (wildcard)
- Estado `exhaust`

Com componentes de ação:
- Reroll, choose task, pick higher reward, cancel task, claim reward
- Search/list para seleção de monstro no modo wildcard

### 4.2.2 Integração com tracker lateral
`prey.lua` prepara os 3 `hslot` no `preyTracker`, com tooltip e clique redirecionando para aba Hunting Tasks.

---

## 5. Fluxo de Execução

## 5.1 Fluxo completo — Battle Pass (equivalente ao “Task Board semanal”)

```pseudo
Usuário clica no botão Battle Pass (sidebuttons)
  -> g_game.requestBattlePass(0)
  -> servidor envia onBattlePassMissions + onBattlePassRewards
  -> BattlePass.onBattlePassMissions atualiza estado local
  -> BattlePass.configureMissionPanel renderiza:
       - tempo de temporada
       - tempo diário
       - unlock semanal (countdown)
       - slots diários
       - grade de missões gerais

Ao clicar reroll em missão diária:
  -> BattlePass.rerollDailyMission() abre confirmação
  -> g_game.rerollBattlePassMission(missionId)
  -> aguarda novo snapshot do servidor

Ao resgatar recompensa:
  -> BattlePassRewards.onRedeemReward
  -> g_game.redeemBattlePass(...)
  -> aguarda confirmação/snapshot servidor
```

### 5.1.1 Como uma Weekly Task é “criada”
No cliente ela **não é criada**; vem serializada do servidor em `dailyMissions/generalMissions` dentro de `onBattlePassMissions`.

### 5.1.2 Como é atribuída ao jogador
Também server-side; cliente recebe já atribuída e só popula widgets.

### 5.1.3 Como o progresso é atualizado
Por novo evento/snapshot (`onBattlePassMissions`) com `currentProgress`, `maxProgress` e `rewardPoints`.

### 5.1.4 Como recompensa é liberada
UI habilita/mostra caixas com base em `currentRewardStep`, `premiumBattlepass` e `hasClamedReward`; resgate efetivo via `g_game.redeemBattlePass`.

### 5.1.5 Como ocorre reset semanal
No cliente: apenas cálculo de ETA de unlock (`calculateWeekNumber/getNextResetWeek`) + label `unlockInfo`.  
Reset real do conteúdo é do servidor.

### 5.1.6 Se o player não completar
Cliente apenas mostra expiração (`running() == false`, widgets ocultados/desabilitados).

---

## 5.2 Fluxo completo — Hunting Tasks

```pseudo
Cliente abre aba Hunting Task
  -> lê recursos (gold, wildcard, hunting token)
  -> mostra estado por slot vindo de eventos do servidor

Estado SELECT:
  -> servidor envia lista de criaturas
  -> jogador escolhe criatura + quantidade (bestiary flag)
  -> g_game.preyHuntingAction(... SELECT ...)

Estado ACTIVE:
  -> cliente exibe progresso killed/toKill
  -> ao completar: habilita botão claim
  -> g_game.preyHuntingAction(... COLLECT ...)

Ações paralelas:
  - reroll lista (gold ou free se cooldown zerado)
  - cancel task (custo em gold)
  - upgrade reward grade (wildcard)
  - seleção wildcard (lista específica)
```

### 5.2.1 Validação de progresso/recompensa
- Progresso: baseado em parâmetros de evento (`toKill`, `killed`)
- Recompensa estimada local: `getHuntingRewardPoints(monsterId, stars, unlocked)` com tabela `huntingRewardData` recebida do servidor

### 5.2.2 Scheduler/timer
`updateVisibleRerollTime` recalcula cooldown e atualiza progressbar textual/percentual.

---

## 6. Sistema de Reset Semanal

### 6.1 Battle Pass (explícito)
Funções-chave:
- `calculateWeekNumber()`
- `getNextResetWeek(currentIndex)`

Regras:
- Base em `beginTime` do passe
- Âncora de horário fixa às 10:00
- Janela de 7 dias por ciclo

Uso:
- Só para UI/contagem regressiva de “New missions available in”.

### 6.2 Hunting Tasks
Não existe reset semanal explícito no cliente. Existe cooldown de reroll por slot (20h) e estados exaustão, todos controlados por eventos do servidor.

---

## 7. Sistema de Recompensas

## 7.1 Battle Pass

### 7.1.1 Missões
Cada missão traz:
- `missionName`
- `missionDescription`
- `currentProgress`
- `maxProgress`
- `rewardPoints`
- (diárias também aceitam reroll por preço dinâmico = `dailyRerollPrice * level`)

### 7.1.2 Recompensas por step
- Estrutura `rewardSteps` recebida via `onBattlePassRewards`
- Tipos free/premium
- Gate por:
  - step desbloqueado (`stepId <= currentRewardStep`)
  - premium ativo
  - já resgatada (`hasClamedReward`)

## 7.2 Hunting Tasks
- Recompensa em `Hunting Task Points` (resource type 50)
- Valor depende de:
  - dificuldade do monstro (`huntingMonsterData`)
  - grade de estrelas (1..5)
  - bestiary unlock (non/full)

---

## 8. Dependências Internas

## 8.1 Mapa de dependência — Battle Pass

```text
sidebuttons.otui
   -> game_battlepass.loadMenu('challengesMenu')
   -> g_game.requestBattlePass(0)

battlepass.lua
   -> const.lua (MissionsDisplacement, RewardPositions, etc.)
   -> classes/rewards.lua (resgate de reward)
   -> g_game events (onBattlePassMissions/onBattlePassRewards)

classes/rewards.lua
   -> g_game.redeemBattlePass(...)
```

## 8.2 Mapa de dependência — Hunting Tasks

```text
prey.lua/prey.otui
   -> botão/aba Hunting Tasks
   -> abre módulo game_prey_hunting

hunting.lua
   -> recebe eventos de estado via g_game
   -> envia ações via g_game.preyHuntingAction
   -> usa ResourceHuntingTask (const.lua)
   -> atualiza tracker visual no módulo prey
```

## 8.3 Protocolo e opcodes
`modules/game_protocol/protocol.lua` registra múltiplos opcodes, mas os fluxos de battlepass/hunting aqui analisados chegam ao Lua por callbacks de alto nível (`onBattlePassMissions`, `onHunting*`, etc.).  
Os IDs/opcodes específicos dessas features não estão explícitos nesse arquivo Lua.

---

## 9. Pontos Críticos e Possíveis Bugs

1. **Variável potencialmente incorreta em Hunting Active State**
   - Em `onHuntingActiveState`, há verificação `if hasWildcard then ...` sem definição local aparente.
   - Isso sugere bug de variável (provável intenção: `noWildcard` ou `wildcardBalance` check).

2. **Dependência forte de snapshot servidor**
   - Cliente não mantém “source of truth”; qualquer latência/descompasso pode gerar UI temporariamente inconsistente.

3. **Risco de divisão por zero em percentuais**
   - Ex.: `currentProgress / maxProgress` e cálculo de barras de tempo se `nextStepPoints` ou janelas temporais vierem inválidas (0).

4. **Battle Pass: ocultação total ao expirar**
   - Em `running() == false`, widgets são desabilitados/ocultados; isso pode prejudicar transparência pós-temporada (histórico visual some).

5. **Typos que dificultam manutenção**
   - Ex.: `seassonMissions`, `huuntingMessageWindow`, `invetoryMoney`, `onUpdateRerrolTime`.

6. **Lógica de reset no cliente só visual**
   - Se relógio local estiver errado, countdown semanal ficará incorreto (embora sem impacto no estado real servidor).

---

## 10. Sugestões de Refatoração

1. **Padronizar nomenclatura e corrigir typos**
   - `seasonMissions`, `huntingMessageWindow`, `inventoryMoney`, `onUpdateRerollTime`.

2. **Extrair cálculo temporal para utilitário único**
   - Funções de tempo (`getFormatedTime`, `getTimeUntil`, cálculo semanal) podem virar módulo utilitário reutilizável/testável.

3. **Criar camada de ViewModel para missões**
   - Separar parsing/normalização de dados recebidos do rendering OTUI.

4. **Adicionar guard clauses robustas**
   - Validar divisores e ranges antes de `setPercent`.

5. **Telemetria de inconsistência de payload**
   - Log estruturado quando `dailyMissions` > 2, missing fields, ou dados fora de faixa.

6. **Unificar sistema de timers**
   - BattlePass usa `scheduleEvent` recursivo; hunting usa `cycleEvent`. Padronizar reduz edge-cases de lifecycle.

7. **Documentar contrato de protocolo no próprio cliente**
   - Mesmo sem parser explícito em Lua, manter markdown de contrato (payload esperado de `onBattlePassMissions` e `onHunting*`).

---

## Apêndice A — Tabela de funções-chave (Battle Pass)

- `BattlePass.onBattlePassMissions(...)`
- `BattlePass.onBattlePassRewards(...)`
- `BattlePass:configureMissionPanel()`
- `BattlePass:configureRewardPanel()`
- `BattlePass.calculateWeekNumber()`
- `BattlePass.getNextResetWeek(currentIndex)`
- `BattlePass:rerollDailyMission(data)`
- `BattlePass:running()`

## Apêndice B — Tabela de funções-chave (Hunting Tasks)

- `onHuntingSelectState(...)`
- `onHuntingActiveState(...)`
- `onHuntingWildcardState(...)`
- `onHuntingExhaustedState(...)`
- `onPreyHuntingBaseData(monsterInfo, rewardData)`
- `getHuntingKills(monsterId, bestiaryUnlocked)`
- `getHuntingRewardPoints(monsterId, stars, bestiaryUnlocked)`
- `updateVisibleRerollTime()`
- `setTimeUntilFreeReroll(slot, timeUntilFreeReroll)`

## Apêndice C — Conclusão objetiva

- **Weekly Task Board literal:** não encontrado.
- **Implementação funcional equivalente:** Battle Pass (com grade semanal + daily missions) e Hunting Tasks.
- **Backend/DB/SQL para weekly tasks:** não existe neste escopo de código cliente; dependente de servidor externo.

---

## Assets Visuais Relacionados ao Task Board

> Critério usado: assets em `data/images/game/battlepass/*` e `data/images/game/prey/*` ligados ao fluxo de Battle Pass (weekly/daily missions) e Hunting Tasks (task board de caça), além de referências cruzadas em `*.otui`/`*.lua`.

### dailyMissionBg.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/dailyMissionBg.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- Tipo: background (card de missão diária)
- Descrição técnica: base visual do widget `DailyMissionWidget`, onde são renderizados nome, progresso, ícone e estado de missão diária.
- Trecho OTUI relevante:
```otui
DailyMissionWidget < Panel
  size: 100 154
  image-source: /images/game/battlepass/dailyMissionBg
```

### missionBg.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/missionBg.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- Tipo: background (card de missão geral)
- Descrição técnica: moldura padrão de cada slot das 26 missões sazonais exibidas na grade do Battle Pass.
- Trecho OTUI relevante:
```otui
MissionWidget < Panel
  size: 104 154
  image-source: /images/game/battlepass/missionBg
```

### daily-free-icon.png / daily-vip-icon.png / daily-icon-complete.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/daily-free-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/daily-vip-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/daily-icon-complete.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- Tipo: ícone de task + badge de completado
- Descrição técnica: o OTUI inicializa os dois slots (free/vip); o Lua troca dinamicamente para `daily-icon-complete` quando `currentProgress == maxProgress`.
- Trecho Lua relevante:
```lua
local icon = (k == 1 and "daily-free-icon" or "daily-vip-icon")
if completed then
    icon = "daily-icon-complete"
end
widget:recursiveGetChildById("dailyMissionIconImage"):setImageSource("/images/game/battlepass/" .. icon)
```

### bronze-icon*.png / silver-icon*.png / gold-icon*.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/bronze-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/bronze-icon-complete.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/silver-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/silver-icon-complete.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/gold-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/gold-icon-complete.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/const.lua`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- Tipo: ícone de dificuldade/rank da missão
- Descrição técnica: o rank é definido por `rewardPoints` (100/150-200/300) e o sufixo `-complete` é aplicado dinamicamente ao concluir.
- Trecho Lua relevante:
```lua
local completed = data.currentProgress == data.maxProgress
local missionIcon = completed and MissionRankIcons[data.rewardPoints] .. "-complete" or MissionRankIcons[data.rewardPoints]
widget:recursiveGetChildById("missionIconImage"):setImageSource("/images/game/battlepass/" .. missionIcon)
```

### blockPattern.png / dailyBlockPattern.png / mission-locked-icon.png / completed.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/blockPattern.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/dailyBlockPattern.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/mission-locked-icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/completed.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- Tipo: estado visual (bloqueado/completo)
- Descrição técnica: compõem os overlays de estado dos cards de missão (bloqueio e concluído).
- Trecho OTUI relevante:
```otui
UIWidget
  id: completedIcon
  image-source: /images/game/battlepass/completed
UIWidget
  id: blockedMissionIcon
  image-source: /images/game/battlepass/blockPattern
```

### reward-button.png / free-reward-chest*.png / vip-reward-chest*.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/reward-button.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/free-reward-chest.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/free-reward-chest-open.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/vip-reward-chest.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/vip-reward-chest-open.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- Tipo: botão de claim + estado de recompensa
- Descrição técnica: botão/moldura fixa em OTUI; Lua alterna chest fechado/aberto conforme `hasClamedReward`, liberado e tipo free/premium.
- Trecho Lua relevante:
```lua
if reward.hasClamedReward then
  rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest-open")
else
  rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
end
```

### battlepass-hourglass.png / battlepass-hourglass-red.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/battlepass-hourglass.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/battlepass-hourglass-red.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_pvp_queue/pvp_queue.lua` (asset compartilhado)
- Tipo: ícone de tempo/countdown
- Descrição técnica: no Battle Pass sinaliza timers de diária/season; no PvP Queue o mesmo asset muda para versão vermelha quando o tempo está curto.

### battlePass-anim.png / battlepass_menu.png / bright.png / mainIcon1.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/battlePass-anim.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/battlepass_menu.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/bright.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/mainIcon1.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/game_sidebuttons/sidebuttons.otui`
- Tipo: elemento decorativo / entrada de navegação
- Descrição técnica: assets de shell visual do módulo (banner, cabeçalho/menu, brilho de botão lateral e ícone principal para abrir Battle Pass).

### map/battlepass-background_0..46.png
- Caminho (família): `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/map/battlepass-background_<n>.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- Tipo: background do layout principal de rewards track
- Descrição técnica: o OTUI gera dinamicamente os tiles de fundo do “caminho” de progressão do passe.
- Trecho OTUI relevante:
```otui
for i = 0, 46 do
  local widget = g_ui.createWidget("UIWidget", self)
  widget:setImageSource("/images/game/battlepass/map/battlepass-background_" .. i)
end
```

### task-button.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task-button.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão de navegação para aba/sistema de tasks
- Descrição técnica: ativa entrada para “Hunting Tasks” dentro do ecossistema Prey.

### task_choose_up/down/off.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task_choose_up.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task_choose_down.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task_choose_off.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão (iniciar/confirmar task)
- Descrição técnica: estados visualmente distintos para escolher/iniciar criatura da task.

### claim_task_up/down/inactive.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/claim_task_up.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/claim_task_down.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/claim_task_inactive.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão de claim de recompensa
- Descrição técnica: usado quando a task ativa atinge `killed >= toKill` e a UI habilita coleta.

### cancel_task_up/down/off.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/cancel_task_up.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/cancel_task_down.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/cancel_task_off.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão de cancelamento de task
- Descrição técnica: integra o fluxo de `PREY_HUNTING_ACTION_REMOVE` (cancelamento com custo em gold).

### higher_task_up/down/up-off.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/higher_task_up.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/higher_task_down.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/higher_task_up-off.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão de upgrade de recompensa
- Descrição técnica: representa a ação de aumento de grade da recompensa (`PREY_HUNTING_ACTION_BONUSREROLL`).

### task_perm.png / task_temp.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task_perm.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/task_temp.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: badge de tipo de task (permanente/temporária)
- Descrição técnica: identificação visual do tipo de slot/task no painel ativo.

### preyhuntingtask-tokens.png / preyhuntingtask-preytoken-banner.png
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/preyhuntingtask-tokens.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/preyhuntingtask-preytoken-banner.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: ícone e banner de moeda de task
- Descrição técnica: assets do saldo de `Hunting Task Points` (resource 50) no cabeçalho e infos.

### preyhuntingtask-exhausted.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/preyhuntingtask-exhausted.png`
- Referenciado em: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: estado (slot exausto)
- Descrição técnica: imagem de feedback quando o slot entra em estado `PREY_HUNTING_STATE_EXHAUSTED`.

### prey_reroll_up.png / timerProgress / progress
- Caminhos:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/prey_reroll_up.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/timerProgress.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/progress.png`
- Referenciado em:
  - `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.otui`
  - `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- Tipo: botão de reroll + barras de progresso/tempo
- Descrição técnica: usados no cooldown de reroll e em barras de progresso de task/prey.

## Estrutura Visual do Sistema

### Layout principal
- Battle Pass usa `missionBg` e `dailyMissionBg` para cards de missão e uma malha de `battlepass-background_<n>` para o trilho de progressão/recompensas.
- Hunting Tasks usa composição própria de painéis Prey com foco em ações de slot (`task_choose`, `claim_task`, `cancel_task`, `higher_task`).

### Ícones dinâmicos
- Battle Pass: ícones dinâmicos por estado/rank (`daily-*-icon`, `bronze/silver/gold[-complete]`, `completed`, `blockPattern`).
- Hunting Tasks: ícones de estado/ação (`claim_task_*`, `cancel_task_*`, `higher_task_*`) e moeda (`preyhuntingtask-tokens`).

### Estados visuais (ativo/completo/bloqueado)
- Battle Pass:
  - Bloqueado: `blockPattern`, `dailyBlockPattern`, `mission-locked-icon`.
  - Completo: `completed`, `daily-icon-complete`, `*-icon-complete`.
  - Claim: `reward-button` + chest aberto/fechado.
- Hunting Tasks:
  - Inativo/exausto: `claim_task_inactive`, `preyhuntingtask-exhausted`.
  - Ativo/ação: `claim_task_up/down`, `cancel_task_*`, `higher_task_*`, `task_choose_*`.

### Assets possivelmente não utilizados (ou uso indireto)
- Possível asset não utilizado no fluxo de tasks/battlepass encontrado por busca direta:
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/mainIcon2.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/mission_icon.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/points-bg.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/reward-house.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/reward-house-unlocked.png`
  - `COMPLETE_CUSTOM_CLIENT/data/images/game/prey/aprey_reroll_up.png` (nome sugere variação/typo de asset)
- Observação: os ícones `bronze/silver/gold` e variantes `-complete` **são usados dinamicamente** via concatenação em `battlepass.lua`.

### Base visual: Battle Pass vs sistema próprio
- A interface de “Weekly Tasks” é visualmente derivada do módulo Battle Pass para missões sazonais/diárias.
- O Hunting Tasks compartilha linguagem visual do ecossistema Prey, funcionando como sistema paralelo de tasks com UI própria.
