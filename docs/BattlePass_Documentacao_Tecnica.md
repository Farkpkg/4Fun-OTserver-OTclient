# Battle Pass - Documentação Técnica

## 1. Visão Geral

O módulo Battle Pass do `COMPLETE_CUSTOM_CLIENT` é implementado no cliente em Lua/OTUI e opera como um sistema de:
- Missões diárias (2 slots: free/vip)
- Missões sazonais (grade com 26 widgets de missão)
- Trilha de recompensas (free/premium) com steps e coleta
- Temporizadores de temporada, daily reset e unlock semanal de missões

A autoridade de dados (progresso, missões, rewards) está no servidor; o cliente renderiza estado recebido por callbacks de `g_game`.

---

## 2. Estrutura de Arquivos

## 2.1 Núcleo do módulo

```text
COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/
├─ battlepass.otmod
├─ battlepass.lua
├─ battlepass.otui
├─ const.lua
└─ classes/
   └─ rewards.lua
```

## 2.2 Integrações diretas

```text
COMPLETE_CUSTOM_CLIENT/modules/game_sidebuttons/sidebuttons.otui
  -> botão que abre battlepass + g_game.requestBattlePass(0)

COMPLETE_CUSTOM_CLIENT/modules/game_skills/skills.lua
  -> exibe bônus BattlePass via onBattlePassBonusChange
```

## 2.3 Assets principais (diretório)

```text
COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/
├─ (ícones de missão/estado/reward)
├─ map/battlepass-background_0..46.png
├─ skills/*.png
└─ tiles/*.png
```

---

## 3. Assets Visuais

> Formato solicitado: nome, caminho, referência, tipo, descrição técnica e trecho real.

### battlePass-anim.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/battlePass-anim.png`
- Referenciado em: `modules/mods/game_battlepass/battlepass.otui`
- Tipo: Background/banner
- Descrição técnica: banner animado/decorativo do painel lateral de missão.
- Código relacionado:
```otui
UIWidget
  id: passBanner
  image-source: /images/game/battlepass/battlePass-anim
```

### dailyMissionBg.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/dailyMissionBg.png`
- Referenciado em: `modules/mods/game_battlepass/battlepass.otui`
- Tipo: Background de slot diário
- Descrição técnica: base do `DailyMissionWidget`.
- Código relacionado:
```otui
DailyMissionWidget < UIWidget
  image-source: /images/game/battlepass/dailyMissionBg
```

### missionBg.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/missionBg.png`
- Referenciado em: `modules/mods/game_battlepass/battlepass.otui`
- Tipo: Background de slot sazonal
- Descrição técnica: base do `MissionWidget` (26 células).
- Código relacionado:
```otui
MissionWidget < UIWidget
  image-source: /images/game/battlepass/missionBg
```

### daily-free-icon.png / daily-vip-icon.png / daily-icon-complete.png
- Caminhos:
  - `.../daily-free-icon.png`
  - `.../daily-vip-icon.png`
  - `.../daily-icon-complete.png`
- Referenciado em: `battlepass.otui`, `battlepass.lua`
- Tipo: Ícone de missão diária / estado completo
- Descrição técnica: ícone inicial do slot e troca dinâmica quando completa.
- Código relacionado:
```lua
local icon = (k == 1 and "daily-free-icon" or "daily-vip-icon")
if completed then
    icon = "daily-icon-complete"
end
widget:recursiveGetChildById("dailyMissionIconImage"):setImageSource("/images/game/battlepass/" .. icon)
```

### bronze/silver/gold icons (+ complete)
- Caminhos:
  - `bronze-icon.png`, `bronze-icon-complete.png`
  - `silver-icon.png`, `silver-icon-complete.png`
  - `gold-icon.png`, `gold-icon-complete.png`
- Referenciado em: `const.lua`, `battlepass.lua`
- Tipo: Ícone de rank/dificuldade de missão
- Descrição técnica: rank por `rewardPoints`; sufixo `-complete` quando concluída.
- Código relacionado:
```lua
MissionRankIcons = { [100] = "bronze-icon", [150] = "silver-icon", [200] = "silver-icon", [300] = "gold-icon" }
local missionIcon = completed and MissionRankIcons[data.rewardPoints] .. "-complete" or MissionRankIcons[data.rewardPoints]
```

### blockPattern.png / dailyBlockPattern.png / mission-locked-icon.png / completed.png
- Caminhos:
  - `blockPattern.png`
  - `dailyBlockPattern.png`
  - `mission-locked-icon.png`
  - `completed.png`
