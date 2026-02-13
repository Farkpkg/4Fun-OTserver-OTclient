<!-- REVIEW: Este documento referencia `COMPLETE_CUSTOM_CLIENT` (repositório externo não versionado neste projeto). Validar manualmente equivalência com `otclient/` atual antes de usar como fonte de verdade. -->

# Custom BattlePass Full Map (1:1 Target)

## Arquivos núcleo (COMPLETE_CUSTOM_CLIENT)
- `modules/mods/game_battlepass/battlepass.otmod`
- `modules/mods/game_battlepass/battlepass.otui`
- `modules/mods/game_battlepass/battlepass.lua`
- `modules/mods/game_battlepass/const.lua`
- `modules/mods/game_battlepass/classes/rewards.lua`

## Estrutura OTUI principal
- `battlePassWindow`
  - `mainPanel`
    - `optionsTabBar` (`challengesMenu`, `rewardsMenu`)
    - `contentPanel`
      - `missionPanel`
      - `progressPanel`

## missionPanel (custom)
- Área de daily missions (`dailyMissionsBg`, widgets dedicados)
- Área de progresso de nível (`playerLevel`, `levelProgress`, `currentlyLevelText`)
- Lista de missões gerais (`missionsBackground` + `MissionWidget`)

## progressPanel (custom)
- Reward track (free + premium)
- Scroll/horizontal track
- Estados visuais por reward:
  - locked
  - available
  - claimed

## Controller/render flow (battlepass.lua)
- Resolve árvore via `recursiveGetChildById`
- Toggle de painéis por menu
- Render incremental de:
  - daily
  - missions
  - reward steps
  - level/progress

## Assets e estilos usados no custom
- `data/images/game/battlepass/*`
- painéis, ícones de missão, chest free/premium, estados de claim/bloqueio

## Domínio visual (experiência)
- Navegação de 2 abas mentais: Challenges / Rewards
- Daily + mission list no lado challenges
- Progressão em níveis e trilha de recompensa no lado rewards
