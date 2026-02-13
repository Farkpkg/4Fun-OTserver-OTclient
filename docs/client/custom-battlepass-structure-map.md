<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# Custom BattlePass/Tasks Structure Map (COMPLETE_CUSTOM_CLIENT)

## Escopo de busca
Keywords usadas em `COMPLETE_CUSTOM_CLIENT/modules`:
- `battlepass`
- `weekly`
- `task`
- `mission`
- `progress`
- `bounty`

## Arquivos principais detectados (núcleo equivalente)

### BattlePass principal
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otmod`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/const.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/classes/rewards.lua`

### Sistemas de tasks correlatos (não-BattlePass)
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/mods/game_prey_hunting/hunting.lua`
- `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.otui`
- `COMPLETE_CUSTOM_CLIENT/modules/game_prey/prey.lua`

## Estrutura de UI (BattlePass)

## Janela principal
- `battlePassWindow`
  - `mainPanel`
    - `optionsTabBar`
      - `challengesMenu`
      - `rewardsMenu`
    - `contentPanel`
      - `missionPanel`
      - `progressPanel`

## Mission side (desafios)
- `missionPanel`
  - `dailyBg`
    - `dailyMissionsBg`
      - `DailyMissionWidget` x2
  - `playerProgressPanel`
    - `levelProgress`
    - `currentlyLevelText`
    - `playerLevel`
  - `missionsBackground`
    - `MissionWidget` (lista)

## Rewards side (track/reward)
- `progressPanel`
  - `progressPanelContent`
    - `RewardWidget` (free/premium por step)
    - `BlockedRewardWidget`
  - `progressPanelScrollBar`
  - `playerOutfit`

## Templates relevantes
- `DailyMissionWidget`
- `MissionWidget`
- `RewardWidget`
- `BlockedRewardWidget`
- `RewardInfoSlot`

## Controller/Render flow (battlepass.lua)

### Inicialização
- Resolve refs por `recursiveGetChildById` (mission/progress/options/bar etc.).
- Prepara widgets base e estados de painel.

### Aplicação de estado
- Missões diárias: seta nome, pontos, progresso, ícone e botão de reroll.
- Missões gerais: popula `missionsBackground` por ordem/rank.
- Reward track: popula rewards por step (free/premium), controla estado claim/unlock.
- Progress: atualiza `playerLevel`, `%` em `levelProgress`, textos de temporada.

### Navegação
- Troca de “aba” via `optionsTabBar` (botões `challengesMenu` / `rewardsMenu`) e hide/show dos painéis.

## Conclusão de mapeamento
- O BattlePass do custom é um layout **com dois painéis principais** (mission/progress) e navegação por **botões em optionsTabBar**.
- A aplicação de estado é orientada por árvore de widgets e updates incrementais em templates.