- Referenciado em: `battlepass.otui`
- Tipo: Estado visual (bloqueado/concluído)
- Descrição técnica: overlays usados nos cards.
- Código relacionado:
```otui
UIWidget id: blockedMissionIcon image-source: /images/game/battlepass/blockPattern
UIWidget id: dailyBlockedMissionIcon image-source: /images/game/battlepass/dailyBlockPattern
UIWidget id: completedIcon image-source: /images/game/battlepass/completed
```

### reward-button.png / free-reward-chest*.png / vip-reward-chest*.png
- Caminhos:
  - `reward-button.png`
  - `free-reward-chest.png`, `free-reward-chest-open.png`
  - `vip-reward-chest.png`, `vip-reward-chest-open.png`
- Referenciado em: `battlepass.otui`, `battlepass.lua`
- Tipo: Slot de reward/claim
- Descrição técnica: botão de coleta e ícone da chest trocado por estado (locked/unlocked/claimed).
- Código relacionado:
```lua
if reward.hasClamedReward then
  rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest-open")
else
  rewardBoxImage:setImageSource("/images/game/battlepass/free-reward-chest")
end
```

### battlepass-hourglass.png
- Caminho: `.../battlepass-hourglass.png`
- Referenciado em: `battlepass.otui`
- Tipo: Ícone de timer
- Descrição técnica: acompanha barras de tempo de daily e season.
- Código relacionado:
```otui
UIWidget id: hourglassIcon image-source: /images/game/battlepass/battlepass-hourglass
UIWidget id: seasonHourglassIcon image-source: /images/game/battlepass/battlepass-hourglass
```

### map/battlepass-background_0..46.png
- Caminho: `COMPLETE_CUSTOM_CLIENT/data/images/game/battlepass/map/battlepass-background_0.png` ... `_46.png`
- Referenciado em: `battlepass.otui`
- Tipo: Background do trilho de progressão
- Descrição técnica: OTUI instancia dinamicamente 47 fragments de mapa do caminho de rewards.
- Código relacionado:
```otui
for i = 0, 46 do
  local widget = g_ui.createWidget('MapFragment', self)
  widget:setImageSource("/images/game/battlepass/map/battlepass-background_" .. i)
end
```

### ground-bg.png
- Caminho: `.../ground-bg.png`
- Referenciado em: `classes/rewards.lua`
- Tipo: Fundo de visualização de reward especial/outfit
- Descrição técnica: base visual em widgets de preview de outfit/mount.
- Código relacionado:
```lua
outfitWidget:setImageSource('/images/game/battlepass/ground-bg')
```

### skills/*.png e tiles/*.png
- Caminhos:
  - `.../skills/{0,1,2,3,4,5,13}.png`
  - `.../tiles/{1,2,3,4,5,6,42}.png`
- Referenciado em: `classes/rewards.lua`
- Tipo: Ícones de recompensa especial
- Descrição técnica: renderização dinâmica por tipo de reward (skills/elemental etc).
- Código relacionado:
```lua
widget.rewardSpecial:setImageSource('/images/game/battlepass/skills/' .. v)
widget.rewardSpecial:setImageSource('/images/game/battlepass/tiles/' .. i)
```

### mainIcon1.png / bright.png
- Caminhos:
  - `.../mainIcon1.png`
  - `.../bright.png`
- Referenciado em: `modules/game_sidebuttons/sidebuttons.otui`
- Tipo: entrada de navegação do módulo
- Descrição técnica: ícone do botão Battle Pass no sidebar e camada de brilho visual.

### Assets possivelmente não utilizados no fluxo Battle Pass
- `battlepass-hourglass-red.png`
- `mainIcon2.png`
- `mission_icon.png`
- `points-bg.png`
- `reward-house.png`
- `reward-house-unlocked.png`

Observação: os ícones bronze/silver/gold e variantes `-complete` são usados por concatenação dinâmica em Lua (não aparecem como `image-source` literal no OTUI).

---

## 4. Estrutura da Interface (OTUI)

## 4.1 Janela principal

Hierarquia simplificada:

```text
BattlePassWindow (NewHeadlessWindow#battlePassWindow)
├─ optionsTabBar
│  ├─ challengesMenu (botão)
│  └─ rewardsMenu (botão)
├─ contentPanel
│  ├─ MissionPanel
│  │  ├─ bannerPanel (passBanner)
│  │  ├─ dailyBg
│  │  │  ├─ dailyMissionsBg (2x DailyMissionWidget)
│  │  │  └─ dailyTimeProgress + hourglassIcon
│  │  ├─ playerProgressPanel
│  │  │  ├─ levelProgress
│  │  │  ├─ seasonTimeProgress
│  │  │  └─ unlockInfo
│  │  └─ missionsBackground (grid 2x13 MissionWidget)
│  └─ ProgressPanel
│     ├─ progressPanelContent (map fragments 0..46)
│     ├─ reward widgets (injetados por Lua)
│     └─ playerOutfit + progressPanelScrollBar
└─ footer
   ├─ close
   ├─ bPassWiki
   ├─ getVipPassTicket
   └─ rCoinPanel
```

