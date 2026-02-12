# TaskBoard vs Custom (BattlePass/Tasks) — Structural Diff

## Referência comparada
- Custom: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/*`
- Alvo: `otclient/modules/game_taskboard/*`

## 1) Arquitetura de árvore de widgets

## Custom (BattlePass)
- `battlePassWindow/mainPanel/optionsTabBar/contentPanel`
- Subárvore principal:
  - `missionPanel` (challenges)
  - `progressPanel` (rewards track)

## TaskBoard (após adaptação)
- `taskBoardWindow/mainPanel/optionsTabBar/contentPanel`
- Subárvore principal:
  - `missionPanel` (bounty + weekly)
  - `progressPanel` (shop)

### Resultado
- **Equivalência estrutural aplicada** no shell principal:
  - janela -> mainPanel -> optionsTabBar -> contentPanel -> mission/progress.

## 2) Navegação de painéis

## Custom
- Botões em `optionsTabBar`:
  - `challengesMenu`
  - `rewardsMenu`
- Controller alterna visibilidade `missionPanel`/`progressPanel`.

## TaskBoard
- Botões em `optionsTabBar`:
  - `bountyMenu`
  - `weeklyMenu`
  - `shopMenu`
- Controller alterna:
  - `missionPanel` (bounty/weekly)
  - `progressPanel` (shop)
- Dentro de `missionPanel`, alterna `bountyPanel` e `weeklyPanel`.

### Resultado
- Mesmo padrão composicional: navegação por botões + hide/show de painéis principais.

## 3) Templates e list/grid composition

## Custom
- Templates:
  - `DailyMissionWidget`, `MissionWidget`, `RewardWidget`, `BlockedRewardWidget`.
- Painéis de lista/track:
  - `missionsBackground` (lista de missões)
  - `progressPanelContent` (track de rewards)

## TaskBoard
- Templates:
  - `TaskBoardBountyCard`, `TaskBoardWeeklySlot`, `TaskBoardShopCard`, `TaskBoardProgressTrack`, `TaskBoardTalismanPanel`.
- Painéis de composição:
  - `bountyCardsContainer`
  - `weeklyKillGrid` / `weeklyDeliveryGrid`
  - `shopGrid`

### Resultado
- Estrutura de composição equivalente (containers + templates), porém com templates de domínio TaskBoard.

## 4) Progress / rewards / claim flow

## Custom
- Progress global com `levelProgress` + textos de etapa.
- Claim por reward track (free/premium).

## TaskBoard
- Progress semanal com `weeklyProgressTrack/weeklyProgressBar`.
- Claim individual e diário de bounty + compra de shop.

### Resultado
- Equivalência de padrão de atualização incremental no controller; sem copiar semântica de BattlePass premium/free.

## 5) Store/State/Controller split

## Custom
- Estado aplicado por controller via callbacks de rede e atualização pontual dos widgets.

## TaskBoard
- Estado central em `state_store.lua` (`sync/delta`) + controller que faz render incremental.

### Resultado
- Equivalência de responsabilidade: state -> render tree update.

## 6) Diferenças intencionais (obrigatórias)
- Protocolo/Opcode:
  - TaskBoard mantém `242` + JSON `sync/delta`.
- Backend:
  - TaskBoard usa stack unificada de domínio no servidor.
- Domínio:
  - TaskBoard substitui premium/free reward track por bounty/weekly/shop.

## Conclusão
- O `game_taskboard` foi ajustado para espelhar a **estrutura-base do BattlePass custom** (hierarquia e padrão de navegação/render), mantendo as diferenças necessárias de protocolo e domínio.