## 4.2 Janelas auxiliares
- `SelectRewardWindow`: seleção/preview de reward antes de coletar.
- `ConfirmReward`: confirmação final de coleta.
- `RewardInfoSlot`: slot genérico para item/outfit/rewardSpecial.

## 4.3 Bindings de UI importantes
- `@onClick: loadMenu('challengesMenu'|'rewardsMenu')`
- `@onClick: modules.game_battlepass.redirectToStore()`
- Barra de scroll horizontal para missão e progress track.

---

## 5. Lógica do Sistema (Lua)

## 5.1 Inicialização e ciclo

- `init()`:
  - instancia UI (`g_ui.displayUI('battlepass')`)
  - cache de widgets principais
  - configura drag em `progressPanelContent`
  - registra eventos `g_game`: `onBattlePassMissions`, `onBattlePassRewards`, `onResourceBalance`
- `terminate()` desfaz binds/conexões.
- `online()` inicializa painéis (2 daily + 26 missions) e carrega config local.
- `offline()` salva estado de câmera/posição e limpa janelas auxiliares.

## 5.2 Funções centrais

### `BattlePass.onBattlePassMissions(...)`
Papel:
- entrada principal de dados de missão/progresso vindos do servidor.
- atualiza estado interno (`begin/end`, `points`, `premium`, `dailyMissions`, `seassonMissions`).
- chama `configureMissionPanel()`.

### `BattlePass.onBattlePassRewards(rewardSteps)`
Papel:
- recebe estrutura de rewards por step e chama `configureRewardPanel()`.

### `BattlePass:configureMissionPanel()`
Papel:
- preenche textos, barras de progresso, timers e widgets de daily/general missions.
- aplica estados visuais (`completed`, bloqueio, ícones por rank).

### `BattlePass:configureRewardPanel()`
Papel:
- avalia disponibilidade por step, premium/free e claimed.
- ajusta `RewardWidget` x `BlockedRewardWidget` e chest aberta/fechada.

### `BattlePass:rerollDailyMission(data)`
Papel:
- abre confirmação e dispara `g_game.rerollBattlePassMission(data.missionId)`.

### `BattlePassRewards:onConfirmClaimReward(index, rewardType)`
Papel:
- constrói janela de preview/seleção do prêmio.
- valida reward que exige escolha (choosable/exercise/skill/elemental etc).
- delega coleta para `onRedeemReward(...)`.

### `BattlePassRewards:onRedeemReward(index, internalRewardId, internalRewardType, objectId)`
Papel:
- envia `g_game.redeemBattlePass(...)`.

## 5.3 Persistência local
- `loadConfigJson()` / `saveConfigJson()` em `/characterdata/<playerId>/battlepass.json`.
- Dados locais persistidos:
  - `currentRewardStep` (último step mostrado)
  - `lastCameraPosition` (posição de scroll)
- Não persiste progresso real de missão (isso vem do servidor).

## 5.4 Premium vs Free
- O estado premium vem de `battlePassActive` no payload de missões.
- Rewards premium podem ficar com label “Deluxe” quando não adquirido.
- Botão `Get Deluxe Battle Pass` abre Store (`g_game.requestStoreOffers(3, "", 20)`).

---

## 6. Comunicação Cliente ⇄ Servidor

## 6.1 Fluxo de abertura

```text
UI (sidebuttons)
  -> g_game.requestBattlePass(0)
Servidor
  -> callback onBattlePassMissions(...)
  -> callback onBattlePassRewards(rewardSteps)
Cliente
  -> BattlePass:configureMissionPanel()
  -> BattlePass:configureRewardPanel()
```

## 6.2 Fluxo de reroll de missão diária

```text
Cliente (confirm window)
  -> g_game.rerollBattlePassMission(missionId)
Servidor
  -> recalcula missão diária e custo
  -> envia novo snapshot (onBattlePassMissions)
Cliente
  -> rerender painel diário
```

## 6.3 Fluxo de claim de reward

```text
Cliente (SelectRewardWindow/ConfirmReward)
  -> g_game.redeemBattlePass(stepIndex, rewardId, objectId)
Servidor
  -> valida desbloqueio/premium/claim
  -> envia atualização de rewards/missões
Cliente
  -> atualiza estado de chest e label claimed
```

## 6.4 ExtendedOpcode / ProtocolGame
- Não há uso explícito de ExtendedOpcode específico do Battle Pass dentro de `modules/mods/game_battlepass/*`.
- No cliente Lua, Battle Pass opera por callbacks de alto nível (`onBattlePassMissions`, `onBattlePassRewards`) e métodos `g_game.*`.
- O parse de pacote/opcode específico do Battle Pass não está declarado em `game_battlepass` (provável binding no core/C++).

---

## 7. Estrutura de Dados (modelo real no cliente)

## 7.1 Estado interno BattlePass

```lua
BattlePass = {
  beginTime = 0,
  endTime = 0,
  progressPoints = 0,
  dailyRerollPrice = 0,
  premiumBattlepass = false,
  currentRewardStep = 0,
  nextStepPoints = 0,
  dailyMissionsBegin = 0,
  dailyMissionsExpire = 0,
  dailyMissions = {},
  seassonMissions = {},
  rewardSteps = {}
}
```

## 7.2 Payload de missões (deduzido da assinatura)

`onBattlePassMissions(playerOutfit, beginTime, endTime, points, rerollPrice, battlePassActive, currentRewardStep, nextStepPoints, dailyBeginTime, dailyEndTime, dailyMissions, generalMissions)`

Campos usados por item de missão (daily/general):
- `missionId`
- `missionName`
- `missionDescription`
- `currentProgress`
- `maxProgress`
- `rewardPoints`

## 7.3 Payload de rewards
- `onBattlePassRewards(rewardSteps)`
- Cada step contém coleção de rewards com campos utilizados no client:
  - `rewardId`, `rewardType`, `freeReward`, `hasClamedReward`
  - campos variáveis por tipo (`itemId`, `count`, `randomValues`, `choosableValues`, `durationTime`, `addons`, etc.)

---

## 8. Dependências e Integrações

## 8.1 Módulos/UI
- `game_sidebuttons`: botão que abre Battle Pass.
- `game_store`: compra de passe deluxe via redirecionamento.
- `game_textmessage`: mensagens de validação/erro em seleção de reward.
- `core widgets` (`displayGeneralBox`, `NewHeadlessWindow`, `ProgressBarSD`, `ScrollablePanel`).

## 8.2 Integrações de domínio
- `game_skills` lê/mostra bônus de battle pass (`onBattlePassBonusChange`).
- `gamelib/player.lua` possui `InventorySlotBattlePass = 12` (integração com item/slot de passe).

## 8.3 Relação com Hunting Tasks/Task Board
- Não há dependência direta de lógica com Hunting Tasks.
- Ambos coexistem como sistemas de tarefas/recompensas, porém com pipelines independentes.

---

## 9. Reset semanal e temporalidade

- `calculateWeekNumber()` e `getNextResetWeek(currentIndex)` calculam ETA de unlock semanal com base em `beginTime` e corte às 10:00.
- O cliente só exibe countdown (`unlockInfo`); reset real ocorre no servidor.
- `running()` controla estado ativo da temporada (`endTime > os.time()`).

---

## 10. Análise Arquitetural

## 10.1 Modularidade
- Parcialmente modular: separação razoável entre `battlepass.lua` (orquestração) e `classes/rewards.lua` (coleta/preview).
- Ainda há acoplamento forte com detalhes de UI (ids OTUI hardcoded em quase toda lógica).

## 10.2 Acoplamento
- Alto acoplamento entre estado e rendering (pouca camada de transformação/view model).
- Dependência implícita de payload do servidor sem validação defensiva forte.

## 10.3 Reutilização para Task Board
Partes reutilizáveis:
- grid de missão com ícones de estado/progresso
- barra de tempo (daily/season)
- trilha de recompensas (free/premium)
- modal de claim com escolha

Partes específicas de temporada:
- lógica de `RewardPositions` fixa e extensa
- semântica “Deluxe Battle Pass”/store específica
- nomenclatura e iconografia próprias

## 10.4 Código potencialmente redundante/morto
- Assets presentes sem referência direta literal em OTUI/Lua (ex.: `mainIcon2`, `points-bg`, `reward-house*`, `battlepass-hourglass-red` no fluxo battlepass).
- Alguns cálculos/updates de UI poderiam ser centralizados para reduzir repetição (chest states, labels de reward, update de moedas).

## 10.5 Inconsistências observáveis
- Typo em nome de campo `seassonMissions`.
- Dependência de concatenação dinâmica para ícones exige naming estrito em assets (erro de nome quebra UI silenciosamente).

---

## 11. Fluxo end-to-end resumido

```pseudo
Open BattlePass button
  -> requestBattlePass(0)
  -> receive missions/rewards payload
  -> render mission view

switch to rewards tab
  -> requestBattlePass(1)
  -> render reward track

reroll daily
  -> confirm dialog
  -> rerollBattlePassMission(missionId)
  -> receive updated missions

claim reward
  -> open SelectRewardWindow
  -> optional select item/skill/element
  -> confirm dialog
  -> redeemBattlePass(step, rewardId, objectId)
  -> receive updated rewards
```

